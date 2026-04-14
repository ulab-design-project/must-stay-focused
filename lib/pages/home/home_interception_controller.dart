import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:isar/isar.dart';

import '../../data/db/isar_service.dart';
import '../../data/models/app_usage.dart';
import '../../data/models/user_settings.dart';
import '../../services/app_interception_service.dart';
import '../../services/appUsageMonitor/android_app_usage.dart';

class InterceptedAppSnapshot {
  final AppUsage app;
  final Uint8List? iconBytes;

  const InterceptedAppSnapshot({required this.app, required this.iconBytes});
}

class HomeInterceptionController {
  HomeInterceptionController({
    AndroidAppUsageMonitor? usageMonitor,
    AppInterceptionService? interceptionService,
  }) : _usageMonitor = usageMonitor ?? AndroidAppUsageMonitor(),
       _interceptionService = interceptionService ?? AppInterceptionService();

  final AndroidAppUsageMonitor _usageMonitor;
  final AppInterceptionService _interceptionService;

  Future<void> syncTrackedApps() async {
    await _interceptionService.syncTrackedAppsFromDatabase();
  }

  Future<String?> consumeInterceptedAppId() async {
    return _interceptionService.consumeInterceptedAppId();
  }

  Future<List<AppUsage>> getTrackedApps() async {
    try {
      return await idb.appUsages.where().findAll();
    } catch (e, stackTrace) {
      debugPrint('HomeInterceptionController getTrackedApps error: $e');
      debugPrintStack(stackTrace: stackTrace);
      return const [];
    }
  }

  Future<InterceptedAppSnapshot?> loadSnapshot(
    String appId, {
    bool includeIcon = true,
  }) async {
    try {
      final app = await idb.appUsages.where().appIdEqualTo(appId).findFirst();
      if (app == null) {
        return null;
      }

      final usedTodayMinutes = await _usageMonitor.getUsageToday(appId);
      app.totalUsedTime = usedTodayMinutes;

      Uint8List? iconBytes;
      if (includeIcon) {
        iconBytes = await loadAppIcon(appId);
      }

      return InterceptedAppSnapshot(app: app, iconBytes: iconBytes);
    } catch (e, stackTrace) {
      debugPrint('HomeInterceptionController loadSnapshot error: $e');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  Future<Uint8List?> loadAppIcon(String appId) async {
    try {
      final iconMap = await _usageMonitor.getTrackedAppIcons({appId});
      return iconMap[appId];
    } catch (e, stackTrace) {
      debugPrint('HomeInterceptionController loadAppIcon error: $e');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  Future<int> getDefaultOvertimeLimitMinutes() async {
    try {
      final UserSettings? settings = await idb.userSettings.get(1);
      final int value = settings?.defaultOvertimeLimitMinutes ?? 15;
      return value < 0 ? 0 : value;
    } catch (e, stackTrace) {
      debugPrint(
        'HomeInterceptionController getDefaultOvertimeLimitMinutes error: $e',
      );
      debugPrintStack(stackTrace: stackTrace);
      return 15;
    }
  }

  int _effectiveOvertimeMinutes(AppUsage app, {int? maxOvertimeMinutes}) {
    final storedOvertime = app.overTimeLimitToday < 0
        ? 0
        : app.overTimeLimitToday;
    if (maxOvertimeMinutes == null) {
      return storedOvertime;
    }

    final safeMax = maxOvertimeMinutes < 0 ? 0 : maxOvertimeMinutes;
    return min(storedOvertime, safeMax);
  }

  int remainingMinutes(AppUsage app, {int? maxOvertimeMinutes}) {
    final effectiveOvertime = _effectiveOvertimeMinutes(
      app,
      maxOvertimeMinutes: maxOvertimeMinutes,
    );
    final allowance = app.maxDailyTimeLimit + effectiveOvertime;
    return max(allowance - app.totalUsedTime, 0);
  }

  bool isUsageOverLimit(AppUsage app, {int? maxOvertimeMinutes}) {
    return remainingMinutes(app, maxOvertimeMinutes: maxOvertimeMinutes) <= 0;
  }

  int continueBypassMinutes(AppUsage app, {int? maxOvertimeMinutes}) {
    final remaining = remainingMinutes(
      app,
      maxOvertimeMinutes: maxOvertimeMinutes,
    );
    return max(remaining, 1);
  }

  Future<void> launchAppWithBypass({
    required AppUsage app,
    required int bypassMinutes,
  }) async {
    try {
      await _interceptionService.setAppBypassMinutes(
        appId: app.appId,
        minutes: bypassMinutes,
      );
      await InstalledApps.startApp(app.appId);
    } catch (e, stackTrace) {
      debugPrint('HomeInterceptionController launchAppWithBypass error: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }
}
