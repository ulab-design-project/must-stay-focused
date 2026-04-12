import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:sensors_plus/sensors_plus.dart';

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
};

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

class ThemeController extends ChangeNotifier {
  static const double _primaryBlendRatio = 0.4;

  String _currentThemeKey = 'Purple Dark';
  bool _isGyroscopeEnabled = false;
  bool _initialized = false;

  final double glassOpacity = 0.1;
  final double glassBlur = 50.0;

  String get currentThemeKey => _currentThemeKey;
  ThemeData get currentTheme =>
      themes[_currentThemeKey] ?? themes['Purple Light']!;
  bool get isGyroscopeEnabled => _isGyroscopeEnabled;
  bool get isInitialized => _initialized;

  Stream<double>? get gyroscopeLightAngleStream {
    if (!_isGyroscopeEnabled) {
      return null;
    }

    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return null;
    }

    try {
      return gyroscopeEventStream(samplingPeriod: SensorInterval.normalInterval)
          .map((event) {
            return event.y.clamp(-1.2, 1.2);
          })
          .handleError((Object error, StackTrace stackTrace) {
            debugPrint('ThemeController gyroscope stream error: $error');
            debugPrintStack(stackTrace: stackTrace);
          });
    } catch (e, stackTrace) {
      debugPrint('ThemeController gyroscope stream init error: $e');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  GlassThemeData get currentGlassTheme {
    final theme = currentTheme;
    final isDark = theme.brightness == Brightness.dark;
    final baseSettings =
        (isDark
            ? GlassThemeVariant.dark.settings
            : GlassThemeVariant.light.settings) ??
        const LiquidGlassSettings();
    final primaryTint = theme.colorScheme.primary.withValues(
      alpha: isDark ? 0.28 : 0.22,
    );

    final tintedSettings = baseSettings.copyWith(
      glassColor:
          Color.lerp(
            baseSettings.glassColor,
            primaryTint,
            _primaryBlendRatio,
          ) ??
          primaryTint,
      thickness: isDark ? 46 : 36,
      blur: isDark ? 12 : 10,
      lightIntensity: isDark ? 1.45 : 1.2,
      ambientStrength: isDark ? 0.34 : 0.26,
      saturation: 1.28,
      chromaticAberration: 0.8,
    );

    final variant = GlassThemeVariant(
      settings: tintedSettings,
      quality: GlassQuality.standard,
      glowColors: GlassGlowColors(primary: theme.colorScheme.primary),
    );

    return GlassThemeData(light: variant, dark: variant);
  }

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
        _isGyroscopeEnabled = settingsConfig.gyroscopeGlassLightingEnabled;
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

      var settingsConfig = await idb.userSettings.get(1);
      if (settingsConfig != null) {
        settingsConfig.themeMode = themeKey;
      } else {
        settingsConfig = UserSettings()
          ..id = 1
          ..themeMode = themeKey
          ..gyroscopeGlassLightingEnabled = _isGyroscopeEnabled;
      }

      await idb.writeTxn(() async {
        await idb.userSettings.put(settingsConfig!);
      });
    }
  }

  Future<void> setGyroscopeEnabled(bool enabled) async {
    if (_isGyroscopeEnabled == enabled) {
      return;
    }

    try {
      _isGyroscopeEnabled = enabled;
      notifyListeners();

      var settingsConfig = await idb.userSettings.get(1);
      if (settingsConfig != null) {
        settingsConfig.gyroscopeGlassLightingEnabled = enabled;
      } else {
        settingsConfig = UserSettings()
          ..id = 1
          ..themeMode = _currentThemeKey
          ..gyroscopeGlassLightingEnabled = enabled;
      }

      await idb.writeTxn(() async {
        await idb.userSettings.put(settingsConfig!);
      });
    } catch (e, stackTrace) {
      debugPrint('ThemeController setGyroscopeEnabled error: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }
}

final ThemeController themeController = ThemeController();
