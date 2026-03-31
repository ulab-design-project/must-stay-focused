// File: lib/data/repositories/task_repository.dart
// TODO: Implement Task Data Access Layer

import 'package:isar/isar.dart';
import '../db/isar_service.dart';
import '../models/task.dart';

class IsarTaskRepository {
  // Upsert: Insert if new (no ID), Update if exists (has ID)
  Future<int> upsertTask(Task task) async {
    return await idb.writeTxn(() async {
      return await idb.tasks.put(task);
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

  Future<List<Task>> getTasksByListName(String listName) async {
    final taskList = await idb.taskLists.filter().nameEqualTo(listName).findFirst();
    if (taskList == null) return [];
    await taskList.tasks.load();
    return taskList.tasks.toList();
  }

  // Get filtered and sorted tasks
  // sortBy: 'priority', 'dueSoon', or 'creationTime'
  // isAscending: true = A->Z, false = Z->A
  Future<List<Task>> getFilteredTasks(String listName, String? sortBy, {bool isAscending = true}) async {
    // Step 1: Filter by listName
    final taskList = await idb.taskLists.filter().nameEqualTo(listName).findFirst();
    if (taskList == null) return [];
    
    await taskList.tasks.load();
    var tasks = taskList.tasks.where((t) => !t.isCompleted).toList();
    
    // Step 2: Sort based on sortBy parameter
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
}
