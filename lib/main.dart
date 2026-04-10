import 'package:flutter/material.dart';

import 'data/db/isar_service.dart';
import 'pages/home/home.dart';
import 'style/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await IsarService().init();

  runApp(const MSF());
}

class MSF extends StatelessWidget {
  const MSF({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'Must Stay Focused',
          debugShowCheckedModeBanner: false,
          theme: themeController.currentTheme,
          home: const Home(),
        );
      }
    );
  }
}
