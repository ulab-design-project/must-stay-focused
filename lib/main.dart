import 'package:flutter/material.dart';

import 'data/db/isar_service.dart';
import 'pages/home/home.dart';
import 'style/theme.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'api_test_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
  url: 'https://ejiurgqvgdbdtwsvwaib.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVqaXVyZ3F2Z2RiZHR3c3Z3YWliIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE4NjI0NjAsImV4cCI6MjA4NzQzODQ2MH0.s0iUa_QF9XYL00KK5_lFlLtCU4g_T3_Qibmpq1m_LUM',
);

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
          home: ApiTestPage(),
        );
      }
    );
  }
}
