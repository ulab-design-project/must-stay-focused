// File: lib/pages/home/home.dart
// Home Page with Task Management
//
// Requirements:
// 1. class Home extends StatelessWidget:
//    - AppBar with title and action buttons (store, settings).
//    - Body contains TasksPage for full task management.
//    - Uses global taskRepo for all task operations.

import 'package:flutter/material.dart';

import 'tasks.dart';

/// Main home page that displays tasks.
/// Contains an AppBar with store and settings actions.
/// The body is the TasksPage widget which handles all task management.
class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          // Store button placeholder
          IconButton(
            icon: const Icon(Icons.store),
            onPressed: () {
              // TODO: Navigate to community template store
            },
          ),
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings page
            },
          ),
        ],
      ),
      body: const TasksPage(),
    );
  }
}
