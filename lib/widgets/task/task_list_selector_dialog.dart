// File: lib/widgets/task/task_list_selector_dialog.dart
// Simple Searchable List Selector Dialog
//
// A lightweight dialog for selecting a task list without edit/create functionality.
// Used within TaskEditDialog for simple list selection.

import 'dart:ui';
import 'package:flutter/material.dart';

import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';
import '../../style/theme.dart';

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
    return _lists.where((l) => l.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final op = themeController.glassOpacity;
    final blur = themeController.glassBlur;
    
    return AlertDialog(
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
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Select Task List',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Search field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
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
                      onChanged: (v) => setState(() => _searchQuery = v),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // List of task lists
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _filteredLists.length,
                        itemBuilder: (ctx, i) {
                          final list = _filteredLists[i];
                          final isSelected = list.id == widget.selectedList?.id;
                          final isLast = i == _filteredLists.length - 1;
                          
                          return InkWell(
                            borderRadius: BorderRadius.zero,
                            onTap: () => Navigator.pop(ctx, list),
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
                    ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
