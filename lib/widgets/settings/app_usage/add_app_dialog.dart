import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:isar/isar.dart';
import 'package:liquid_glass_widgets/widgets/input/glass_text_field.dart';
import 'package:liquid_glass_widgets/widgets/overlays/glass_dialog.dart';
import 'package:must_stay_focused/data/db/isar_service.dart';
import 'package:must_stay_focused/data/models/app_usage.dart';
import 'package:must_stay_focused/services/appUsageMonitor/android_app_usage.dart';
import 'package:must_stay_focused/style/theme.dart';

class AddAppDialog extends StatefulWidget {
  const AddAppDialog({super.key});

  @override
  State<AddAppDialog> createState() => _AddAppDialogState();
}

class _AddAppDialogState extends State<AddAppDialog> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<AppInfo> _allApps = [];
  List<AppInfo> _filteredApps = [];
  Set<String> _existingAppIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearch);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final existing = await idb.appUsages.where().findAll();
      final existingIds = existing.map((e) => e.appId).toSet();

      // Retrieve installed apps
      final allAppsRaw = await AndroidAppUsageMonitor().getInstalledApps();
      
      // Exclude must_stay_focused from the allowed apps to track
      final apps = allAppsRaw.where((app) {
        final pkg = app.packageName.toLowerCase();
        return !pkg.contains('must_stay_focused') && !pkg.contains('muststayfocused');
      }).toList();

      if (mounted) {
        setState(() {
          _allApps = apps;
          _filteredApps = apps;
          _existingAppIds = existingIds;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSearch() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      _filteredApps = _allApps.where((app) {
        return app.name.toLowerCase().contains(query) ||
               app.packageName.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _toggleAppTrack(AppInfo app, bool track) async {
    if (track) {
      final usage = AppUsage()
        ..name = app.name
        ..appId = app.packageName
        ..maxDailyTimeLimit = 15
        ..isTracked = true;

      await idb.writeTxn(() async {
        await idb.appUsages.put(usage);
      });
      if (mounted) setState(() { _existingAppIds.add(app.packageName); });
    } else {
      final existing = await idb.appUsages.where().appIdEqualTo(app.packageName).findFirst();
      if (existing != null) {
        await idb.writeTxn(() async {
          await idb.appUsages.delete(existing.id);
        });
      }
      if (mounted) setState(() { _existingAppIds.remove(app.packageName); });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassDialog(
      title: "Select an App",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GlassTextField(
            controller: _searchCtrl,
            placeholder: "Search apps...",
            prefixIcon: const Icon(Icons.search, color: Colors.white54),
          ),
          const SizedBox(height: AppElementSizes.spacingLg),
          if (_isLoading)
            const CircularProgressIndicator()
          else
            SizedBox(
              height: 300,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredApps.length,
                itemBuilder: (context, index) {
                  final app = _filteredApps[index];
                  final isTracked = _existingAppIds.contains(app.packageName);
                  return CheckboxListTile(
                    activeColor: Theme.of(context).colorScheme.primary,
                    checkColor: Colors.white,
                    secondary: SizedBox(
                      width: AppElementSizes.buttonSquare,
                      height: AppElementSizes.buttonSquare,
                      child: app.icon != null
                          ? Image.memory(app.icon!)
                          : const Icon(Icons.android, color: Colors.white),
                    ),
                    title: Text(
                      app.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      app.packageName,
                      style: const TextStyle(fontSize: 10, color: Colors.white70),
                    ),
                    value: isTracked,
                    onChanged: (val) {
                      if (val != null) _toggleAppTrack(app, val);
                    },
                  );
                },
              ),
            ),
          const SizedBox(height: AppElementSizes.spacingLg),
        ],
      ),
      actions: [
        GlassDialogAction(
          label: "Close",
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

