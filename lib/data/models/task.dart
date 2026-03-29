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
import 'package:isar/isar.dart';

part 'task.g.dart';

enum TaskPriority
{
  low,
  medium,
  high,
  critical
}

enum TaskCategory
{
  essentials,
  work,
  study,
  personal
}

@collection
class Task
{
  Task();

  Id id = Isar.autoIncrement;

  late String title;
  String? description;

  DateTime? dueDate;
  DateTime? time;

  @enumerated
  late TaskPriority priority;

  @enumerated
  late TaskCategory category;

  bool isCompleted = false;

  factory Task.fromJson(Map<String, dynamic> json)
  {
    return Task()
      ..id = json['id'] ?? Isar.autoIncrement
      ..title = json['title']
      ..description = json['description']
      ..dueDate = json['due_date'] != null ? DateTime.parse(json['due_date']) : null
      ..time = json['time'] != null ? DateTime.parse(json['time']) : null
      ..priority = TaskPriority.values.firstWhere((e) => e.name == json['priority'])
      ..category = TaskCategory.values.firstWhere((e) => e.name == json['category'])
      ..isCompleted = json['is_completed'];
  }

  Map<String, dynamic> toJson()
  {
    return {
      'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
      'time': time?.toIso8601String(),
      'priority': priority.name,
      'category': category.name,
      'is_completed': isCompleted,
    };
  }
}
