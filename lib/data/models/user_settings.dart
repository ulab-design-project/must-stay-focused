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
