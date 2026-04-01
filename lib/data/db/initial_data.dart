// File: lib/data/db/initial_data.dart
// Initial Data Setup for Isar Database
//
// This file contains all functions for creating default data in the database.
// Called automatically during IsarService initialization.

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import '../models/task.dart';
import 'isar_service.dart';

/// Creates the default task list and sample tasks if they don't exist.
/// Called automatically during IsarService init().
Future<void> prepareDefaultData() async {
  // Check if default list already exists
  final existingDefault = await idb.taskLists.filter().nameEqualTo('Default').findFirst();
  
  if (existingDefault != null) return;

  await idb.writeTxn(() async {
    // Create default list
    final defaultList = TaskList()
      ..name = 'Default'
      ..iconCodePoint = Icons.list.codePoint
      ..isDefault = true;
    await idb.taskLists.put(defaultList);

    // Sample task 1: Low priority, no time
    final task1 = Task()
      ..title = 'Read a book chapter'
      ..description = 'Finish chapter 5 of the current book'
      ..priority = TaskPriority.low
      ..creationTime = DateTime.now()
      ..isCompleted = false
      ..isArchived = false;
    task1.taskList.value = defaultList;
    await idb.tasks.put(task1);
    await task1.taskList.save();

    // Sample task 2: Medium priority with time range
    final task2 = Task()
      ..title = 'Team meeting'
      ..description = 'Weekly sync with the team'
      ..priority = TaskPriority.medium
      ..startTime = DateTime.now().copyWith(hour: 10, minute: 0)
      ..endTime = DateTime.now().copyWith(hour: 11, minute: 0)
      ..creationTime = DateTime.now()
      ..isCompleted = false
      ..isArchived = false;
    task2.taskList.value = defaultList;
    await idb.tasks.put(task2);
    await task2.taskList.save();

    // Sample task 3: High priority, critical
    final task3 = Task()
      ..title = 'Submit project report'
      ..description = 'Final report for Q4 deliverables'
      ..priority = TaskPriority.high
      ..startTime = DateTime.now().copyWith(hour: 17, minute: 0)
      ..creationTime = DateTime.now()
      ..isCompleted = false
      ..isArchived = false;
    task3.taskList.value = defaultList;
    await idb.tasks.put(task3);
    await task3.taskList.save();

    // Sample task 4: Critical priority, recurring Mon/Wed/Fri
    final task4 = Task()
      ..title = 'Daily standup'
      ..description = 'Quick status update'
      ..priority = TaskPriority.critical
      ..startTime = DateTime.now().copyWith(hour: 9, minute: 30)
      ..days = [1, 3, 5] // Mon, Wed, Fri
      ..creationTime = DateTime.now()
      ..isCompleted = false
      ..isArchived = false;
    task4.taskList.value = defaultList;
    await idb.tasks.put(task4);
    await task4.taskList.save();

    // Sample task 5: Completed task
    final task5 = Task()
      ..title = 'Setup development environment'
      ..description = 'Install all required tools'
      ..priority = TaskPriority.medium
      ..creationTime = DateTime.now().subtract(const Duration(days: 2))
      ..completionTime = DateTime.now().subtract(const Duration(days: 1))
      ..isCompleted = true
      ..isArchived = false;
    task5.taskList.value = defaultList;
    await idb.tasks.put(task5);
    await task5.taskList.save();
  });
}
