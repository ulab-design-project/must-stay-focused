// File: lib/widgets/task/task_list_edit_dialog.dart
// Task List Edit Dialog
//
// Dialog for creating, editing, and deleting task lists.
// Only the Default list is protected from deletion.

import 'package:flutter/material.dart';

import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';
import '../../style/chips.dart';
import '../../style/dialogs.dart';
import '../../style/forms.dart';
import '../../style/theme.dart';
import '../../utils/task_list_icons.dart';
import '../../utils/logging.dart';

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
      await logger(
        LogLevel.info,
        'TaskList saved: ${list.name}',
        source: 'task_list_edit_dialog.dart',
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      await logger(
        LogLevel.error,
        'Failed to save list: $e',
        source: 'task_list_edit_dialog.dart',
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  /// Deletes the task list with option to merge tasks to default list.
  Future<void> _delete() async {
    if (widget.existingList == null) return;
    if (widget.existingList!.isDefault) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Can't delete default list")),
        );
      }
      return;
    }

    final merge = await showDialog<bool>(
      barrierDismissible: true,
      context: context,
      builder: (ctx) => GlassDialog(
        title: 'Delete List',
        content: const Text('Move tasks to Default list before deleting?'),
        actions: [
          GlassDialogAction(
            label:
                'Delete', //TODO known issue  - the task list needs to reset to default
            isDestructive: true,
            onPressed: () => Navigator.pop(ctx, false),
          ),
          GlassDialogAction(
            label: 'Move',
            isPrimary: true,
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
    if (merge == null) return;

    try {
      await taskRepo.deleteTaskList(
        widget.existingList!,
        mergeToDefault: merge,
      );
      await logger(
        LogLevel.info,
        'TaskList deleted: ${widget.existingList!.name}',
        source: 'task_list_edit_dialog.dart',
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      await logger(
        LogLevel.error,
        'Failed to delete list: $e',
        source: 'task_list_edit_dialog.dart',
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isProtectedList =
        widget.existingList != null && widget.existingList!.isDefault;

    return GlassDialog(
      title: widget.existingList == null ? 'New List' : 'Edit List',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isProtectedList)
            Padding(
              padding: const EdgeInsets.only(bottom: AppElementSizes.spacingSm),
              child: Text(
                'This is a system list and cannot be edited.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ),
          GlassTextField(
            controller: _nameController,
            enabled: !isProtectedList,
            placeholder: 'List Name',
          ),
          const SizedBox(height: AppElementSizes.spacingMd),
          Text(
            'Select Icon',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppElementSizes.spacingSm),
          Wrap(
            spacing: AppElementSizes.spacingSm,
            runSpacing: AppElementSizes.spacingSm,
            children: taskListAvailableIcons.map((icon) {
              final isSelected = icon.codePoint == _selectedIcon;
              return GlassChip(
                label: '',
                leading: Icon(
                  icon,
                  size: AppElementSizes.icon,
                  color: isSelected
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.onSurface,
                ),
                selected: isSelected,
                onTap: isProtectedList
                    ? null
                    : () => setState(() => _selectedIcon = icon.codePoint),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        GlassDialogAction(
          label: 'Cancel',
          onPressed: () => Navigator.pop(context),
        ),
        if (widget.existingList != null && !isProtectedList)
          GlassDialogAction(
            label: 'Delete',
            isDestructive: true,
            onPressed: _delete,
          ),
        if (!isProtectedList)
          GlassDialogAction(label: 'Save', isPrimary: true, onPressed: _save),
      ],
    );
  }
}
