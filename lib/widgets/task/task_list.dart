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
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../data/models/task.dart';
import 'task_card.dart';
import 'grouped_task_card.dart';

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

  // Whether to use Keep-style grouped view
  final bool useGroupedView;

  const TaskListView({
    super.key,
    required this.incompleteTasks,
    required this.completedTasks,
    required this.onEditTask,
    this.onTaskChanged,
    this.useGroupedView = true,
  });

  Map<TaskPriority, List<Task>> _groupTasksByPriority(List<Task> tasks) {
    final Map<TaskPriority, List<Task>> groups = {};
    for (final task in tasks) {
      if (!groups.containsKey(task.priority)) {
        groups[task.priority] = [];
      }
      groups[task.priority]!.add(task);
    }
    return groups;
  }

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

    final hasCompletedTasks = completedTasks.isNotEmpty;

    // Build task grid with Google Keep style staggered cards
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Incomplete tasks staggered grid
          if (useGroupedView)
            _buildGroupedView(context)
          else
            _buildSingleTaskView(context),
          
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
            _buildSingleTaskView(context, tasks: completedTasks),
        ],
      ),
    );
  }

  Widget _buildGroupedView(BuildContext context) {
    final groups = _groupTasksByPriority(incompleteTasks);
    final sortedPriorities = TaskPriority.values.reversed; // Highest first

    return MasonryGridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final priority = sortedPriorities.elementAt(index);
        final tasks = groups[priority];
        
        if (tasks == null || tasks.isEmpty) return const SizedBox.shrink();
        
        return GroupedTaskCard(
          tasks: tasks,
          priority: priority,
          onEditTask: onEditTask,
          onTaskChanged: onTaskChanged,
        );
      },
    );
  }

  Widget _buildSingleTaskView(BuildContext context, {List<Task>? tasks}) {
    final displayTasks = tasks ?? incompleteTasks;

    return MasonryGridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      itemCount: displayTasks.length,
      itemBuilder: (context, index) {
        final task = displayTasks[index];
        return TaskCard(
          task: task,
          onEdit: () => onEditTask(task),
          onTaskChanged: onTaskChanged,
        );
      },
    );
  }
}
