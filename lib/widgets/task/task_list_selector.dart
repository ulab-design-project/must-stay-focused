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

import 'dart:ui';
import 'package:flutter/material.dart';

import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';
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
    final theme = Theme.of(context);
    final op = themeController.glassOpacity;
    final blur = themeController.glassBlur;
    
    return InkWell(
      onTap: () => _showDropdown(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: op),
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.selectedList != null)
                    Icon(
                      IconData(widget.selectedList!.iconCodePoint, fontFamily: 'MaterialIcons'),
                      size: 18,
                    )
                  else
                    const Icon(Icons.archive, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    widget.selectedList?.name ?? 'Archived',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.expand_more, size: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Shows the dropdown dialog with search and list options.
  void _showDropdown(BuildContext context) {
    final theme = Theme.of(context);
    final op = themeController.glassOpacity;
    final blur = themeController.glassBlur;
    
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: 300,
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
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: op),
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
                    children: [
                      // Search field
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onChanged: (v) {
                            _searchQuery = v;
                            _filterLists();
                            setDialogState(() {});
                          },
                        ),
                      ),
                      // List of task lists
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: _filteredLists.length,
                        itemBuilder: (ctx, i) {
                          final list = _filteredLists[i];
                          final isSelected = widget.selectedList?.id == list.id;
                          final isLast = i == _filteredLists.length - 1 && widget.selectedList == null;
                          
                          return InkWell(
                            borderRadius: BorderRadius.zero,
                            onTap: () {
                              Navigator.pop(ctx);
                              widget.onListSelected(list);
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
                                  Icon(
                                    IconData(list.iconCodePoint, fontFamily: 'MaterialIcons'),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      list.name,
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
                        },
                      ),
                      // Archived button
                      Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.2)),
                      InkWell(
                        onTap: () {
                          Navigator.pop(ctx);
                          widget.onArchivedToggled?.call();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              const Icon(Icons.archive, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Archived',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: widget.selectedList == null ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (widget.selectedList == null)
                                Icon(
                                  Icons.check,
                                  size: 18,
                                  color: theme.colorScheme.primary,
                                ),
                            ],
                          ),
                        ),
                      ),
                      Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.2)),
                      // Add new list button
                      InkWell(
                        onTap: () {
                          Navigator.pop(ctx);
                          _openEditDialog();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              const Icon(Icons.add, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Add List',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
