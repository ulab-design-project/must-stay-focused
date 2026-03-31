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
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/task.dart';
import '../models/flash_card.dart';
import '../models/user_settings.dart';

final Isar idb = IsarService().db; // global singleton

class IsarService {
  static final IsarService _instance = IsarService._internal();

  late Isar db;

  factory IsarService() {
    return _instance;
  }

  IsarService._internal();

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();

    db = await Isar.open([
      TaskSchema,
      TaskListSchema,
      FlashCardSchema,
      UserSettingsSchema,
    ], directory: dir.path);
  }
}
