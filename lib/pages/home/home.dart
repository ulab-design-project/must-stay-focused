import 'package:flutter/material.dart';

import 'tasks.dart';
import '../../style/buttons.dart';
import '../../style/background.dart';
import '../settings.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundDrop(
      scaffold: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Tasks'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: GlassSquircleIconButton(
                icon: const Icon(Icons.store),
                onPressed: () {
                  // TODO: Navigate to community template store
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: GlassSquircleIconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Stack(children: [TasksPage()]),
      ),
    );
  }
}
