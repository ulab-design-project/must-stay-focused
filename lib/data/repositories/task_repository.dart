// File: lib/data/repositories/task_repository.dart
// Task Data Access Layer
//
// This repository provides all methods for interacting with the Isar database
// for Task and TaskList entities. Widgets should NEVER call `idb` directly.
// Instead, inject this repository and use its methods.
//
// Methods:
// - upsertTask(Task): Insert or update a task
// - deleteTask(int id): Delete a task by ID
// - watchTasks(): Stream of all tasks
// - getInterceptionTasks(): Get incomplete tasks sorted by priority
// - getTaskLists(): Get all task lists
// - getTasksByListName(String): Get tasks for a specific list
// - getFilteredTasks(String, String?, {bool}): Get filtered/sorted tasks
// - upsertTaskList(TaskList): Insert or update a task list
// - deleteTaskList(TaskList, {bool}): Delete a task list with optional merge

import 'package:isar/isar.dart';
import '../db/isar_service.dart';
import '../models/task.dart';

final IsarTaskRepository taskRepo = IsarTaskRepository(); // global taskRepo

/// Repository for all Task and TaskList database operations.
/// Use this class instead of calling idb directly.

class IsarTaskRepository {
  // Upsert: Insert if new (no ID), Update if exists (has ID)
  Future<int> upsertTask(Task task) async {
    return await idb.writeTxn(() async {
      final id = await idb.tasks.put(task);
      await task.taskList.save();
      return id;
    });
  }

  Future<void> deleteTask(int id) async {
    await idb.writeTxn(() async {
      await idb.tasks.delete(id);
    });
  }

  Stream<List<Task>> watchTasks() {
    return idb.tasks.where().watch(fireImmediately: true);
  }

  Future<List<Task>> getInterceptionTasks() async {
    return await idb.tasks
        .filter()
        .isCompletedEqualTo(false)
        .sortByPriorityDesc()
        .findAll();
  }

  Future<List<TaskList>> getTaskLists() async {
    return await idb.taskLists.where().findAll();
  }

  Stream<List<TaskList>> watchTaskLists() {
    return idb.taskLists.where().watch(fireImmediately: true);
  }

  Future<List<Task>> getTasksByListName(String listName) async {
    final taskList = await idb.taskLists
        .filter()
        .nameEqualTo(listName)
        .findFirst();
    if (taskList == null) return [];
    await taskList.tasks.load();
    return taskList.tasks.toList();
  }

  // Get filtered and sorted tasks
  // listName: name of the task list to filter by (ignored if isArchived is true)
  // sortBy: 'priority', 'dueSoon', or 'creationTime'
  // isAscending: true = A->Z, false = Z->A
  // isArchived: if true, returns archived tasks ignoring listName; if false, returns non-archived tasks from listName
  // isCompleted: if null, returns all tasks; if true/false, filters by completion
  Future<List<Task>> getFilteredTasks(
    String listName,
    String? sortBy, {
    bool isAscending = true,
    bool? isCompleted,
    bool isArchived = false,
  }) async {
    List<Task> tasks;

    // Step 1: Filter by archive status
    if (isArchived) {
      // Get all archived tasks directly from the tasks collection
      tasks = await idb.tasks.filter().isArchivedEqualTo(true).findAll();
    } else {
      // Get tasks from specific list that are not archived
      final taskList = await idb.taskLists
          .filter()
          .nameEqualTo(listName)
          .findFirst();
      if (taskList == null) return [];
      await taskList.tasks.load();
      tasks = taskList.tasks.where((t) => !t.isArchived).toList();
    }

    // Step 2: Filter by completion status if specified
    if (isCompleted != null) {
      tasks = tasks.where((t) => t.isCompleted == isCompleted).toList();
    }

    // Step 3: Sort based on sortBy parameter
    switch (sortBy) {
      case 'priority':
        tasks.sort((a, b) {
          final comparison = a.priorityValue.compareTo(b.priorityValue);
          return isAscending ? comparison : -comparison;
        });
        break;

      case 'dueSoon':
        tasks.sort((a, b) {
          final aUrgency = a.urgencyScore;
          final bUrgency = b.urgencyScore;

          // Handle null cases: tasks with no time go to end
          if (aUrgency == null && bUrgency == null) return 0;
          if (aUrgency == null) return 1;
          if (bUrgency == null) return -1;

          final comparison = aUrgency.compareTo(bUrgency);
          return isAscending ? comparison : -comparison;
        });
        break;

      case 'creationTime':
      default:
        tasks.sort((a, b) {
          final comparison = a.creationTime.compareTo(b.creationTime);
          return isAscending ? comparison : -comparison;
        });
        break;
    }

    return tasks;
  }

  // Upsert TaskList
  Future<void> upsertTaskList(TaskList list) async {
    await idb.writeTxn(() async {
      await idb.taskLists.put(list);
    });
  }

  // Delete TaskList with optional merge to default
  Future<void> deleteTaskList(
    TaskList list, {
    bool mergeToDefault = false,
  }) async {
    if (list.isDefault) {
      throw Exception('Cannot delete default list');
    }

    if (mergeToDefault) {
      await idb.writeTxn(() async {
        await list.tasks.load();
        final defaultList = await idb.taskLists
            .filter()
            .isDefaultEqualTo(true)
            .findFirst();
        if (defaultList != null) {
          for (final task in list.tasks) {
            task.taskList.value = defaultList;
            await idb.tasks.put(task);
            await task.taskList.save();
          }
        }
        await idb.taskLists.delete(list.id);
      });
    } else {
      await idb.writeTxn(() async {
        await idb.taskLists.delete(list.id);
      });
    }
  }
}
