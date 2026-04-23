// File: lib/data/models/user_settings.dart
// TODO: Implement Preferences Entity
// Architecture: Can be an Isar model (since there's ideally only 1 row) OR handled via SharedPrefs wrapping.
// If using Isar `@collection class UserSettings`:
// Requirements:
// 1. Fields:
//    - `Id id = 1;`
//    - `String? pinHash;` (Stored safely via SHA-256) (FR-02, NFR-11).
//    - `String? salt;`
//    - `String themeMode = 'system';`
//    - `String preferredChallengeType = 'math';` (FR-27)
//    - `bool strictModeEnabled = false;`
//    - `List<String> blockedPackages = [];`
//    - `bool notificationsEnabled = true;`
import 'package:isar/isar.dart'; // TODO use shared prefs for user settings.
import 'app_usage.dart';

part 'user_settings.g.dart';

@collection
class UserSettings {
  Id id = 1;

  String? pinHash;
  String? salt;

  String themeMode = 'Purple Light';
  String preferredChallengeType = 'Math';
  int defaultOvertimeLimitMinutes = 15;
  int warningSecondsBeforeIntercept = 10;

  bool strictModeEnabled = false;
  bool gyroscopeGlassLightingEnabled = false;
  List<String> blockedPackages = [];

  bool notificationsEnabled = true;

  @Backlink(to: 'user')
  final appUsages = IsarLinks<AppUsage>();
}
