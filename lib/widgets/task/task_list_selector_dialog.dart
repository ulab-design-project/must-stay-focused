// File: lib/widgets/task/task_list_selector_dialog.dart
// Simple Searchable List Selector Dialog
//
// A lightweight dialog for selecting a task list without edit/create functionality.
// Used within TaskEditDialog for simple list selection.

import 'package:flutter/material.dart';

import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';

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
    return AlertDialog(
      title: const Text('Select Task List'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search field
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
            const SizedBox(height: 16),
            // List of task lists
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredLists.length,
                  itemBuilder: (ctx, i) {
                    final list = _filteredLists[i];
                    final isSelected = list.id == widget.selectedList?.id;
                    return ListTile(
                      leading: Icon(IconData(list.iconCodePoint, fontFamily: 'MaterialIcons')),
                      title: Text(list.name),
                      trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
                      onTap: () => Navigator.pop(ctx, list),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      ],
    );
  }
}
