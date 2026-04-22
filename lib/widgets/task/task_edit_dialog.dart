import 'package:flutter/material.dart';

import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';
import '../../style/buttons.dart';
import '../../style/containers.dart';
import '../../style/dialogs.dart';
import '../../style/forms.dart';
import '../../style/list_tile.dart';
import '../../style/picker.dart';
import '../../style/theme.dart';
import '../../utils/logging.dart';
import 'task_list_selector_dialog.dart';

// Day abbreviations for recurring task selection
// const _days = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU']; // Unused currently

/// Dialog for creating or editing a task.
/// Includes title, description, priority, time range, recurring days, and list selection.
class TaskEditDialog extends StatefulWidget {
  final Task? existingTask;
  final TaskList? selectedList;

  const TaskEditDialog({super.key, this.existingTask, this.selectedList});

  @override
  State<TaskEditDialog> createState() => _TaskEditDialogState();
}

class _TaskEditDialogState extends State<TaskEditDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  TaskList? _selectedList;
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _startTime;
  DateTime? _endTime;
  List<int> _selectedDays = [];

  @override
  void initState() {
    super.initState();
    _selectedList = widget.selectedList;
    if (widget.existingTask != null) {
      _titleController.text = widget.existingTask!.title;
      _descController.text = widget.existingTask!.description ?? '';
      _priority = widget.existingTask!.priority;
      _startTime = widget.existingTask!.startTime;
      _endTime = widget.existingTask!.endTime;
      _selectedDays = widget.existingTask!.days ?? [];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  /// Shows date and time picker for start time.
  Future<void> _pickStartTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startTime ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startTime ?? DateTime.now()),
    );
    if (time == null || !mounted) return;

    setState(() {
      _startTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  /// Shows time picker for end time (requires start time to be set).
  Future<void> _pickEndTime() async {
    if (_startTime == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endTime ?? _startTime!),
    );
    if (time == null || !mounted) return;

    setState(() {
      _endTime = DateTime(
        _startTime!.year,
        _startTime!.month,
        _startTime!.day,
        time.hour,
        time.minute,
      );
    });
  }

  /// Shows the list selector dialog.
  Future<void> _showListSelector() async {
    final selected = await showDialog<TaskList>(
      context: context,
      builder: (ctx) => TaskListSelectorDialog(selectedList: _selectedList),
    );
    if (selected != null) {
      setState(() => _selectedList = selected);
    }
  }

  Future<void> _openPriorityPicker() async {
    final selected = await showModalBottomSheet<TaskPriority>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Padding(
          padding: const EdgeInsets.all(AppElementSizes.spacingLg),
          child: GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: TaskPriority.values.map((priority) {
                return GlassListTile(
                  leading: Icon(
                    Icons.flag,
                    color: theme.colorScheme.onSurface,
                    size: 18,
                  ),
                  title: Text(
                    priority.name.toUpperCase(),
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                  trailing: priority == _priority
                      ? Icon(Icons.check, color: theme.colorScheme.primary)
                      : null,
                  onTap: () => Navigator.of(ctx).pop(priority),
                  isLast: priority == TaskPriority.values.last,
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    if (selected != null && mounted) {
      setState(() => _priority = selected);
    }
  }

  /// Saves the task to the database.
  Future<void> _save() async {
    final trimmedTitle = _titleController.text.trim();
    if (trimmedTitle.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Title is required')));
      }
      return;
    }

    if (_selectedList == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Select a list')));
      }
      return;
    }

    try {
      final task = widget.existingTask ?? Task();
      task.title = trimmedTitle;
      task.description = _descController.text.isEmpty
          ? null
          : _descController.text;
      task.priority = _priority;
      task.startTime = _startTime;
      task.endTime = _endTime;
      task.days = _selectedDays.isEmpty ? null : _selectedDays;
      task.taskList.value = _selectedList;
      if (widget.existingTask == null) task.creationTime = DateTime.now();

      await taskRepo.upsertTask(task);
      await logger(
        LogLevel.info,
        'Task saved: ${task.title}',
        source: 'task_edit_dialog.dart',
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      await logger(
        LogLevel.error,
        'Failed to save task: $e',
        source: 'task_edit_dialog.dart',
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  String _timeLabel(DateTime? value, String fallback) {
    if (value == null) return fallback;
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassDialog(
      maxWidth: 460,
      title: widget.existingTask == null ? 'New Task' : 'Edit Task',
      content: SizedBox(
        height: 300,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassTextField(
                controller: _titleController,
                placeholder: 'Title *',
              ),
              const SizedBox(height: AppElementSizes.spacingMd),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal:   AppElementSizes.spacingMd),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Task list',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.88,
                          ),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GlassPicker(
                      width: 160,
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      value: _selectedList?.name ?? 'Default',
                      textStyle: TextStyle(
                        fontSize: AppTextSizes.small,
                        color: theme.colorScheme.onSurface,
                      ),
                      placeholderStyle: TextStyle(
                        fontSize: AppTextSizes.small,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.65,
                        ),
                      ),
                      icon: Icon(
                        Icons.expand_more,
                        size: 14,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.85,
                        ),
                      ),
                      onTap: _showListSelector,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppElementSizes.spacingMd),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppElementSizes.spacingMd),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Priority',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.88,
                          ),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GlassPicker(
                      width: 160,
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      value: _priority.name,
                      textStyle: TextStyle(
                        fontSize: AppTextSizes.small,
                        color: theme.colorScheme.onSurface,
                      ),
                      placeholderStyle: TextStyle(
                        fontSize: AppTextSizes.small,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.65,
                        ),
                      ),
                      icon: Icon(
                        Icons.expand_more,
                        size: 14,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.85,
                        ),
                      ),
                      onTap: _openPriorityPicker,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppElementSizes.spacingMd),
              GlassTextField(
                controller: _descController,
                placeholder: 'Description',
                maxLines: 2,
              ),
              const SizedBox(height: AppElementSizes.spacingMd),
              Row(
                children: [
                  Expanded(
                    child: GlassSquircleButton(
                      isPrimary: true,
                      onPressed: _pickStartTime,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color: theme.colorScheme.onSurface,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _timeLabel(_startTime, 'Start time'),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: AppTextSizes.small,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppElementSizes.spacingSm),
                  Expanded(
                    child: GlassSquircleButton(
                      isPrimary: true,
                      onPressed: _startTime != null ? _pickEndTime : null,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color: theme.colorScheme.onSurface,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _timeLabel(_endTime, 'End time'),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: AppTextSizes.small,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppElementSizes.spacingMd),
            ],
          ),
        ),
      ),
      actions: [
        GlassDialogAction(
          label: 'Cancel',
          onPressed: () => Navigator.pop(context),
        ),
        GlassDialogAction(label: 'Save', isPrimary: true, onPressed: _save),
      ],
    );
  }
}
