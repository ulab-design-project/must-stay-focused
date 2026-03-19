// File: lib/data/models/task.dart
// TODO: Implement Task Data Entity
// Architecture: Isar annotated Model class.
// Requirements:
// 1. Enums: 
//    - `enum TaskPriority { low, medium, high, critical }` (FR-13).
//    - `enum TaskCategory { essentials, work, study, personal }` (FR-14).
// 2. `@collection class Task`:
//    - `Id id = Isar.autoIncrement;`
//    - `String title;`
//    - `String? description;`
//    - `DateTime? dueDate;`
//    - `DateTime? time;`
//    - `@enumerated TaskPriority priority;`
//    - `@enumerated TaskCategory category;`
//    - `bool isCompleted = false;`
// 3. Methods:
//    - `Map<String, dynamic> toJson()` and `factory Task.fromJson(...)` for exports.
