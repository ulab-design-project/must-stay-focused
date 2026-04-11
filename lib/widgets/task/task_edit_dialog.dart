// File: lib/widgets/task/task_edit_dialog.dart
// Task Edit Dialog
//
// Dialog for creating, editing, and deleting tasks.
// Uses TaskListSelectorDialog for simple list selection.

import 'dart:ui';
import 'package:flutter/material.dart';

import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';
import '../../style/theme.dart';
import '../../utils/logging.dart';
import 'task_list_selector_dialog.dart';

// Day abbreviations for recurring task selection
const _days = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];

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
  final _formKey = GlobalKey<FormState>();
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
      _startTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
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
      _endTime = DateTime(_startTime!.year, _startTime!.month, _startTime!.day, time.hour, time.minute);
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

  /// Saves the task to the database.
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedList == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a list')));
      }
      return;
    }

    try {
      final task = widget.existingTask ?? Task();
      task.title = _titleController.text;
      task.description = _descController.text.isEmpty ? null : _descController.text;
      task.priority = _priority;
      task.startTime = _startTime;
      task.endTime = _endTime;
      task.days = _selectedDays.isEmpty ? null : _selectedDays;
      task.taskList.value = _selectedList;
      if (widget.existingTask == null) task.creationTime = DateTime.now();

      await taskRepo.upsertTask(task);
      await logger(LogLevel.info, 'Task saved: ${task.title}', source: 'task_edit_dialog.dart');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      await logger(LogLevel.error, 'Failed to save task: $e', source: 'task_edit_dialog.dart');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  /// Deletes the task from the database.
  Future<void> _delete() async {
    if (widget.existingTask == null) return;

    try {
      await taskRepo.deleteTask(widget.existingTask!.id);
      await logger(LogLevel.info, 'Task deleted: ${widget.existingTask!.title}', source: 'task_edit_dialog.dart');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      await logger(LogLevel.error, 'Failed to delete task: $e', source: 'task_edit_dialog.dart');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingTask == null ? 'New Task' : 'Edit Task'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title field (required)
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title *'),
                validator: (v) => v!.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),

              // List selector
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Task List', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _showListSelector,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: themeController.glassBlur, sigmaY: themeController.glassBlur),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface.withValues(alpha: themeController.glassOpacity),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.2),
                                    Colors.white.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                              child: Row(
                                children: [
                                  if (_selectedList != null)
                                    Icon(
                                      IconData(_selectedList!.iconCodePoint, fontFamily: 'MaterialIcons'),
                                      size: 20,
                                    ),
                                  if (_selectedList != null) const SizedBox(width: 8),
                                  Expanded(child: Text(_selectedList?.name ?? 'Select a list')),
                                  const Icon(Icons.expand_more, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Description field (optional)
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Priority dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Priority', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      // Open priority selector
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (ctx) {
                          final theme = Theme.of(context);
                          return Container(
                            margin: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: themeController.glassBlur, sigmaY: themeController.glassBlur),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface.withValues(alpha: themeController.glassOpacity),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      width: 1,
                                    ),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white.withValues(alpha: 0.2),
                                        Colors.white.withValues(alpha: 0.0),
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: TaskPriority.values.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final p = entry.value;
                                      final isSelected = p == _priority;
                                      final isLast = index == TaskPriority.values.length - 1;
                                      
                                      return InkWell(
                                        onTap: () {
                                          setState(() => _priority = p);
                                          Navigator.pop(ctx);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                          decoration: BoxDecoration(
                                            border: isLast
                                                ? null
                                                : Border(
                                                    bottom: BorderSide(
                                                      color: theme.dividerColor.withValues(alpha: 0.1),
                                                      width: 1,
                                                    ),
                                                  ),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  p.name,
                                                  style: theme.textTheme.bodyMedium?.copyWith(
                                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                                  ),
                                                ),
                                              ),
                                              if (isSelected)
                                                Icon(
                                                  Icons.check,
                                                  size: 18,
                                                  color: theme.colorScheme.primary,
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: themeController.glassBlur, sigmaY: themeController.glassBlur),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface.withValues(alpha: themeController.glassOpacity),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1,
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withValues(alpha: 0.2),
                                  Colors.white.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(child: Text(_priority.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500))),
                                const Icon(Icons.expand_more, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Time range selection
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickStartTime,
                      icon: const Icon(Icons.access_time),
                      label: Text(
                        _startTime != null
                            ? '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}'
                            : 'Start Time',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _startTime != null ? _pickEndTime : null,
                      icon: const Icon(Icons.access_time),
                      label: Text(
                        _endTime != null
                            ? '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}'
                            : 'End Time',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Recurring days selection
              const Text('Recurring Days'),
              Wrap(
                spacing: 4,
                children: List.generate(7, (i) {
                  final dayNum = i + 1;
                  final isSelected = _selectedDays.contains(dayNum);
                  return FilterChip(
                    label: Text(_days[i]),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedDays.add(dayNum);
                        } else {
                          _selectedDays.remove(dayNum);
                        }
                      });
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        if (widget.existingTask != null)
          TextButton(onPressed: _delete, child: const Text('Delete')),
        ElevatedButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
