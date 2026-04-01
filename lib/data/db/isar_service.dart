import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/task.dart';
import '../models/flash_card.dart';
import '../models/user_settings.dart';

final Isar idb = IsarService().db;

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

    // // Ensure default list exists
    // final existing = await db.taskLists.filter().isDefaultEqualTo(true).findFirst();
    // if (existing == null) {
    //   await db.writeTxn(() async {
    //     final defaultList = TaskList()
    //       ..name = 'Default'
    //       ..iconCodePoint = Icons.list.codePoint
    //       ..isDefault = true;
    //     await db.taskLists.put(defaultList);
    //   });
    // }
  }
}
