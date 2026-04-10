import 'package:flutter/material.dart';

import '../data/db/isar_service.dart';
import '../data/models/user_settings.dart';

final Map<String, ThemeData> themes = {
  'Purple Light': ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFFA666CC),
    scaffoldBackgroundColor: const Color(0xFFEADCF2),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF8D47B3),
      secondary: Color(0xFFA666CC),
      surface: Color(0xFFF9F2FF),
    ),
  ),
  'Purple Dark': ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF7D4D99),
    scaffoldBackgroundColor: const Color(0xFF1B121A),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF783D99),
      secondary: Color(0xFF915AB3),
      surface: Color(0xFF261F29),
    ),
  ),
  'Green Light': ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF66CC66),
    scaffoldBackgroundColor: const Color(0xFFDCF2DC),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF47B347),
      secondary: Color(0xFF66CC66),
      surface: Color(0xFFF2FFF2),
    ),
  ),
  'Green Dark': ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF4D994D),
    scaffoldBackgroundColor: const Color(0xFF121A12),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF3D993D),
      secondary: Color(0xFF5AB35A),
      surface: Color(0xFF1F291F),
    ),
  ),
};

class ThemeController extends ChangeNotifier {
  String _currentThemeKey = 'Purple Light';
  bool _initialized = false;

  String get currentThemeKey => _currentThemeKey;
  ThemeData get currentTheme => themes[_currentThemeKey] ?? themes['Purple Light']!;
  bool get isInitialized => _initialized;

  ThemeController() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      var settingsConfig = await idb.userSettings.get(1);
      if (settingsConfig != null) {
        if (themes.containsKey(settingsConfig.themeMode)) {
          _currentThemeKey = settingsConfig.themeMode;
        }
      }
    } catch(e) {}
    _initialized = true;
    notifyListeners();
  }

  Future<void> setTheme(String themeKey) async {
    if (themes.containsKey(themeKey) && _currentThemeKey != themeKey) {
      _currentThemeKey = themeKey;
      notifyListeners();

      var settingsConfig = await idb.userSettings.get(1);
      if (settingsConfig != null) {
        settingsConfig.themeMode = themeKey;
      } else {
        settingsConfig = UserSettings()..id = 1..themeMode = themeKey;
      }

      await idb.writeTxn(() async {
        await idb.userSettings.put(settingsConfig!);
      });
    }
  }
}

final ThemeController themeController = ThemeController();

