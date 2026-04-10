// File: lib/data/models/task.dart
// TODO: Implement Task Data Entity

//    - `Map<String, dynamic> toJson()` and `factory Task.fromJson(...)` for exports.
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'task.g.dart';

enum TaskPriority { low, medium, high, critical }

@collection
class TaskList {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String name;

  late List<String> tags = ['default'];
  
  // Store icon as codePoint for persistence
  late int iconCodePoint;
  
  // Prevent deletion of default list
  bool isDefault = false;
  
  // Helper to get Icon from codePoint (computed, not stored in DB)
  @ignore
  Icon get icon => Icon(IconData(iconCodePoint));

  @Backlink(to: 'taskList')
  final tasks = IsarLinks<Task>(); // one to many relation

  TaskList();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tags': tags,
      'iconCodePoint': iconCodePoint,
      'isDefault': isDefault,
    };
  }

  factory TaskList.fromJson(Map<String, dynamic> json) {
    return TaskList()
      ..id = json['id'] ?? Isar.autoIncrement
      ..name = json['name']
      ..tags = (json['tags'] as List?)?.map((e) => e as String).toList() ?? ['default']
      ..iconCodePoint = json['iconCodePoint'] ?? Icons.list.codePoint
      ..isDefault = json['isDefault'] ?? false;
  }
}

@collection
class Task {
  Task();

  Id id = Isar.autoIncrement;

  late String title;
  
  final taskList = IsarLink<TaskList>();
  
  String? description;

  @enumerated
  late TaskPriority priority;

  DateTime? startTime; // if !null - Particular time
  DateTime? endTime; // if !null - In range
  List<int>? days;
  // if !null - Regular interval: 1 Saturday 2 Sunday 3 Monday ... 7 Friday

  late DateTime creationTime;
  DateTime? completionTime;
  // if days != null, will reset everyday. preferably next launch of app.

  bool isArchived = false;
  bool isCompleted = false; // will reset if days != null, preferably on next launch of app.

  // Helper to calculate urgency score (for "due soon" sorting)
  // Returns duration until task is due, or null if no time set
  @ignore
  Duration? get urgencyScore {
    final now = DateTime.now();
    
    if (days != null) {
      // Regular interval: find next occurrence
      final today = now.weekday; // 1 = Monday, 7 = Sunday
      
      for (int i = 0; i < 7; i++) {
        final checkDay = (today + i - 1) % 7 + 1; // Convert to 1-7 (Mon-Sun)
        if (days!.contains(checkDay)) {
          var nextOccurrence = DateTime(now.year, now.month, now.day + i);
          if (startTime != null) {
            nextOccurrence = DateTime(
              nextOccurrence.year,
              nextOccurrence.month,
              nextOccurrence.day,
              startTime!.hour,
              startTime!.minute,
            );
          }
          return nextOccurrence.difference(now);
        }
      }
      return null; // No matching day found
    }
    
    if (startTime != null) {
      // One-time task with specific time
      return startTime!.difference(now);
    }
    
    return null; // No time-based info
  }

  // Priority numeric value (higher = more important)
  @ignore
  int get priorityValue {
    switch (priority) {
      case TaskPriority.critical:
        return 4;
      case TaskPriority.high:
        return 3;
      case TaskPriority.medium:
        return 2;
      case TaskPriority.low:
        return 1;
    }
  }

  Task.make({
    required this.title,
    required TaskList taskList,
    required this.priority,
    required this.creationTime,
    this.description,
    this.startTime,
    this.endTime,
    this.days,
    this.isCompleted = false,
  }) {
    this.taskList.value = taskList;
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task()
      ..id = json['id'] ?? Isar.autoIncrement
      ..title = json['title']
      ..description = json['description']
      ..startTime = json['start_time'] != null
          ? DateTime.parse(json['start_time'])
          : null
      ..endTime = json['end_time'] != null
          ? DateTime.parse(json['end_time'])
          : null
      ..days = (json['days'] as List?)?.map((e) => e as int).toList()
      ..creationTime = json['creation_time'] != null
          ? DateTime.parse(json['creation_time'])
          : DateTime.now()
      ..completionTime = json['completion_time'] != null
          ? DateTime.parse(json['completion_time'])
          : null
      ..priority = TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.medium,
      )
      ..isCompleted = json['is_completed'] ?? false;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'taskListId': taskList.value?.id,
      'description': description,
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'days': days,
      'creation_time': creationTime.toIso8601String(),
      'completion_time': completionTime?.toIso8601String(),
      'priority': priority.name,
      'is_completed': isCompleted,
    };
  }
}
