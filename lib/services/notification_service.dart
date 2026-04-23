import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:must_stay_focused/data/db/isar_service.dart';
import 'package:must_stay_focused/data/models/user_settings.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Manages local push notifications for the app.
/// Uses flutter_local_notifications to schedule and display warnings
/// before an app is intercepted.
class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  static const String _channelId = 'app_intercept_warnings';
  static const String _channelName = 'App Interception Warnings';
  static const String _channelDescription = 'Warnings before an app is blocked';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Map to track scheduled notification IDs per app
  final Map<String, int> _scheduledNotifications = {};

  /// Initializes the plugin and creates the notification channel.
  Future<void> init() async {
    // Initialize timezone database for zonedSchedule
    tz.initializeTimeZones();

    const AndroidInitializationSettings initSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: initSettingsAndroid,
    );

    await _plugin.initialize(settings: initSettings);

    // Create notification channel for Android 8+
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Schedules a warning notification for the given app.
  /// The notification will fire after [warningDelaySeconds] seconds.
  Future<void> scheduleAppWarning({
    required String appId,
    required String appName,
    required int warningDelaySeconds,
  }) async {
    if (warningDelaySeconds <= 0) return;

    // Cancel any existing warning for this app
    cancelWarning(appId);

    // Respect global notifications setting
    final settings = await idb.userSettings.get(1);
    final notificationsEnabled = settings?.notificationsEnabled ?? true;
    if (!notificationsEnabled) return;

    final scheduledTime = tz.TZDateTime.now(
      tz.local,
    ).add(Duration(seconds: warningDelaySeconds));
    final notificationId = appId.hashCode;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'App time running out',
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _plugin.zonedSchedule(
      id: notificationId,
      scheduledDate: scheduledTime,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      title: 'Time is almost up!',
      body: '$appName will be blocked in $warningDelaySeconds seconds',
      payload: appId,
    );

    _scheduledNotifications[appId] = notificationId;
  }

  /// Cancels any pending warning notification for the given [appId].
  Future<void> cancelWarning(String appId) async {
    final notificationId = _scheduledNotifications[appId];
    if (notificationId != null) {
      await _plugin.cancel(id: notificationId);
      _scheduledNotifications.remove(appId);
    }
  }

  /// Cancels all pending warning notifications.
  Future<void> cancelAllWarnings() async {
    for (final id in _scheduledNotifications.values) {
      await _plugin.cancel(id: id);
    }
    _scheduledNotifications.clear();
  }
}
