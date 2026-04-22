import 'package:flutter/material.dart';

import '../data/db/isar_service.dart';
import '../data/models/user_settings.dart';

/// Application theme definitions - Light and Dark variants for Purple and Green color schemes.
final Map<String, ThemeData> themes = {
  'Purple Light': ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFFA666CC),
    scaffoldBackgroundColor: const Color(0xFFEADCF2),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF8D47B3),
      secondary: Color(0xFFA666CC),
      surface: Color(0xFFF9F2FF),
      onSurface: Color(0xFF2A1E34),
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
      onSurface: Color(0xFFE9D8F5),
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
      onSurface: Color(0xFF17311A),
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
      onSurface: Color(0xFFD7F0D7),
    ),
  ),
  'Blue Light': ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF66ACFF),
    scaffoldBackgroundColor: const Color(0xFFDCEBFF),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF4285F4),
      secondary: Color(0xFF66ACFF),
      surface: Color(0xFFF0F7FF),
      onSurface: Color(0xFF0D1B2A),
    ),
  ),
  'Blue Dark': ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF4A7ED9),
    scaffoldBackgroundColor: const Color(0xFF0D1525),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF3B6BCF),
      secondary: Color(0xFF5A8CE5),
      surface: Color(0xFF162036),
      onSurface: Color(0xFFD8E6FF),
    ),
  ),
  'Red Light': ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFFFF8A80),
    scaffoldBackgroundColor: const Color(0xFFFFEBEE),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFEA4335),
      secondary: Color(0xFFFF8A80),
      surface: Color(0xFFFFF5F5),
      onSurface: Color(0xFF2A1215),
    ),
  ),
 
  'Orange Dark': ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFFF9A825),
    scaffoldBackgroundColor: const Color(0xFF1A1500),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFF57F17),
      secondary: Color(0xFFFFB300),
      surface: Color(0xFF261E00),
      onSurface: Color(0xFFFFF8E1),
    ),
  ),
};

/// Text size constants used throughout the app.
class AppTextSizes {
  static const double h1 = 28;
  static const double h2 = 24;
  static const double h3 = 20;
  static const double title = 18;
  static const double body = 16;
  static const double small = 14;
  static const double compact = 10;
  static const double error = 13;
  static const double unavailable = 12;
}

/// Element size constants used throughout the app.
class AppElementSizes {
  static const double buttonSquare = 40;
  static const double buttonHeight = 40;
  static const double icon = 20;
  static const double cardRadius = 12;
  static const double inputHeight = 40;
  static const double tileHeight = 44;
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 12;
  static const double spacingLg = 16;
}

/// Glass effect constants.
class GlassEffects {
  /// Opacity for glass card backgrounds (0.5 as specified)
  static const double opacity = 0.5;

  /// Opacity for glass stroke/border (0.3 as specified)
  static const double strokeOpacity = 0.3;

  /// Blur radius not used directly (laggy), kept for reference
  static const double blurSigma = 60.0;

  /// Corner radius for glass elements
  static final double radius = AppElementSizes.cardRadius;

  /// Glow intensity on hover
  static const double glowIntensity = 0.15;

  /// Stroke width for glass border
  static const double strokeWidth = 1.0;
}

/// Controller for managing theme changes and gyroscope settings.
class ThemeController extends ChangeNotifier {
  String _currentThemeKey = 'Purple Light';
  bool _initialized = false;

  ThemeController() {
    _loadTheme();
  }

  String get currentThemeKey => _currentThemeKey;
  ThemeData get currentTheme =>
      themes[_currentThemeKey] ?? themes['Purple Light']!;
  bool get isInitialized => _initialized;

  Future<void> _loadTheme() async {
    try {
      var settingsConfig = await idb.userSettings.get(1);
      if (settingsConfig != null &&
          themes.containsKey(settingsConfig.themeMode)) {
        _currentThemeKey = settingsConfig.themeMode;
      }
    } catch (e, stackTrace) {
      debugPrint('ThemeController load error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> setTheme(String themeKey) async {
    if (themes.containsKey(themeKey) && _currentThemeKey != themeKey) {
      _currentThemeKey = themeKey;
      notifyListeners();

      try {
        var settingsConfig = await idb.userSettings.get(1);
        if (settingsConfig != null) {
          settingsConfig.themeMode = themeKey;
        } else {
          settingsConfig = UserSettings()
            ..id = 1
            ..themeMode = themeKey;
        }
        await idb.writeTxn(() async {
          await idb.userSettings.put(settingsConfig!);
        });
      } catch (e, stackTrace) {
        debugPrint('ThemeController setTheme error: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }
}

final ThemeController themeController = ThemeController();
