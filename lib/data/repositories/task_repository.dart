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
