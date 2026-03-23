// File: lib/data/repositories/task_repository.dart
// TODO: Implement Task Data Access Layer
// Architecture: Define `abstract class ITaskRepository` and concrete `class IsarTaskRepository`.
// Requirements:
// 1. Methods:
//    - `Future<int> insertTask(Task task)` (FR-43 ensures instant save).
//    - `Future<void> updateTask(Task task)`.
//    - `Future<void> deleteTask(int id)`.
//    - `Stream<List<Task>> watchTasks()` to drive UI reactivity automatically.
//    - `Future<List<Task>> getInterceptionTasks()` queries only `isCompleted==false` ordered by `Priority` descending.
import 'package:isar/isar.dart';
import '../db/isar_service.dart';
import '../models/task.dart';

abstract class ITaskRepository
{
  Future<int> insertTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(int id);
  Stream<List<Task>> watchTasks();
  Future<List<Task>> getInterceptionTasks();
}

class IsarTaskRepository implements ITaskRepository
{
  final _isar = IsarService().db;

  @override
  Future<int> insertTask(Task task) async
  {
    return await _isar.writeTxn(() async {
      return await _isar.tasks.put(task);
    });
  }

  @override
  Future<void> updateTask(Task task) async
  {
    await _isar.writeTxn(() async {
      await _isar.tasks.put(task);
    });
  }

  @override
  Future<void> deleteTask(int id) async
  {
    await _isar.writeTxn(() async {
      await _isar.tasks.delete(id);
    });
  }

  @override
  Stream<List<Task>> watchTasks()
  {
    return _isar.tasks.where().watch(fireImmediately: true);
  }

  @override
  Future<List<Task>> getInterceptionTasks() async
  {
    return await _isar.tasks
        .filter()
        .isCompletedEqualTo(false)
        .sortByPriorityDesc()
        .findAll();
  }
}
