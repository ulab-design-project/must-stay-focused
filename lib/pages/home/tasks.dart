// File: lib/pages/home/tasks.dart
// Advanced Task Management Screen
//
// Requirements:
// 1. class TasksPage extends StatefulWidget:
//    - Full CRUD UI for Task items.
//    - Integrates TaskListSelector, TaskListView, and TaskEditDialog.
//    - Supports sorting by priority, due date, or creation time.
//    - All DB operations via global taskRepo instance.

import 'package:flutter/material.dart';

import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';
import '../../widgets/task/task_edit_dialog.dart';
import '../../widgets/task/task_list.dart';
import '../../widgets/task/task_list_selector.dart';

/// Main task management page with full CRUD functionality.
/// Displays tasks from the selected list with sorting options.
/// All database operations are performed via the global taskRepo instance.
class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  // Currently selected task list (acts as global cursor)
  TaskList? _selectedList;

  // Whether to show archived tasks
  bool _showArchived = false;

  // Current sort mode: 'priority', 'dueSoon', or 'creationTime'
  String _sortBy = 'creationTime';

  // Sort direction: true = ascending, false = descending
  bool _isAscending = true;

  // Currently loaded incomplete tasks
  List<Task> _incompleteTasks = [];

  // Currently loaded completed tasks
  List<Task> _completedTasks = [];

  // Loading state
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  /// Initializes the page by loading the default task list.
  Future<void> _initialize() async {
    final lists = await taskRepo.getTaskLists();
    if (lists.isNotEmpty) {
      // Select default list if available, otherwise first list
      _selectedList = lists.firstWhere(
        (l) => l.isDefault,
        orElse: () => lists.first,
      );
      await _loadTasks();
    }
    if (mounted) setState(() => _isLoading = false);
  }

  /// Loads tasks for the selected list with current sort settings.
  Future<void> _loadTasks() async {
    // Load incomplete and completed tasks separately
    final results = await Future.wait([
      taskRepo.getFilteredTasks(
        _selectedList?.name ?? '',
        _sortBy,
        isAscending: _isAscending,
        isCompleted: false,
        isArchived: _showArchived,
      ),
      taskRepo.getFilteredTasks(
        _selectedList?.name ?? '',
        _sortBy,
        isAscending: _isAscending,
        isCompleted: true,
        isArchived: _showArchived,
      ),
    ]);
    _incompleteTasks = results[0];
    _completedTasks = results[1];
    if (mounted) setState(() {});
  }

  /// Opens the TaskEditDialog for creating a new task.
  void _openAddTask() {
    showDialog(
      context: context,
      builder: (ctx) => TaskEditDialog(selectedList: _selectedList),
    ).then((_) => _loadTasks());
  }

  /// Opens the TaskEditDialog for editing an existing task.
  void _openEditTask(Task task) {
    showDialog(
      context: context,
      builder: (ctx) =>
          TaskEditDialog(existingTask: task, selectedList: _selectedList),
    ).then((_) => _loadTasks());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Top bar with list selector and sort controls
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              ElevatedButton(
                onPressed: _openAddTask,
                child: Row(
                  children: [
                    const Icon(Icons.add),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Task list selector with archived button
              TaskListSelector(
                selectedList: _showArchived ? null : _selectedList,
                onListSelected: (list) {
                  setState(() {
                    _showArchived = false;
                    _selectedList = list;
                  });
                  _loadTasks();
                },
                onListChanged: _loadTasks,
                onArchivedToggled: () {
                  setState(() => _showArchived = true);
                  _loadTasks();
                },
              ),
              const Spacer(),
              // Sort by dropdown
              DropdownButton<String>(
                value: _sortBy,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'creationTime', child: Text('Date')),
                  DropdownMenuItem(value: 'priority', child: Text('Priority')),
                  DropdownMenuItem(value: 'dueSoon', child: Text('Urgency')),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _sortBy = v);
                    _loadTasks();
                  }
                },
              ),
              const SizedBox(width: 4),
              // Sort direction toggle
              IconButton(
                icon: Icon(
                  _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                ),
                onPressed: () {
                  setState(() => _isAscending = !_isAscending);
                  _loadTasks();
                },
                tooltip: _isAscending ? 'Ascending' : 'Descending',
              ),
            ],
          ),
        ),
        // Task list view
        Expanded(
          child: TaskListView(
            incompleteTasks: _incompleteTasks,
            completedTasks: _completedTasks,
            onEditTask: _openEditTask,
            onTaskChanged: _loadTasks,
          ),
        ),
      ],
    );
  }
}
