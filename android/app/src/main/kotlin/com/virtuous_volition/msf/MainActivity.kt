package com.virtuous_volition.msf

import android.app.AppOpsManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.Process
import android.os.SystemClock
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    companion object {
        const val EXTRA_INTERCEPTED_APP_ID = "extra_intercepted_app_id"

        private const val PREFS_NAME = "msf_interception_prefs"
        private const val PREF_TRACKED_PACKAGES = "tracked_packages"
    private const val PREF_BYPASS_PREFIX = "bypass_until_"
    private const val PREF_WARNING_SECONDS = "pref_warning_seconds"
    private const val PREF_NOTIFICATIONS_ENABLED = "pref_notifications_enabled"

    @Volatile
    private var pendingInterceptedAppId: String? = null

        fun readTrackedPackages(context: Context): Set<String> {
            return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .getStringSet(PREF_TRACKED_PACKAGES, emptySet())
                ?.toSet()
                ?: emptySet()
        }

        fun writeTrackedPackages(context: Context, packages: Set<String>) {
            context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .edit()
                .putStringSet(PREF_TRACKED_PACKAGES, packages)
                .apply()
        }

        fun writeBypassUntilElapsed(
            context: Context,
            packageName: String,
            bypassUntilElapsed: Long,
        ) {
            context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .edit()
                .putLong("$PREF_BYPASS_PREFIX$packageName", bypassUntilElapsed)
                .apply()
        }

        fun readBypassUntilElapsed(context: Context, packageName: String): Long {
            return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .getLong("$PREF_BYPASS_PREFIX$packageName", 0L)
        }

        fun clearBypassForApp(context: Context, packageName: String) {
            context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .edit()
                .remove("$PREF_BYPASS_PREFIX$packageName")
                .apply()
        }
    }

    private val permissionsChannel = "must_stay_focused_permissions"
    private val interceptionChannel = "must_stay_focused_interception"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        captureInterceptedIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        captureInterceptedIntent(intent)
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, permissionsChannel)
            .setMethodCallHandler { call, result ->
                if (call.method == "checkUsageAccess") {
                    result.success(hasUsageAccess())
                } else {
                    result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, interceptionChannel)
            .setMethodCallHandler { call, result ->
                handleInterceptionCall(call, result)
            }
    }

    private fun handleInterceptionCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "syncTrackedApps" -> {
                val packages = call.argument<List<String>>("packageNames")
                    ?.map { it.trim() }
                    ?.filter { it.isNotEmpty() && it != packageName }
                    ?.toSet()
                    ?: emptySet()

                writeTrackedPackages(this, packages)
                result.success(true)
            }

            "syncSettings" -> {
                val warningSec = call.argument<Int>("warningSecondsBeforeIntercept") ?: 10
                val notifEnabled = call.argument<Boolean>("notificationsEnabled") ?: true
                val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                prefs.edit()
                    .putInt(PREF_WARNING_SECONDS, warningSec)
                    .putBoolean(PREF_NOTIFICATIONS_ENABLED, notifEnabled)
                    .apply()
                result.success(true)
            }

            "consumeInterceptedAppId" -> {
                val intercepted = pendingInterceptedAppId
                pendingInterceptedAppId = null
                result.success(intercepted)
            }

            "isAccessibilityServiceEnabled" -> {
                result.success(isAccessibilityServiceEnabled())
            }

            "openAccessibilitySettings" -> {
                try {
                    startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
                    result.success(true)
                } catch (e: Exception) {
                    result.error(
                        "OPEN_ACCESSIBILITY_SETTINGS_ERROR",
                        e.message,
                        null,
                    )
                }
            }

            "setAppBypassMinutes" -> {
                val appId = call.argument<String>("appId")?.trim().orEmpty()
                val minutes = call.argument<Int>("minutes") ?: 1

                if (appId.isEmpty()) {
                    result.success(false)
                    return
                }

                val safeMinutes = minutes.coerceAtLeast(1)
                val bypassDurationMs = safeMinutes.toLong() * 60_000L
                val bypassUntil = SystemClock.elapsedRealtime() + bypassDurationMs

                writeBypassUntilElapsed(this, appId, bypassUntil)
                result.success(true)
            }

            else -> result.notImplemented()
        }
    }

    private fun captureInterceptedIntent(intent: Intent?) {
        val packageId = intent
            ?.getStringExtra(EXTRA_INTERCEPTED_APP_ID)
            ?.trim()

        if (!packageId.isNullOrEmpty()) {
            pendingInterceptedAppId = packageId
        }
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        return try {
            val enabled = Settings.Secure.getString(
                contentResolver,
                Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES,
            ) ?: return false

            val expected = ComponentName(this, InterceptionService::class.java)

            val isEnabled = enabled.split(':').any { flattened ->
                ComponentName.unflattenFromString(flattened) == expected
            }

            val accessibilityOn = Settings.Secure.getInt(
                contentResolver,
                Settings.Secure.ACCESSIBILITY_ENABLED,
                0,
            ) == 1

            isEnabled && accessibilityOn
        } catch (e: Exception) {
            false
        }
    }

    private fun hasUsageAccess(): Boolean {
        return try {
            val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
            val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                appOps.unsafeCheckOpNoThrow(
                    AppOpsManager.OPSTR_GET_USAGE_STATS,
                    Process.myUid(), packageName
                )
            } else {
                appOps.checkOpNoThrow(
                    AppOpsManager.OPSTR_GET_USAGE_STATS,
                    Process.myUid(), packageName
                )
            }
            mode == AppOpsManager.MODE_ALLOWED
        } catch (e: Exception) {
            false
        }
    }
}
