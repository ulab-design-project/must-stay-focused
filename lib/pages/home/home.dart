import 'package:flutter/material.dart';

import 'tasks.dart';
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
            IconButton(
              icon: const Icon(Icons.store),
              onPressed: () {
                // TODO: Navigate to community template store
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
          ],
        ),
        body: const Stack(children: [TasksPage()]),
      ),
    );
  }
}
