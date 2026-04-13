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
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';
import '../../style/liquid_glass_style.dart';
import '../../utils/theme_helpers.dart';
import '../../utils/logging.dart';

/// A swipeable card widget representing a single task.
/// Provides quick actions: toggle complete, move to Archived (swipe left), delete (swipe right).
/// All database operations are performed via the global taskRepo instance.
class TaskCard extends StatefulWidget {
  // The task data to display
  final Task task;

  // Callback fired when the card body is tapped (opens edit dialog)
  final VoidCallback onEdit;

  // Callback fired when task is modified (for parent to refresh list)
  final ValueChanged<Task>? onTaskChanged;

  // Whether this card should play a small entry animation.
  final bool animateEntry;

  const TaskCard({
    super.key,
    required this.task,
    required this.onEdit,
    this.onTaskChanged,
    this.animateEntry = false,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  static const Duration _toggleAnimationDuration = Duration(milliseconds: 220);

  bool _isExiting = false;
  bool _isCollapsed = false;
  bool _entryReady = false;

  /// Returns the background color based on task priority.
  Color _getPriorityColor(BuildContext context) {
    final theme = Theme.of(context);
    final priorityColors = generateColorSteps(theme.colorScheme.primary);
    switch (widget.task.priority) {
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

  /// Toggles the task completion status and updates via repository.
  @override
  void initState() {
    super.initState();
    _entryReady = !widget.animateEntry;

    if (widget.animateEntry) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        setState(() => _entryReady = true);
      });
    }
  }

  Future<void> _toggleComplete(BuildContext context) async {
    final previousCompleted = widget.task.isCompleted;
    final previousCompletionTime = widget.task.completionTime;

    try {
      if (_isExiting) {
        return;
      }

      widget.task.isCompleted = !widget.task.isCompleted;
      widget.task.completionTime = widget.task.isCompleted
          ? DateTime.now()
          : null;

      if (mounted) {
        setState(() => _isExiting = true);
      }

      await taskRepo.upsertTask(widget.task);
      await Future.delayed(_toggleAnimationDuration);

      if (mounted) {
        setState(() => _isCollapsed = true);
      }

      await logger(
        LogLevel.info,
        'Task toggled: ${widget.task.title}',
        source: 'task_card.dart',
      );
      widget.onTaskChanged?.call(widget.task);
    } catch (e) {
      widget.task.isCompleted = previousCompleted;
      widget.task.completionTime = previousCompletionTime;

      if (mounted) {
        setState(() {
          _isExiting = false;
          _isCollapsed = false;
        });
      }

      await logger(
        LogLevel.error,
        'Failed to toggle task: $e',
        source: 'task_card.dart',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  /// Toggles the task archived status and updates via repository.
  Future<void> _toggleArchive(BuildContext context) async {
    try {
      widget.task.isArchived = !widget.task.isArchived;
      await taskRepo.upsertTask(widget.task);
      await logger(
        LogLevel.info,
        'Task archived: ${widget.task.title}',
        source: 'task_card.dart',
      );
      widget.onTaskChanged?.call(widget.task);
    } catch (e) {
      await logger(
        LogLevel.error,
        'Failed to archive task: $e',
        source: 'task_card.dart',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  /// Deletes the task from the database via repository.
  Future<void> _delete(BuildContext context) async {
    try {
      await taskRepo.deleteTask(widget.task.id);
      await logger(
        LogLevel.info,
        'Task deleted: ${widget.task.title}',
        source: 'task_card.dart',
      );
    } catch (e) {
      await logger(
        LogLevel.error,
        'Failed to delete task: $e',
        source: 'task_card.dart',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  /// Formats a DateTime to HH:MM string.
  String _formatTime(DateTime time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final entryOpacity = _entryReady ? 1.0 : 0.0;
    final entryOffsetY = _entryReady ? 0.0 : 0.06;
    final exitOpacity = _isExiting ? 0.0 : 1.0;
    final exitOffsetY = _isExiting ? 0.08 : 0.0;

    final animatedOpacity = entryOpacity * exitOpacity;
    final animatedOffset = Offset(0, entryOffsetY + exitOffsetY);

    return AnimatedSize(
      duration: _toggleAnimationDuration,
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: _isCollapsed
          ? const SizedBox.shrink()
          : AnimatedOpacity(
              duration: _toggleAnimationDuration,
              curve: Curves.easeInOut,
              opacity: animatedOpacity,
              child: AnimatedSlide(
                duration: _toggleAnimationDuration,
                curve: Curves.easeInOut,
                offset: animatedOffset,
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: 8.0,
                    left: 16.0,
                    right: 16.0,
                  ),
                  child: Dismissible(
                    key: ValueKey(widget.task.id),
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
                          builder: (ctx) => GlassDialog(
                            title: 'Delete Task',
                            content: const Text(
                              'Are you sure you want to delete this task?', style: TextStyle(color: Colors.white),
                            ),
                            actions: [
                              GlassDialogAction(
                                label: 'Cancel',
                                onPressed: () => Navigator.pop(ctx, false),
                                
                              ),
                              GlassDialogAction(
                                label: 'Delete',
                                onPressed: () => Navigator.pop(ctx, true),
                          
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
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 16),
                      child: Icon(
                        Icons.delete,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                    // Background for swipe left (move to Archived)
                    secondaryBackground: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      child: Icon(
                        Icons.archive,
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                    ),
                    child: GlassCard(
                      padding: EdgeInsets.zero,
                      useOwnLayer: false,
                      settings: glassSettingsFor(
                        context,
                        isPrimary:
                            widget.task.priority == TaskPriority.critical,
                      ),
                      child: GlassListTile(
                        leading: GestureDetector(
                          onTap: () => _toggleComplete(context),
                          child: Checkbox(
                            visualDensity: VisualDensity.compact,
                            // TODO: Convert to liquid glass checkbox when available.
                            value: widget.task.isCompleted,
                            onChanged: null,
                            fillColor: WidgetStateProperty.resolveWith<Color>((
                              states,
                            ) {
                              if (states.contains(WidgetState.disabled)) {
                                return widget.task.isCompleted
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.secondary.withValues(
                                        alpha: 0.2,
                                      );
                              }
                              return theme.colorScheme.primary;
                            }),
                          ),
                        ),
                        title: Text(
                          widget.task.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            decoration: widget.task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: widget.task.isCompleted
                                ? theme.colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  )
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          widget.task.startTime != null
                              ? '${_formatTime(widget.task.startTime!)}${widget.task.endTime != null ? ' - ${_formatTime(widget.task.endTime!)}' : ''}'
                              : (widget.task.description ?? ''),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(
                              context,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          child: Text(
                            widget.task.priority.name.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        onTap: widget.onEdit,
                        isLast: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
