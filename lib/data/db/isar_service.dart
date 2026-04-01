// File: lib/data/db/isar_service.dart
// Isar Database Service
//
// Manages the local Isar database lifecycle.
// Call IsarService().init() before any database operations.
// The global `idb` getter provides access to the initialized database.

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/task.dart';
import '../models/flash_card.dart';
import '../models/user_settings.dart';
import 'initial_data.dart';

/// The global database instance. Call IsarService().init() before accessing.
late final Isar idb;

/// IsarService manages the local Isar database lifecycle.
/// Call init() before any database operations.
class IsarService {
  static final IsarService _instance = IsarService._internal();

  factory IsarService() {
    return _instance;
  }

  IsarService._internal();

  /// Initialize the database and create default data.
  /// Must be called before any database operations.
  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();

    idb = await Isar.open(
      [
        TaskSchema,
        TaskListSchema,
        FlashCardSchema,
        UserSettingsSchema,
      ],
      directory: dir.path,
    );

    await prepareDefaultData();
  }
}
