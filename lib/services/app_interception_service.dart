import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';

import '../data/db/isar_service.dart';
import '../data/models/app_usage.dart';
import '../data/models/user_settings.dart';

class AppInterceptionService {
  AppInterceptionService._internal();

  static final AppInterceptionService _instance =
      AppInterceptionService._internal();

  factory AppInterceptionService() => _instance;

  static const MethodChannel _channel = MethodChannel(
    'must_stay_focused_interception',
  );

  Future<void> syncTrackedAppsFromDatabase() async {
    try {
      final apps = await idb.appUsages.where().findAll();
      final packageNames = apps
          .where((app) => app.isTracked)
          .map((app) => app.appId.trim())
          .where((appId) => appId.isNotEmpty)
          .toSet()
          .toList(growable: false);

      await _channel.invokeMethod<void>('syncTrackedApps', {
        'packageNames': packageNames,
      });
    } catch (e, stackTrace) {
      debugPrint(
        'AppInterceptionService syncTrackedAppsFromDatabase error: $e',
      );
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> syncSettings() async {
    try {
      final settings = await idb.userSettings.get(1);
      await _channel.invokeMethod<void>('syncSettings', {
        'warningSecondsBeforeIntercept':
            settings?.warningSecondsBeforeIntercept ?? 10,
        'notificationsEnabled': settings?.notificationsEnabled ?? true,
      });
    } catch (e, stackTrace) {
      debugPrint('AppInterceptionService syncSettings error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<String?> consumeInterceptedAppId() async {
    try {
      final dynamic intercepted = await _channel.invokeMethod(
        'consumeInterceptedAppId',
      );

      if (intercepted is String && intercepted.trim().isNotEmpty) {
        return intercepted.trim();
      }
    } catch (e, stackTrace) {
      debugPrint('AppInterceptionService consumeInterceptedAppId error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }

    return null;
  }

  Future<bool> isAccessibilityServiceEnabled() async {
    try {
      final enabled = await _channel.invokeMethod<bool>(
        'isAccessibilityServiceEnabled',
      );
      return enabled ?? false;
    } catch (e, stackTrace) {
      debugPrint(
        'AppInterceptionService isAccessibilityServiceEnabled error: $e',
      );
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  Future<void> openAccessibilitySettings() async {
    try {
      await _channel.invokeMethod<void>('openAccessibilitySettings');
    } catch (e, stackTrace) {
      debugPrint('AppInterceptionService openAccessibilitySettings error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> setAppBypassMinutes({
    required String appId,
    required int minutes,
  }) async {
    final safeAppId = appId.trim();
    if (safeAppId.isEmpty) {
      return;
    }

    final int safeMinutes;
    if (minutes < 1) {
      safeMinutes = 1;
    } else if (minutes > 24 * 60) {
      safeMinutes = 24 * 60;
    } else {
      safeMinutes = minutes;
    }

    try {
      await _channel.invokeMethod<void>('setAppBypassMinutes', {
        'appId': safeAppId,
        'minutes': safeMinutes,
      });
    } catch (e, stackTrace) {
      debugPrint('AppInterceptionService setAppBypassMinutes error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
