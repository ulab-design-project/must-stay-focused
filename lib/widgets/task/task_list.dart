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
  final VoidCallback? onTaskChanged;

  const TaskListView({
    super.key,
    required this.incompleteTasks,
    required this.completedTasks,
    required this.onEditTask,
    this.onTaskChanged,
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
            Icon(Icons.task_alt, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              'No tasks yet',
              style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to add your first task',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
            ),
          ],
        ),
      );
    }

    // Calculate total items and positions
    // Structure: [incomplete tasks] + [optional header] + [completed tasks]
    final hasCompletedTasks = completedTasks.isNotEmpty;
    final totalItems = incompleteTasks.length + (hasCompletedTasks ? 1 : 0) + completedTasks.length;
    
    // Build task grid with Google Keep style cards
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Incomplete tasks grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: incompleteTasks.length,
            itemBuilder: (context, index) {
              final task = incompleteTasks[index];
              return TaskCard(
                task: task,
                onEdit: () => onEditTask(task),
                onTaskChanged: onTaskChanged,
              );
            },
          ),
          
          // Completed tasks header
          if (hasCompletedTasks)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Completed Tasks',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          
          // Completed tasks grid
          if (hasCompletedTasks)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: completedTasks.length,
              itemBuilder: (context, index) {
                final task = completedTasks[index];
                return TaskCard(
                  task: task,
                  onEdit: () => onEditTask(task),
                  onTaskChanged: onTaskChanged,
                );
              },
            ),
        ],
      ),
    );
  }
}
