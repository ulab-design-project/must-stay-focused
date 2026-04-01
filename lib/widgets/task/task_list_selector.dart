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

import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';
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

  const TaskListSelector({
    super.key,
    this.selectedList,
    required this.onListSelected,
    this.onListChanged,
    this.onArchivedToggled,
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
      _filteredLists = _allLists.where(
        (l) => l.name.toLowerCase().contains(_searchQuery.toLowerCase()),
      ).toList();
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
    return InkWell(
      onTap: () => _showDropdown(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.selectedList != null)
              Icon(
                IconData(widget.selectedList!.iconCodePoint, fontFamily: 'MaterialIcons'),
                size: 20,
              )
            else
              const Icon(Icons.archive, size: 20),
            const SizedBox(width: 8),
            Text(widget.selectedList?.name ?? 'Archived'),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  /// Shows the dropdown dialog with search and list options.
  void _showDropdown(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search field
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) {
                      _searchQuery = v;
                      _filterLists();
                      setDialogState(() {});
                    },
                  ),
                ),
                // List of task lists
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredLists.length,
                    itemBuilder: (ctx, i) {
                      final list = _filteredLists[i];
                      // Only Default list is protected (cannot be edited/deleted)
                      final isProtectedList = list.isDefault;
                      return ListTile(
                        leading: Icon(
                          IconData(list.iconCodePoint, fontFamily: 'MaterialIcons'),
                        ),
                        title: Text(list.name),
                        trailing: isProtectedList
                            ? null // No edit button for protected lists
                            : IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  _openEditDialog(list: list);
                                },
                              ),
                        onTap: () {
                          Navigator.pop(ctx);
                          widget.onListSelected(list);
                        },
                      );
                    },
                  ),
                ),
                // Archived button
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.archive),
                  title: const Text('Archived'),
                  onTap: () {
                    Navigator.pop(ctx);
                    widget.onArchivedToggled?.call();
                  },
                ),
                const Divider(height: 1),
                // Add new list button
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('Add List'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _openEditDialog();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
