import 'package:flutter/material.dart';

import '../style/background.dart';
import '../widgets/settings/theme_picker.dart';

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
        body: const Column(
          children: [
            ThemePicker(),
          ],
        ),
      ),
    );
  }
}
