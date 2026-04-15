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
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';
import '../../style/buttons.dart';
import '../../style/theme.dart';
import '../../widgets/task/task_edit_dialog.dart';
import '../../widgets/task/task_list.dart';
import '../../widgets/task/task_list_selector.dart';

/// Main task management page with full CRUD functionality.
/// Displays tasks from the selected list with sorting options.
/// All database operations are performed via the global taskRepo instance.
class TasksPage extends StatefulWidget {
  final bool interceptionMode;

  const TasksPage({super.key, this.interceptionMode = false});

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

  // Last task moved into completed list (used for entry animation)
  int? _animatedCompletedTaskId;

  @override
  void initState() {
    super.initState();
    if (widget.interceptionMode) {
      _applyInterceptionDefaultSort();
    }
    _initialize();
  }

  @override
  void didUpdateWidget(covariant TasksPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.interceptionMode && widget.interceptionMode) {
      _applyInterceptionDefaultSort();
    }
    if (oldWidget.interceptionMode != widget.interceptionMode) {
      _loadTasks();
    }
  }

  void _applyInterceptionDefaultSort() {
    _sortBy = 'priority';
    _isAscending = false;
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

  String get _sortByLabel {
    switch (_sortBy) {
      case 'creationTime':
        return 'Date';
      case 'priority':
        return 'Priority';
      case 'dueSoon':
        return 'Urgency';
      default:
        return _sortBy;
    }
  }

  Future<void> _openSortPicker() async {
    try {
      final selected = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          const options = [
            ('Date', 'creationTime'),
            ('Priority', 'priority'),
            ('Urgency', 'dueSoon'),
          ];

          return Padding(
            padding: const EdgeInsets.all(AppElementSizes.spacingLg),
            child: GlassCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...options.map((option) {
                    final isSelected = _sortBy == option.$2;
                    return GlassListTile(
                      title: Text(
                        option.$1,
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: Colors.white)
                          : null,
                      onTap: () => Navigator.of(context).pop(option.$2),
                      isLast: option == options.last,
                    );
                  }),
                ],
              ),
            ),
          );
        },
      );

      if (selected == null || !mounted) {
        return;
      }

      setState(() => _sortBy = selected);
      await _loadTasks();
    } catch (e, stackTrace) {
      debugPrint('TasksPage _openSortPicker error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _handleTaskChanged(Task task) async {
    try {
      if (mounted) {
        setState(() {
          _animatedCompletedTaskId = task.isCompleted ? task.id : null;
        });
      }

      await _loadTasks();

      if (task.isCompleted) {
        await Future.delayed(const Duration(milliseconds: 320));
        if (mounted && _animatedCompletedTaskId == task.id) {
          setState(() => _animatedCompletedTaskId = null);
        }
      }
    } catch (e, stackTrace) {
      debugPrint('TasksPage _handleTaskChanged error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return AdaptiveLiquidGlassLayer(
      child: Column(
        children: [
          // Top bar with list selector and sort controls
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                GlassSquircleIconButton(
                  onPressed: _openAddTask,
                  icon: Icon(Icons.add, color: theme.colorScheme.onSurface),
                  isPrimary: true,
                ),
                const SizedBox(width: AppElementSizes.spacingSm),
                Expanded(
                  child: TaskListSelector(
                    width: 100,
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
                ),
                const SizedBox(width: AppElementSizes.spacingSm),
                GlassPicker(
                  width: 100,
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  value: _sortByLabel,
                  placeholder: 'Sort',
                  textStyle: TextStyle(
                    fontSize: AppTextSizes.small,
                    color: theme.colorScheme.onSurface,
                  ),
                  // placeholderStyle: TextStyle(
                  //   fontSize: AppTextSizes.small,
                  //   color: Colors.pink,
                  // ),
                  icon: Icon(
                    Icons.expand_more,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                  ),
                  onTap: _openSortPicker,
                ),
                const SizedBox(width: AppElementSizes.spacingSm),
                GlassSquircleIconButton(
                  onPressed: () {
                    setState(() => _isAscending = !_isAscending);
                    _loadTasks();
                  },
                  icon: Icon(
                    _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          // Task list view
          Expanded(
            child: TaskListView(
              incompleteTasks: _incompleteTasks,
              completedTasks: _completedTasks,
              interceptionMode: widget.interceptionMode,
              onEditTask: _openEditTask,
              onTaskChanged: _handleTaskChanged,
              animatedCompletedTaskId: _animatedCompletedTaskId,
            ),
          ),
        ],
      ),
    );
  }
}
