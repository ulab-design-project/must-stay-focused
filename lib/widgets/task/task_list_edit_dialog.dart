// File: lib/widgets/task/task_list_edit_dialog.dart
// Task List Edit Dialog
//
// Dialog for creating, editing, and deleting task lists.
// Only the Default list is protected from deletion.

import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';
import '../../style/theme.dart';
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

    final merge = await GlassDialog.show<bool>(
      context: context,
      title: 'Delete List',
      message: 'Move tasks to Default list?',
      actions: [
        GlassDialogAction(
          label: 'Delete', //TODO known issue  - the task list needs to reset to default
          isDestructive: true,
          onPressed: () => Navigator.pop(context, false),
        ),
        GlassDialogAction(
          label: 'Move',
          isPrimary: true,
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
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
              padding: const EdgeInsets.only(
                bottom: AppElementSizes.spacingSm,
              ),
              child: Text(
                'This is a system list and cannot be edited.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ),
              GlassTextField(
                controller: _nameController,
                enabled: !isProtectedList,
                placeholder: 'List Name',
              ),
              const SizedBox(height: AppElementSizes.spacingMd),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select Icon',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: AppElementSizes.spacingSm),
              Wrap(
                spacing: AppElementSizes.spacingSm,
                runSpacing: AppElementSizes.spacingSm,
                children: availableIcons.map((icon) {
                  final isSelected = icon.codePoint == _selectedIcon;
                  return GlassChip(
                    label: '',
                    icon: Padding(
                      padding: const EdgeInsets.only(left: 4.0), // Alignment -_-
                      child: Icon(
                        icon,
                        size: AppElementSizes.icon,
                        color: isSelected
                            ? theme.colorScheme.secondary
                            : Colors.white,
                      ),
                    ),
                    labelStyle: TextStyle(fontSize: 0),
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
          GlassDialogAction(
            label: 'Save',
            isPrimary: true,
            onPressed: _save,
          ),
      ],
    );
  }
}
