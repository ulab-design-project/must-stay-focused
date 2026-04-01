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
    // Show empty state if no tasks at all
    if (incompleteTasks.isEmpty && completedTasks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.task_alt, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No tasks yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Tap + to add your first task',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Calculate total items and positions
    // Structure: [incomplete tasks] + [optional header] + [completed tasks]
    final hasCompletedTasks = completedTasks.isNotEmpty;
    final totalItems = incompleteTasks.length + (hasCompletedTasks ? 1 : 0) + completedTasks.length;
    
    // Build task list with cards
    return ListView.builder(
      itemCount: totalItems,
      itemBuilder: (context, index) {
        // First, show all incomplete tasks
        if (index < incompleteTasks.length) {
          final task = incompleteTasks[index];
          return TaskCard(
            task: task,
            onEdit: () => onEditTask(task),
            onTaskChanged: onTaskChanged,
          );
        }
        
        // Then, show "Completed Tasks" header if there are completed tasks
        final headerIndex = incompleteTasks.length;
        if (hasCompletedTasks && index == headerIndex) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Completed Tasks',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          );
        }
        
        // Finally, show completed tasks
        final completedIndex = index - (hasCompletedTasks ? headerIndex + 1 : headerIndex);
        final task = completedTasks[completedIndex];
        return TaskCard(
          task: task,
          onEdit: () => onEditTask(task),
          onTaskChanged: onTaskChanged,
        );
      },
    );
  }
}
