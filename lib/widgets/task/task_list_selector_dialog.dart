// File: lib/widgets/task/task_list_selector_dialog.dart
// Simple Searchable List Selector Dialog
//
// A lightweight dialog for selecting a task list without edit/create functionality.
// Used within TaskEditDialog for simple list selection.

import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';
import '../../style/theme.dart';
import '../../utils/task_list_icons.dart';

/// A simple searchable dialog for selecting a task list.
/// Does not include edit or create functionality - just selection.
class TaskListSelectorDialog extends StatefulWidget {
  final TaskList? selectedList;

  const TaskListSelectorDialog({super.key, this.selectedList});

  @override
  State<TaskListSelectorDialog> createState() => _TaskListSelectorDialogState();
}

class _TaskListSelectorDialogState extends State<TaskListSelectorDialog> {
  String _searchQuery = '';
  List<TaskList> _lists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLists();
  }

  /// Loads all task lists from the database.
  Future<void> _loadLists() async {
    _lists = await taskRepo.getTaskLists();
    if (mounted) setState(() => _isLoading = false);
  }

  /// Filters lists based on search query.
  List<TaskList> get _filteredLists {
    if (_searchQuery.isEmpty) return _lists;
    return _lists
        .where((l) => l.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassDialog(
      maxWidth: 360,
      title: 'Select Task List',
      actions: [
        GlassDialogAction(
          label: 'Cancel',
          onPressed: () => Navigator.pop(context),
        ),
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GlassTextField(
                placeholder: 'Search...',
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white.withValues(alpha: 0.75),
                  size: 18,
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
              const SizedBox(height: AppElementSizes.spacingSm),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(AppElementSizes.spacingLg),
                  child: CircularProgressIndicator(),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 280),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredLists.length,
                    itemBuilder: (ctx, i) {
                      final list = _filteredLists[i];
                      final isSelected = list.id == widget.selectedList?.id;
                      return GlassListTile(
                        leading: Icon(
                          taskListIconFromCodePoint(list.iconCodePoint),
                          color: Colors.white,
                        ),
                        title: Text(
                          list.name,
                          style: TextStyle(color: Colors.white),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check,
                                color: theme.colorScheme.primary,
                              )
                            : null,
                        onTap: () => Navigator.pop(ctx, list),
                        isLast: i == _filteredLists.length - 1,
                      );
                    },
                  ),
                ),
            ],
          ),
    );
  }
}
