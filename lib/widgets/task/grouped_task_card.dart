import 'package:flutter/material.dart';

import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';
import '../../utils/logging.dart';
import '../../utils/theme_helpers.dart';
import 'task_detail_view.dart';

/// Google Keep style card with multiple tasks inside
/// Tap to expand/collapse all tasks, long press on individual task to edit
class GroupedTaskCard extends StatefulWidget {
  final List<Task> tasks;
  final TaskPriority priority;
  final ValueChanged<Task> onEditTask;
  final VoidCallback? onTaskChanged;

  const GroupedTaskCard({
    super.key,
    required this.tasks,
    required this.priority,
    required this.onEditTask,
    this.onTaskChanged,
  });

  @override
  State<GroupedTaskCard> createState() => _GroupedTaskCardState();
}

class _GroupedTaskCardState extends State<GroupedTaskCard> {
  bool _isExpanded = false;
  Task? _expandedTask;

  Color _getPriorityColor(BuildContext context) {
    final theme = Theme.of(context);
    final priorityColors = generatePriorityColors(theme.colorScheme.primary);
    switch (widget.priority) {
      case TaskPriority.critical:
        return priorityColors[0];
      case TaskPriority.high:
        return priorityColors[1];
      case TaskPriority.medium:
        return priorityColors[2];
      case TaskPriority.low:
        return priorityColors[3];
    }
  }

  Future<void> _toggleTaskComplete(Task task, BuildContext context) async {
    try {
      task.isCompleted = !task.isCompleted;
      task.completionTime = task.isCompleted ? DateTime.now() : null;
      await taskRepo.upsertTask(task);
      await logger(
        LogLevel.info,
        'Task toggled: ${task.title}',
        source: 'grouped_task_card.dart',
      );
      widget.onTaskChanged?.call();
    } catch (e) {
      await logger(
        LogLevel.error,
        'Failed to toggle task: $e',
        source: 'grouped_task_card.dart',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priorityColor = _getPriorityColor(context);

    return GestureDetector(
      onTap: () => setState(() {
        _isExpanded = !_isExpanded;
        _expandedTask = null;
      }),
      child: Container(
        decoration: BoxDecoration(
          color: widget.priority == TaskPriority.critical
              ? priorityColor.withValues(alpha: 0.15)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with priority badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.priority.name.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: priorityColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${widget.tasks.length} tasks',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Task list inside card
            ...widget.tasks.map((task) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onLongPress: () => widget.onEditTask(task),
                  onTap: () => setState(() {
                    _expandedTask = _expandedTask == task ? null : task;
                  }),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _toggleTaskComplete(task, context),
                        child: Checkbox(
                          visualDensity: VisualDensity.compact,
                          value: task.isCompleted,
                          onChanged: null,
                          fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                            if (states.contains(WidgetState.disabled)) {
                              return task.isCompleted
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.secondary.withValues(alpha: 0.2);
                            }
                            return theme.colorScheme.primary;
                          }),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          task.title,
                          maxLines: _isExpanded || _expandedTask == task ? null : 1,
                          overflow: _isExpanded || _expandedTask == task
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            color: task.isCompleted
                                ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Show detail view if this task is selected
                if (_expandedTask == task)
                  Padding(
                    padding: const EdgeInsets.only(left: 40.0, top: 8.0, bottom: 8.0),
                    child: TaskDetailView(task: task),
                  ),
                // Show divider between tasks
                if (widget.tasks.last != task)
                  const Divider(height: 16, thickness: 0.5),
              ],
            )),
            // Show more indicator if not expanded
            if (!_isExpanded && widget.tasks.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  '+${widget.tasks.length - 3} more',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}