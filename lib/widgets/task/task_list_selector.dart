// File: lib/widgets/task/task_list_selector.dart
// Task List Selector Dropdown Widget
//
// Requirements:
// 1. class TaskListSelector extends StatefulWidget:
//    - Properties: final TaskList? selectedList, final ValueChanged<TaskList> onListSelected, final VoidCallback? onListChanged, final VoidCallback? onArchivedToggled
//    - Shows current list name with icon
//    - Opens dropdown dialog with search functionality
//    - Allows selecting, editing, or creating task lists
//    - All DB operations via global taskRepo instance

import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';
import '../../style/buttons.dart';
import '../../style/theme.dart';
import 'task_list_edit_dialog.dart';

/// A dropdown selector widget for choosing a task list.
/// Opens a dialog with search, edit, and create functionality.
/// All database operations are performed via the global taskRepo instance.
class TaskListSelector extends StatefulWidget {
  // Currently selected task list (null = no selection or archived view)
  final TaskList? selectedList;

  // Callback fired when a list is selected
  final ValueChanged<TaskList> onListSelected;

  // Callback fired when a list is added/edited/deleted (for parent to refresh)
  final VoidCallback? onListChanged;

  // Callback fired when Archived button is tapped
  final VoidCallback? onArchivedToggled;
  final double? width;

  const TaskListSelector({
    super.key,
    this.selectedList,
    required this.onListSelected,
    this.onListChanged,
    this.onArchivedToggled,
    this.width = 100,
  });

  @override
  State<TaskListSelector> createState() => _TaskListSelectorState();
}

class _TaskListSelectorState extends State<TaskListSelector> {
  // All loaded task lists from database
  List<TaskList> _allLists = [];

  // Filtered lists based on search query
  List<TaskList> _filteredLists = [];

  // Current search text
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadLists();
  }

  /// Loads all task lists from the database via global taskRepo.
  Future<void> _loadLists() async {
    _allLists = await taskRepo.getTaskLists();
    _filterLists();
    if (mounted) setState(() {});
  }

  /// Filters the loaded lists based on current search query.
  void _filterLists() {
    if (_searchQuery.isEmpty) {
      _filteredLists = List.from(_allLists);
    } else {
      _filteredLists = _allLists
          .where(
            (l) => l.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
  }

  /// Opens the TaskListEditDialog for creating or editing a list.
  void _openEditDialog({TaskList? list}) async {
    await showDialog(
      context: context,
      builder: (ctx) => TaskListEditDialog(existingList: list),
    );
    await _loadLists();
    widget.onListChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassPicker(
      width: widget.width,
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      value: widget.selectedList?.name ?? 'Archived',
      textStyle: TextStyle(
        fontSize: AppTextSizes.small,
        color: theme.colorScheme.onSurface,
      ),
      placeholderStyle: TextStyle(
        fontSize: AppTextSizes.small,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
      ),
      icon: Icon(
        Icons.expand_more,
        size: 16,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
      ),
      onTap: () => _showDropdown(context),
    );
  }

  /// Shows the dropdown dialog with search and list options.
  void _showDropdown(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        _searchQuery = '';
        _filterLists();
        return StatefulBuilder(
          builder: (ctx, setDialogState) => GlassDialog(
            title: 'Select List',
            maxWidth: 360,
            actions: [
              GlassDialogAction(
                label: 'Close',
                onPressed: () => Navigator.pop(ctx),
              )
            ],
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GlassTextField(
                    placeholder: 'Search...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.white.withValues(
                        alpha: 0.75,
                      ),
                      size: 18,
                    ),
                    onChanged: (v) {
                      _searchQuery = v;
                      _filterLists();
                      setDialogState(() {});
                    },
                  ),
                  const SizedBox(height: AppElementSizes.spacingSm),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredLists.length,
                      itemBuilder: (ctx, i) {
                        final list = _filteredLists[i];
                        final isProtectedList = list.isDefault;
                        return GlassListTile(
                          leading: Icon(
                            IconData(
                              list.iconCodePoint,
                              fontFamily: 'MaterialIcons',
                            ),
                            color: Colors.white,
                          ),
                          title: Text(
                            list.name,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          trailing: isProtectedList
                              ? null
                              : GlassSquircleIconButton(
                                  size: 30,
                                  color: Colors.white,
                                  icon: const Icon(Icons.edit, size: 16),
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    _openEditDialog(list: list);
                                  },
                                ),
                          onTap: () {
                            Navigator.pop(ctx);
                            widget.onListSelected(list);
                          },
                          isLast: i == _filteredLists.length - 1,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppElementSizes.spacingSm),
                  GlassListTile(
                    leading: Icon(
                      Icons.archive,
                      color: Colors.white,
                    ),
                    title: Text(
                      'Archived',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      widget.onArchivedToggled?.call();
                    },
                    isLast: false,
                  ),
                  GlassListTile(
                    leading: Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    title: Text(
                      'Add List',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      _openEditDialog();
                    },
                    isLast: true,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
