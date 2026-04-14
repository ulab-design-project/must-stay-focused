import 'dart:async';
import 'dart:typed_data';
import 'package:app_usage/app_usage.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

class AndroidAppUsageMonitor {
  static final AndroidAppUsageMonitor _instance = AndroidAppUsageMonitor._internal();
  factory AndroidAppUsageMonitor() => _instance;
  AndroidAppUsageMonitor._internal();

  Future<void> requestUsagePermissions() async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(minutes: 1));
      await AppUsage().getAppUsage(startDate, endDate);
    } catch (e) {
      print("App usage permission error: $e");
    }
  }

  // Cache for the usage stats to avoid heavy platform calls.
  List<AppUsageInfo>? _cachedUsageList;
  DateTime? _lastCacheTime;
  Future<List<AppUsageInfo>>? _pendingUsageRequest;

  Stream<int> getUsageTodayStream(String packageName) async* {
    yield await getUsageToday(packageName);
  }

  Future<int> getUsageToday(String packageName) async {
    try {
      final now = DateTime.now();
      
      // If cache is null or older than 60 seconds, fetch fresh.
      if (_cachedUsageList == null || _lastCacheTime == null || now.difference(_lastCacheTime!).inSeconds > 60) {
        if (_pendingUsageRequest == null) {
          final startDate = DateTime(now.year, now.month, now.day);
          _pendingUsageRequest = AppUsage().getAppUsage(startDate, now);
        }
        _cachedUsageList = await _pendingUsageRequest;
        _lastCacheTime = now;
        _pendingUsageRequest = null;
      }

      for (var info in _cachedUsageList!) {
        if (info.packageName == packageName) {
          return info.usage.inMinutes;
        }
      }
    } catch (e) {
      print("App usage error: $e");
    }
    return 0;
  }

  // Cache installed apps so icon-heavy platform calls happen once per cache window.
  List<AppInfo>? _cachedInstalledApps;
  DateTime? _lastAppCacheTime;
  Future<List<AppInfo>>? _pendingInstalledAppsRequest;
  final Map<String, Uint8List> _trackedIconCache = {};

  Future<List<AppInfo>> getInstalledApps() async {
    try {
      final now = DateTime.now();
      if (_cachedInstalledApps == null || _lastAppCacheTime == null || now.difference(_lastAppCacheTime!).inMinutes > 5) {
        _pendingInstalledAppsRequest ??= InstalledApps.getInstalledApps(
          excludeSystemApps: false,
          withIcon: true,
          excludeNonLaunchableApps: true,
        );

        _cachedInstalledApps = await _pendingInstalledAppsRequest;
        _lastAppCacheTime = now;
        _pendingInstalledAppsRequest = null;
      }

      return _cachedInstalledApps!;
    } catch (e) {
      _pendingInstalledAppsRequest = null;
      print("Error fetching installed apps: $e");
      return [];
    }
  }

  Future<Map<String, Uint8List>> getTrackedAppIcons(Set<String> packageNames) async {
    if (packageNames.isEmpty) {
      return const {};
    }

    try {
      for (final packageName in packageNames) {
        if (_trackedIconCache.containsKey(packageName)) {
          continue;
        }

        final apps = await InstalledApps.getInstalledApps(
          excludeSystemApps: false,
          excludeNonLaunchableApps: true,
          withIcon: true,
          packageNamePrefix: packageName,
        );

        for (final app in apps) {
          if (app.packageName != packageName) {
            continue;
          }

          final icon = app.icon;
          if (icon != null && icon.isNotEmpty) {
            _trackedIconCache[packageName] = icon;
          }
          break;
        }
      }

      final icons = <String, Uint8List>{};
      for (final packageName in packageNames) {
        final icon = _trackedIconCache[packageName];
        if (icon != null) {
          icons[packageName] = icon;
        }
      }

      return icons;
    } catch (e) {
      print("Error getting tracked app icons: $e");
      return const {};
    }
  }
}

