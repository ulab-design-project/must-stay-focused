// File: lib/widgets/task/task_list.dart
// Configurable Task ListView Widget
//
// Requirements:
// 1. class TaskListView extends StatelessWidget:
//    - Properties: final List<Task> incompleteTasks, final List<Task> completedTasks, final ValueChanged<Task> onEditTask, final VoidCallback? onTaskChanged
//    - Uses ListView.builder for efficient rendering.
//    - Each item wrapped with TaskCard for swipe actions.
//    - Shows incomplete tasks first, then "Completed Tasks" header, then completed tasks.
//    - Empty state handling when no tasks are present.
//    - All DB operations via global taskRepo instance.

import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../data/models/task.dart';
import 'task_card.dart';

/// A ListView widget that displays a list of tasks.
/// Shows incomplete tasks first, then a "Completed Tasks" header, then completed tasks.
/// Each task is rendered as a TaskCard with swipe actions.
class TaskListView extends StatelessWidget {
  // List of incomplete tasks to display first
  final List<Task> incompleteTasks;

  // List of completed tasks to display after the header
  final List<Task> completedTasks;

  // Callback fired when a task card is tapped for editing
  final ValueChanged<Task> onEditTask;

  // Callback fired when a task is modified (for parent to refresh list)
  final ValueChanged<Task>? onTaskChanged;

  // Task id that should play completed entry animation.
  final int? animatedCompletedTaskId;

  const TaskListView({
    super.key,
    required this.incompleteTasks,
    required this.completedTasks,
    required this.onEditTask,
    this.onTaskChanged,
    this.animatedCompletedTaskId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Show empty state if no tasks at all
    if (incompleteTasks.isEmpty && completedTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks yet',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to add your first task',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    // Calculate total items and positions
    // Structure: [incomplete tasks] + [optional header] + [completed tasks]
    final hasCompletedTasks = completedTasks.isNotEmpty;
    final totalItems =
        incompleteTasks.length +
        (hasCompletedTasks ? 1 : 0) +
        completedTasks.length;

    // Build task list with cards
    return LiquidGlassBlendGroup(
      child: ListView.builder(
        itemCount: totalItems,
        addRepaintBoundaries: true,
        itemBuilder: (context, index) {
          // First, show all incomplete tasks
          if (index < incompleteTasks.length) {
            final task = incompleteTasks[index];
            return TaskCard(
              key: ValueKey('incomplete-${task.id}'),
              task: task,
              onEdit: () => onEditTask(task),
              onTaskChanged: onTaskChanged,
            );
          }

          // Then, show "Completed Tasks" header if there are completed tasks
          final headerIndex = incompleteTasks.length;
          if (hasCompletedTasks && index == headerIndex) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Completed Tasks',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            );
          }

          // Finally, show completed tasks
          final completedIndex =
              index - (hasCompletedTasks ? headerIndex + 1 : headerIndex);
          final task = completedTasks[completedIndex];
          return TaskCard(
            key: ValueKey('completed-${task.id}'),
            task: task,
            onEdit: () => onEditTask(task),
            onTaskChanged: onTaskChanged,
            animateEntry: task.id == animatedCompletedTaskId,
          );
        },
      ),
    );
  }
}
