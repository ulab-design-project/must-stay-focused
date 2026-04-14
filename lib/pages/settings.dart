import 'package:flutter/material.dart';
import 'package:must_stay_focused/widgets/settings/permissions_tile.dart';

import '../style/background.dart';
import '../widgets/settings/theme_picker.dart';
import '../widgets/settings/app_usage/tracked_apps.dart';
import '../style/theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundDrop(
      scaffold: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppElementSizes.spacingLg),
            child: Column(
              children: [
                const ThemePicker(),
                const SizedBox(height: AppElementSizes.spacingLg * 1.5),
                PermissionsTile(),
                const SizedBox(height: AppElementSizes.spacingLg * 1.5),
                TrackedAppsWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
