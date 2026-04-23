package com.virtuous_volition.msf

import android.accessibilityservice.AccessibilityService
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

class InterceptionService : AccessibilityService() {
    companion object {
        private const val TAG = "InterceptionService"
        private const val INTERCEPT_COOLDOWN_MS = 1200L
        private const val SAME_PACKAGE_EVENT_THROTTLE_MS = 700L
        private const val BYPASS_EXPIRY_CHECK_GRACE_MS = 200L
        private const val FOREGROUND_QUERY_WINDOW_MS = 20_000L

        private val ignoredPackages = setOf(
            "android",
            "com.android.systemui",
            "com.google.android.permissioncontroller",
            "com.google.android.packageinstaller",
        )

        // SharedPreferences keys for warning settings
        private const val PREFS_NAME = "msf_interception_prefs"
        private const val PREF_WARNING_SECONDS = "pref_warning_seconds"
        private const val PREF_NOTIFICATIONS_ENABLED = "pref_notifications_enabled"
    }

    private val mainHandler = Handler(Looper.getMainLooper())
    private var lastObservedPackage = ""
    private var lastObservedAt = 0L
    private var lastInterceptedPackage = ""
    private var lastInterceptedAt = 0L

    private var scheduledBypassCheckPackage: String? = null
    private var scheduledBypassUntilElapsed = 0L

    // Map to hold warning notification runnables per app
    private val warningRunnables = mutableMapOf<String, Runnable>()

    private val bypassExpiryRunnable = Runnable {
        try {
            val packageName = scheduledBypassCheckPackage ?: return@Runnable
            scheduledBypassCheckPackage = null
            scheduledBypassUntilElapsed = 0L

            val foregroundPackage = resolveForegroundPackage()
            if (foregroundPackage.isNullOrEmpty()) {
                Log.d(TAG, "Bypass expiry check skipped, no foreground package available")
                return@Runnable
            }

            if (foregroundPackage != packageName) {
                Log.d(TAG, "Bypass expiry check skipped, foreground=$foregroundPackage expected=$packageName")
                return@Runnable
            }

            evaluatePackageForInterception(packageName, forceIntercept = true)
        } catch (e: Exception) {
            Log.e(TAG, "bypassExpiryRunnable error", e)
        }
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        createNotificationChannel()
        Log.d(TAG, "Interception service connected")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        try {
            if (event == null) {
                return
            }

            val isRelevantEvent =
                event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED ||
                event.eventType == AccessibilityEvent.TYPE_WINDOWS_CHANGED

            if (!isRelevantEvent) {
                return
            }

            val foregroundPackage = event.packageName?.toString()?.trim().orEmpty()
            if (foregroundPackage.isEmpty()) {
                return
            }

            val now = SystemClock.elapsedRealtime()
            val isSameForegroundPackage = foregroundPackage == lastObservedPackage
            if (isSameForegroundPackage && now - lastObservedAt < SAME_PACKAGE_EVENT_THROTTLE_MS) {
                return
            }

            lastObservedPackage = foregroundPackage
            lastObservedAt = now

            evaluatePackageForInterception(foregroundPackage)
        } catch (e: Exception) {
            Log.e(TAG, "onAccessibilityEvent error", e)
        }
    }

    private fun evaluatePackageForInterception(
        packageNameToEvaluate: String,
        forceIntercept: Boolean = false,
    ) {
        try {
            if (packageNameToEvaluate.isEmpty()) {
                return
            }

            if (packageNameToEvaluate == packageName || ignoredPackages.contains(packageNameToEvaluate)) {
                return
            }

            val trackedPackages = MainActivity.readTrackedPackages(this)
            if (!trackedPackages.contains(packageNameToEvaluate)) {
                return
            }

            val now = SystemClock.elapsedRealtime()
            val bypassUntil = MainActivity.readBypassUntilElapsed(this, packageNameToEvaluate)
            if (bypassUntil > now) {
                scheduleBypassExpiryCheck(packageNameToEvaluate, bypassUntil)
                return
            }

            if (bypassUntil > 0L) {
                MainActivity.clearBypassForApp(this, packageNameToEvaluate)
            }

            if (scheduledBypassCheckPackage == packageNameToEvaluate) {
                clearBypassExpiryCheck()
            }

            val isDuplicate =
                packageNameToEvaluate == lastInterceptedPackage &&
                now - lastInterceptedAt < INTERCEPT_COOLDOWN_MS
            if (isDuplicate && !forceIntercept) {
                return
            }

            lastInterceptedPackage = packageNameToEvaluate
            lastInterceptedAt = now

            launchInterceptionActivity(packageNameToEvaluate)
        } catch (e: Exception) {
            Log.e(TAG, "evaluatePackageForInterception error", e)
        }
    }

    private fun launchInterceptionActivity(interceptedPackage: String) {
        try {
            val launchIntent = Intent(this, MainActivity::class.java).apply {
                addFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP,
                )
                putExtra(MainActivity.EXTRA_INTERCEPTED_APP_ID, interceptedPackage)
            }

            startActivity(launchIntent)
            Log.d(TAG, "Interception launched for $interceptedPackage")
        } catch (e: Exception) {
            Log.e(TAG, "launchInterceptionActivity error", e)
        }
    }

    private fun scheduleBypassExpiryCheck(packageName: String, bypassUntil: Long) {
        try {
            if (bypassUntil <= 0L) {
                return
            }

            if (
                scheduledBypassCheckPackage == packageName &&
                kotlin.math.abs(scheduledBypassUntilElapsed - bypassUntil) <= 250L
            ) {
                return
            }

            val now = SystemClock.elapsedRealtime()
            val delayMs = (bypassUntil - now).coerceAtLeast(0L) + BYPASS_EXPIRY_CHECK_GRACE_MS

            clearBypassExpiryCheck()
            scheduledBypassCheckPackage = packageName
            scheduledBypassUntilElapsed = bypassUntil
            mainHandler.postDelayed(bypassExpiryRunnable, delayMs)

            // Schedule warning notification before the bypass expires
            scheduleWarningNotification(packageName, bypassUntil)
        } catch (e: Exception) {
            Log.e(TAG, "scheduleBypassExpiryCheck error", e)
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "app_intercept_warnings",
                "App Interception Warnings",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Warnings before an app is blocked"
            }
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }
    }

    private fun clearWarningRunnable(packageName: String) {
        warningRunnables[packageName]?.let { runnable ->
            mainHandler.removeCallbacks(runnable)
            warningRunnables.remove(packageName)
        }
    }

    private fun scheduleWarningNotification(packageName: String, bypassUntil: Long) {
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val notifEnabled = prefs.getBoolean(PREF_NOTIFICATIONS_ENABLED, true)
        if (!notifEnabled) return

        val warningSec = prefs.getInt(PREF_WARNING_SECONDS, 10)
        val now = SystemClock.elapsedRealtime()
        val warningMs = warningSec * 1000L
        val timeUntilWarning = bypassUntil - now - warningMs

        // Clear any existing warning for this package
        clearWarningRunnable(packageName)

        if (timeUntilWarning <= 0) return

        val runnable = Runnable {
            warningRunnables.remove(packageName)
            try {
                val pm = packageManager
                val appInfo = pm.getApplicationInfo(packageName, 0)
                val appName = pm.getApplicationLabel(appInfo).toString()
                sendWarningNotification(appName, warningSec)
            } catch (e: Exception) {
                Log.e(TAG, "Failed to send warning notification", e)
            }
        }

        warningRunnables[packageName] = runnable
        mainHandler.postDelayed(runnable, timeUntilWarning)
    }

    private fun sendWarningNotification(appName: String, secondsLeft: Int) {
        val notificationManager = NotificationManagerCompat.from(this)
        val notificationId = appName.hashCode()
        val notification = NotificationCompat.Builder(this, "app_intercept_warnings")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle("Time is almost up!")
            .setContentText("$appName will be blocked in $secondsLeft seconds")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .build()
        notificationManager.notify(notificationId, notification)
    }

    private fun resolveForegroundPackage(): String? {
        try {
            val rootPackage = rootInActiveWindow?.packageName?.toString()?.trim()
            if (!rootPackage.isNullOrEmpty()) {
                return rootPackage
            }
        } catch (e: Exception) {
            Log.d(TAG, "resolveForegroundPackage root lookup failed: ${e.message}")
        }

        try {
            val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
                ?: return lastObservedPackage.takeIf { it.isNotEmpty() }

            val end = System.currentTimeMillis()
            val start = end - FOREGROUND_QUERY_WINDOW_MS
            val usageEvents = usageStatsManager.queryEvents(start, end)
            val event = UsageEvents.Event()

            var latestPackage: String? = null
            var latestTimestamp = 0L

            while (usageEvents.hasNextEvent()) {
                usageEvents.getNextEvent(event)

                val isForegroundEvent =
                    event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND ||
                    event.eventType == UsageEvents.Event.ACTIVITY_RESUMED

                if (!isForegroundEvent) {
                    continue
                }

                val pkg = event.packageName?.trim().orEmpty()
                if (pkg.isEmpty()) {
                    continue
                }

                if (event.timeStamp >= latestTimestamp) {
                    latestTimestamp = event.timeStamp
                    latestPackage = pkg
                }
            }

            if (!latestPackage.isNullOrEmpty()) {
                return latestPackage
            }
        } catch (e: Exception) {
            Log.d(TAG, "resolveForegroundPackage usage lookup failed: ${e.message}")
        }

        return lastObservedPackage.takeIf { it.isNotEmpty() }
    }

    private fun clearBypassExpiryCheck() {
        try {
            mainHandler.removeCallbacks(bypassExpiryRunnable)
            scheduledBypassCheckPackage = null
            scheduledBypassUntilElapsed = 0L
        } catch (e: Exception) {
            Log.e(TAG, "clearBypassExpiryCheck error", e)
        }
    }

    override fun onInterrupt() {
        clearBypassExpiryCheck()
        clearAllWarnings()
        Log.d(TAG, "Interception service interrupted")
    }

    override fun onDestroy() {
        clearBypassExpiryCheck()
        clearAllWarnings()
        super.onDestroy()
    }

    private fun clearAllWarnings() {
        warningRunnables.values.forEach { mainHandler.removeCallbacks(it) }
        warningRunnables.clear()
    }
}