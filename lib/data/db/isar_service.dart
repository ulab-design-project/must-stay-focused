// File: lib/data/db/isar_service.dart
// TODO: Setup Local Database Configuration
// Architecture: Singleton wrapper or DI provider initializing Isar.
// Requirements:
// 1. `class IsarService`:
//    - Property: `late Isar db;`
//    - Method: `Future<void> init()`
//      - Calls `getApplicationDocumentsDirectory()`.
//      - Runs `Isar.open([TaskSchema, FlashCardSchema, DeckSchema, UserSettingsSchema])`.
//      - Setup fast write mechanisms (FR-42, NFR-18 ensures instant changes flush to disk).
