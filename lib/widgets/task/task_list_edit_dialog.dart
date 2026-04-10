// File: lib/widgets/task/task_list_edit_dialog.dart
// Task List Edit Dialog
//
// Dialog for creating, editing, and deleting task lists.
// Only the Default list is protected from deletion.

import 'package:flutter/material.dart';

import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';
import '../../utils/logging.dart';

// Available icons for task list selection
const availableIcons = [
  Icons.list,
  Icons.work,
  Icons.school,
  Icons.person,
  Icons.home,
  Icons.fitness_center,
  Icons.shopping_cart,
  Icons.book,
  Icons.music_note,
  Icons.flight,
];

/// Dialog for creating or editing a task list.
/// Allows name input, icon selection, and deletion with merge option.
class TaskListEditDialog extends StatefulWidget {
  final TaskList? existingList;

  const TaskListEditDialog({super.key, this.existingList});

  @override
  State<TaskListEditDialog> createState() => _TaskListEditDialogState();
}

class _TaskListEditDialogState extends State<TaskListEditDialog> {
  final _nameController = TextEditingController();
  int _selectedIcon = Icons.list.codePoint;

  @override
  void initState() {
    super.initState();
    if (widget.existingList != null) {
      _nameController.text = widget.existingList!.name;
      _selectedIcon = widget.existingList!.iconCodePoint;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Saves the task list to the database.
  Future<void> _save() async {
    if (_nameController.text.isEmpty) return;
    try {
      final list = widget.existingList ?? TaskList();
      list.name = _nameController.text;
      list.iconCodePoint = _selectedIcon;
      await taskRepo.upsertTaskList(list);
      await logger(LogLevel.info, 'TaskList saved: ${list.name}', source: 'task_list_edit_dialog.dart');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      await logger(LogLevel.error, 'Failed to save list: $e', source: 'task_list_edit_dialog.dart');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  /// Deletes the task list with option to merge tasks to default list.
  Future<void> _delete() async {
    if (widget.existingList == null) return;
    if (widget.existingList!.isDefault) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Can't delete default list")));
      }
      return;
    }

    final merge = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete List'),
        content: const Text('Move tasks to Default list?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Delete tasks')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Move to Default')),
        ],
      ),
    );
    if (merge == null) return;

    try {
      await taskRepo.deleteTaskList(widget.existingList!, mergeToDefault: merge);
      await logger(LogLevel.info, 'TaskList deleted: ${widget.existingList!.name}', source: 'task_list_edit_dialog.dart');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      await logger(LogLevel.error, 'Failed to delete list: $e', source: 'task_list_edit_dialog.dart');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isProtectedList = widget.existingList != null && widget.existingList!.isDefault;

    return AlertDialog(
      title: Text(widget.existingList == null ? 'New List' : 'Edit List'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isProtectedList)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'This is a system list and cannot be edited.',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onTertiaryContainer),
                ),
              ),
            ),
          TextField(
            controller: _nameController,
            enabled: !isProtectedList,
            decoration: const InputDecoration(labelText: 'List Name'),
          ),
          const SizedBox(height: 16),
          const Text('Select Icon'),
          Wrap(
            spacing: 8,
            children: availableIcons.map((icon) {
              final isSelected = icon.codePoint == _selectedIcon;
              return GestureDetector(
                onTap: isProtectedList ? null : () => setState(() => _selectedIcon = icon.codePoint),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        if (widget.existingList != null && !isProtectedList)
          TextButton(onPressed: _delete, child: const Text('Delete')),
        if (!isProtectedList)
          ElevatedButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
