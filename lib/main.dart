// File: lib/main.dart
// Application Entry Point
//
// Initializes the database before running the app.

import 'package:flutter/material.dart';

import 'data/db/isar_service.dart';
import 'pages/home/home.dart';

void main() async {
  // Ensure Flutter bindings are initialized before async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database before running the app
  await IsarService().init();

  runApp(const MSF());
}

class MSF extends StatelessWidget {
  const MSF({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Must Stay Focused',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Home(),
    );
  }
}
