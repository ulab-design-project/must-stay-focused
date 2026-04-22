import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';
import '../../style/containers.dart';
import '../../style/list_tile.dart';
import '../../style/dialogs.dart';
import '../../utils/logging.dart';
import '../../utils/theme_helpers.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final VoidCallback onEdit;
  final ValueChanged<Task>? onTaskChanged;
  final bool animateEntry;

  // Plays finite glow bursts under high/critical cards in interception mode.
  final bool showInterceptionGlow;

  const TaskCard({
    super.key,
    required this.task,
    required this.onEdit,
    this.onTaskChanged,
    this.animateEntry = false,
    this.showInterceptionGlow = false,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard>
    with SingleTickerProviderStateMixin {
  static const Duration _toggleAnimationDuration = Duration(milliseconds: 220);
  static const Duration _glowBurstDuration = Duration(milliseconds: 360);
  static const Duration _glowBurstGap = Duration(milliseconds: 140);

  bool _isExiting = false;
  bool _isCollapsed = false;
  bool _entryReady = false;
  late final AnimationController _glowController;
  int _remainingGlowBursts = 0;

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

  int _targetGlowBursts() {
    switch (widget.task.priority) {
      case TaskPriority.critical:
        return 3;
      case TaskPriority.high:
        return 2;
      case TaskPriority.medium:
      case TaskPriority.low:
        return 0;
    }
  }

  bool get _canGlowBurst {
    return widget.showInterceptionGlow &&
        !widget.task.isCompleted &&
        _targetGlowBursts() > 0;
  }

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: _glowBurstDuration,
    );
    _entryReady = !widget.animateEntry;

    if (widget.animateEntry) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        setState(() => _entryReady = true);
      });
    }

    _runGlowBurstsIfNeeded();
  }

  @override
  void didUpdateWidget(covariant TaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.showInterceptionGlow != widget.showInterceptionGlow ||
        oldWidget.task.id != widget.task.id ||
        oldWidget.task.priority != widget.task.priority ||
        oldWidget.task.isCompleted != widget.task.isCompleted) {
      _runGlowBurstsIfNeeded();
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _runGlowBurstsIfNeeded() {
    try {
      _glowController.stop();
      _glowController.value = 0;
      _remainingGlowBursts = 0;

      if (!_canGlowBurst) {
        return;
      }

      _remainingGlowBursts = _targetGlowBursts();
      unawaited(_playNextGlowBurst());
    } catch (e, stackTrace) {
      debugPrint('TaskCard _runGlowBurstsIfNeeded error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _playNextGlowBurst() async {
    try {
      if (!mounted || _remainingGlowBursts <= 0) {
        return;
      }

      await _glowController.forward(from: 0);

      if (!mounted) {
        return;
      }

      _remainingGlowBursts -= 1;
      if (_remainingGlowBursts <= 0) {
        return;
      }

      await Future.delayed(_glowBurstGap);
      if (!mounted) {
        return;
      }

      unawaited(_playNextGlowBurst());
    } catch (e, stackTrace) {
      debugPrint('TaskCard _playNextGlowBurst error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Widget _buildGlowUnderlay(BuildContext context) {
    final glowColor = _getPriorityColor(context);

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, _) {
          if (!_canGlowBurst) {
            return const SizedBox.shrink();
          }

          final t = Curves.easeInOut.transform(_glowController.value);
          final burstOpacity = 1.0 - (2.0 * t - 1.0).abs();
          if (burstOpacity <= 0) {
            return const SizedBox.shrink();
          }

          return Opacity(
            opacity: burstOpacity,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withValues(alpha: 0.45),
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: glowColor.withValues(alpha: 0.30),
                    blurRadius: 32,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
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
                      if (direction == DismissDirection.endToStart) {
                        await _toggleArchive(context);
                        return true;
                      }

                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => GlassDialog(
                          title: 'Delete Task',
                          content: const Text(
                            'Are you sure you want to delete this task?',
                            style: TextStyle(
                              color: Color.fromRGBO(255, 255, 255, 0.87),
                            ),
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
                    },
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
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(child: _buildGlowUnderlay(context)),
                        GlassCard(
                          padding: EdgeInsets.zero,
                          isPrimary:
                              widget.task.priority == TaskPriority.critical,
                          child: GlassListTile(
                            leading: GestureDetector(
                              onTap: () => _toggleComplete(context),
                              child: Checkbox(
                                visualDensity: VisualDensity.compact,
                                value: widget.task.isCompleted,
                                onChanged: null,
                                fillColor:
                                    WidgetStateProperty.resolveWith<Color>((
                                      states,
                                    ) {
                                      if (states.contains(
                                        WidgetState.disabled,
                                      )) {
                                        return widget.task.isCompleted
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.secondary
                                                  .withValues(alpha: 0.2);
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
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.secondary
                                        .withValues(alpha: 0.3),
                                    blurRadius: 7,
                                  ),
                                ],
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
