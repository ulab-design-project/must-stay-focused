// File: lib/widgets/task/task_card.dart
// Reusable Task Card Item with swipe actions
//
// Requirements:
// 1. class TaskCard extends StatelessWidget:
//    - Properties: final Task task, final VoidCallback onEdit, final VoidCallback? onTaskChanged
//    - UI:
//      - Checkbox leading icon for quick complete toggle.
//      - Title and time/description as subtitle.
//      - Priority indicator with color-coded trailing badge.
//      - Swipe left to move to Archived list, swipe right to delete with confirmation.
//    - All DB operations via global taskRepo instance.
//    - Logging for all operations.

import 'package:flutter/material.dart';

import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';
import '../../utils/logging.dart';

/// A swipeable card widget representing a single task.
/// Provides quick actions: toggle complete, move to Archived (swipe left), delete (swipe right).
/// All database operations are performed via the global taskRepo instance.
class TaskCard extends StatelessWidget {
  // The task data to display
  final Task task;
  
  // Callback fired when the card body is tapped (opens edit dialog)
  final VoidCallback onEdit;
  
  // Callback fired when task is modified (for parent to refresh list)
  final VoidCallback? onTaskChanged;

  const TaskCard({
    super.key,
    required this.task,
    required this.onEdit,
    this.onTaskChanged,
  });

  /// Returns the background color based on task priority.
  Color _getPriorityColor() {
    switch (task.priority) {
      case TaskPriority.critical:
        return Colors.red.shade100;
      case TaskPriority.high:
        return Colors.orange.shade100;
      case TaskPriority.medium:
        return Colors.blue.shade100;
      case TaskPriority.low:
        return Colors.grey.shade200;
    }
  }

  /// Toggles the task completion status and updates via repository.
  Future<void> _toggleComplete(BuildContext context) async {
    try {
      task.isCompleted = !task.isCompleted;
      task.completionTime = task.isCompleted ? DateTime.now() : null;
      await taskRepo.upsertTask(task);
      await logger(
        LogLevel.info,
        'Task toggled: ${task.title}',
        source: 'task_card.dart',
      );
      onTaskChanged?.call();
    } catch (e) {
      await logger(
        LogLevel.error,
        'Failed to toggle task: $e',
        source: 'task_card.dart',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  /// Toggles the task archived status and updates via repository.
  Future<void> _toggleArchive(BuildContext context) async {
    try {
      task.isArchived = !task.isArchived;
      await taskRepo.upsertTask(task);
      await logger(
        LogLevel.info,
        'Task archived: ${task.title}',
        source: 'task_card.dart',
      );
      onTaskChanged?.call();
    } catch (e) {
      await logger(
        LogLevel.error,
        'Failed to archive task: $e',
        source: 'task_card.dart',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  /// Deletes the task from the database via repository.
  Future<void> _delete(BuildContext context) async {
    try {
      await taskRepo.deleteTask(task.id);
      await logger(
        LogLevel.info,
        'Task deleted: ${task.title}',
        source: 'task_card.dart',
      );
    } catch (e) {
      await logger(
        LogLevel.error,
        'Failed to delete task: $e',
        source: 'task_card.dart',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  /// Formats a DateTime to HH:MM string.
  String _formatTime(DateTime time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        // Swipe left (endToStart) = toggle archive
        if (direction == DismissDirection.endToStart) {
          await _toggleArchive(context);
          return true;
        } else {
          // Swipe right (startToEnd) = delete with confirmation
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Delete Task'),
              content: const Text(
                'Are you sure you want to delete this task?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
          if (confirm == true && context.mounted) {
            await _delete(context);
          }
          return confirm;
        }
      },
      // Background for swipe right (delete)
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      // Background for swipe left (move to Archived)
      secondaryBackground: Container(
        color: Colors.orange,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.archive, color: Colors.white),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          // Checkbox with its own tap handling - stops propagation to ListTile
          leading: GestureDetector(
            onTap: () => _toggleComplete(context),
            child: Checkbox(
              value: task.isCompleted,
              onChanged: null, // null because we handle tap on GestureDetector
            ),
          ),
          title: Text(task.title),
          subtitle: Text(
            task.startTime != null
                ? '${_formatTime(task.startTime!)}${task.endTime != null ? ' - ${_formatTime(task.endTime!)}' : ''}'
                : (task.description ?? ''),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getPriorityColor(),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              task.priority.name,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          onTap: onEdit,
        ),
      ),
    );
  }
}
