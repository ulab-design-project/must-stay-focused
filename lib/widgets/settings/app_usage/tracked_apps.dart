import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:must_stay_focused/widgets/settings/app_usage/add_app_dialog.dart';
import '../../../style/buttons.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../../../style/theme.dart';
import '../../../data/models/app_usage.dart';
import '../../../data/db/isar_service.dart';
import '../../../services/app_interception_service.dart';
import '../../../services/appUsageMonitor/android_app_usage.dart';
import 'app_usage_card.dart';
import 'default_interception_settings_dialog.dart';

class TrackedAppsWidget extends StatefulWidget {
  const TrackedAppsWidget({super.key});

  @override
  State<TrackedAppsWidget> createState() => _TrackedAppsWidgetState();
}

class _TrackedAppsWidgetState extends State<TrackedAppsWidget> {
  bool _isLoading = true;
  List<AppUsage> _trackedApps = const [];
  Map<String, int> _usageMap = const {};
  Map<String, Uint8List> _iconMap = const {};
  int _loadVersion = 0;
  late StreamSubscription<void> _dbSubscription;

  @override
  void initState() {
    super.initState();
    _loadTrackedApps();
    _dbSubscription = idb.appUsages.watchLazy().listen((_) {
      _loadTrackedApps();
    });
  }

  @override
  void dispose() {
    _dbSubscription.cancel();
    super.dispose();
  }

  // Load tracked apps first so the page can render immediately.
  Future<void> _loadTrackedApps() async {
    final int version = ++_loadVersion;

    try {
      final existingApps = await idb.appUsages.where().findAll();
      await AppInterceptionService().syncTrackedAppsFromDatabase();

      if (mounted && version == _loadVersion) {
        setState(() {
          _trackedApps = existingApps;
          _isLoading = false;
          _usageMap = const {};
          _iconMap = const {};
        });
      }

      _loadUsageAndIcons(existingApps, version);
    } catch (e, stackTrace) {
      debugPrint('TrackedAppsWidget: failed to load tracked apps: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted && version == _loadVersion) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Load heavy data after first paint to keep route transition smooth.
  Future<void> _loadUsageAndIcons(List<AppUsage> apps, int version) async {
    if (!mounted || version != _loadVersion) return;
    if (apps.isEmpty) return;

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted || version != _loadVersion) return;

    try {
      final usage = <String, int>{};
      for (final app in apps) {
        usage[app.appId] = await AndroidAppUsageMonitor().getUsageToday(app.appId);
      }

      final trackedIds = apps.map((app) => app.appId).toSet();
      final icons = await AndroidAppUsageMonitor().getTrackedAppIcons(trackedIds);

      if (mounted && version == _loadVersion) {
        setState(() {
          _usageMap = usage;
          _iconMap = icons;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('TrackedAppsWidget: failed to load usage/icon data: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  void _openAddDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddAppDialog(),
    );
  }

  void _openDefaultSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => const DefaultInterceptionSettingsDialog(),
    );
  }

  Future<void> _untrackApp(AppUsage usage) async {
    try {
      await idb.writeTxn(() async {
        await idb.appUsages.delete(usage.id);
      });
      // Stream listener handles reload implicitly.
    } catch (e, stackTrace) {
      debugPrint('TrackedAppsWidget: failed to untrack app ${usage.appId}: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return GlassCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Tracked Apps",
                  style: TextStyle(
                    fontSize: AppTextSizes.title,
                    fontWeight: FontWeight.bold,
                    color: onSurface,
                  ),
                ),
              ),
              GlassSquircleIconButton(
                icon: Icon(Icons.tune, color: onSurface),
                onPressed: _openDefaultSettingsDialog,
                size: AppElementSizes.buttonSquare,
              ),
              const SizedBox(width: AppElementSizes.spacingSm),
              GlassSquircleIconButton(
                icon: Icon(Icons.add, color: onSurface),
                onPressed: _openAddDialog,
                size: AppElementSizes.buttonSquare,
              ),
            ],
          ),
          const SizedBox(height: AppElementSizes.spacingLg),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(AppElementSizes.spacingLg),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_trackedApps.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Text(
                "No apps tracked yet.",
                textAlign: TextAlign.center,
                style: TextStyle(color: onSurface.withValues(alpha: 0.54)),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _trackedApps.length,
              itemBuilder: (context, index) {
                final app = _trackedApps[index];
                final usageTodayMins = _usageMap[app.appId] ?? 0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppElementSizes.spacingSm),
                  child: AppUsageCard(
                    appUsage: app,
                    usageTodayMins: usageTodayMins,
                    iconBytes: _iconMap[app.appId],
                    onUntrack: () => _untrackApp(app),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

