import 'package:flutter/material.dart';

import 'package:must_stay_focused/style/buttons.dart';
import 'package:must_stay_focused/style/containers.dart';
import 'package:must_stay_focused/style/dialogs.dart';
import 'package:must_stay_focused/style/forms.dart';
import 'package:must_stay_focused/style/list_tile.dart';
import 'package:must_stay_focused/style/picker.dart';
import 'package:must_stay_focused/style/switch.dart';
import 'package:must_stay_focused/style/theme.dart';
import 'package:must_stay_focused/utils/theme_helpers.dart';

import '../../data/models/community_template.dart';
import '../../data/models/flash_card.dart';
import '../../data/models/task.dart';
import '../../data/repositories/flashcard_repository.dart';
import '../../data/repositories/task_repository.dart';
import '../flashcard/deck_selector_dialog.dart';
import '../task/task_list_selector_dialog.dart';

/// Combined dialog for creating either a task or a flashcard.
/// Features a switch to toggle between the two modes, each with
/// its own selector (TaskList or Deck).
class CombinedEditDialog extends StatefulWidget {
  const CombinedEditDialog({super.key});

  @override
  State<CombinedEditDialog> createState() => _CombinedEditDialogState();
}

class _CombinedEditDialogState extends State<CombinedEditDialog> {
  String _selectedType = CommunityTemplateType.taskList;
  TaskList? _selectedTaskList;
  Deck? _selectedDeck;

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _frontController = TextEditingController();
  final _backController = TextEditingController();

  TaskPriority _priority = TaskPriority.medium;
  DateTime? _startTime;
  DateTime? _endTime;
  List<int> _selectedDays = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDefaultSelections();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _frontController.dispose();
    _backController.dispose();
    super.dispose();
  }

  Future<void> _loadDefaultSelections() async {
    try {
      final taskLists = await taskRepo.getTaskLists();
      final decks = await flashcardRepo.getAllDecks();
      if (!mounted) return;

      setState(() {
        if (taskLists.isNotEmpty) {
          _selectedTaskList = taskLists.first;
        }
        if (decks.isNotEmpty) {
          _selectedDeck = decks.first;
        }
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('CombinedEditDialog _loadDefaultSelections error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool get _isTaskList => _selectedType == CommunityTemplateType.taskList;

  Future<void> _showTaskListSelector() async {
    final selected = await showDialog<TaskList>(
      context: context,
      builder: (ctx) => TaskListSelectorDialog(selectedList: _selectedTaskList),
    );
    if (selected != null) {
      setState(() => _selectedTaskList = selected);
    }
  }

  Future<void> _showDeckSelector() async {
    final selected = await showDialog<Deck>(
      context: context,
      builder: (ctx) => DeckSelectorDialog(selectedDeck: _selectedDeck),
    );
    if (selected != null) {
      setState(() => _selectedDeck = selected);
    }
  }

  Future<void> _pickStartTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startTime ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startTime ?? DateTime.now()),
    );
    if (time == null || !mounted) return;

    setState(() {
      _startTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _pickEndTime() async {
    if (_startTime == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endTime ?? _startTime!),
    );
    if (time == null || !mounted) return;

    setState(() {
      _endTime = DateTime(
        _startTime!.year,
        _startTime!.month,
        _startTime!.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _openPriorityPicker() async {
    final selected = await showModalBottomSheet<TaskPriority>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Padding(
          padding: const EdgeInsets.all(AppElementSizes.spacingLg),
          child: GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: TaskPriority.values.map((priority) {
                return GlassListTile(
                  leading: Icon(
                    Icons.flag,
                    color: theme.colorScheme.onSurface,
                    size: 18,
                  ),
                  title: Text(
                    priority.name.toUpperCase(),
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                  trailing: priority == _priority
                      ? Icon(Icons.check, color: theme.colorScheme.primary)
                      : null,
                  onTap: () => Navigator.of(ctx).pop(priority),
                  isLast: priority == TaskPriority.values.last,
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    if (selected != null && mounted) {
      setState(() => _priority = selected);
    }
  }

  Future<void> _saveTask() async {
    final trimmedTitle = _titleController.text.trim();
    if (trimmedTitle.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Title is required')));
      }
      return;
    }

    if (_selectedTaskList == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Select a list')));
      }
      return;
    }

    try {
      final task = Task();
      task.title = trimmedTitle;
      task.description = _descController.text.isEmpty
          ? null
          : _descController.text;
      task.priority = _priority;
      task.startTime = _startTime;
      task.endTime = _endTime;
      task.days = _selectedDays.isEmpty ? null : _selectedDays;
      task.taskList.value = _selectedTaskList;
      task.creationTime = DateTime.now();

      await taskRepo.upsertTask(task);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _saveFlashcard() async {
    final front = _frontController.text.trim();
    final back = _backController.text.trim();
    if (front.isEmpty || back.isEmpty) return;

    if (_selectedDeck == null) return;

    final card = FlashCard.make(
      front: front,
      back: back,
      deck: _selectedDeck!,
      creationDate: DateTime.now(),
    );

    await flashcardRepo.upsertFlashCard(card);
    if (mounted) Navigator.pop(context);
  }

  String _timeLabel(DateTime? value, String fallback) {
    if (value == null) return fallback;
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassDialog(
      maxWidth: 460,
      title: _isTaskList ? 'New Task' : 'New Flashcard',
      content: _isLoading
          ? const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          : SizedBox(
              height: getScreenHeight(context) * 0.4,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Switch row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Task',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontSize: AppTextSizes.body,
                          ),
                        ),
                        const SizedBox(width: AppElementSizes.spacingSm),
                        GlassSwitch(
                          value: !_isTaskList,
                          onChanged: (value) {
                            setState(() {
                              _selectedType = value
                                  ? CommunityTemplateType.flashCard
                                  : CommunityTemplateType.taskList;
                            });
                          },
                          activeColor: theme.colorScheme.primary,
                          inactiveColor: theme.colorScheme.primary.withValues(
                            alpha: 0.25,
                          ),
                        ),
                        const SizedBox(width: AppElementSizes.spacingSm),
                        Text(
                          'FlashCard',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontSize: AppTextSizes.body,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppElementSizes.spacingMd),

                    // Selector: TaskList or Deck
                    if (_isTaskList)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppElementSizes.spacingMd,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Task list',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.88,
                                  ),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            GlassPicker(
                              width: 160,
                              height: 36,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              value: _selectedTaskList?.name ?? 'Default',
                              textStyle: TextStyle(
                                fontSize: AppTextSizes.small,
                                color: theme.colorScheme.onSurface,
                              ),
                              placeholderStyle: TextStyle(
                                fontSize: AppTextSizes.small,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.65,
                                ),
                              ),
                              icon: Icon(
                                Icons.expand_more,
                                size: 14,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.85,
                                ),
                              ),
                              onTap: _showTaskListSelector,
                            ),
                          ],
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppElementSizes.spacingMd,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Deck',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.88,
                                  ),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            GlassPicker(
                              width: 160,
                              height: 36,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              value: _selectedDeck?.name ?? 'Default',
                              textStyle: TextStyle(
                                fontSize: AppTextSizes.small,
                                color: theme.colorScheme.onSurface,
                              ),
                              placeholderStyle: TextStyle(
                                fontSize: AppTextSizes.small,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.65,
                                ),
                              ),
                              icon: Icon(
                                Icons.expand_more,
                                size: 14,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.85,
                                ),
                              ),
                              onTap: _showDeckSelector,
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: AppElementSizes.spacingMd),

                    // Task-specific fields
                    if (_isTaskList) ...[
                      GlassTextField(
                        controller: _titleController,
                        placeholder: 'Title *',
                      ),
                      const SizedBox(height: AppElementSizes.spacingMd),
                      GlassTextField(
                        controller: _descController,
                        placeholder: 'Description',
                        maxLines: 3,
                      ),
                      const SizedBox(height: AppElementSizes.spacingMd),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppElementSizes.spacingMd,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Priority',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.88,
                                  ),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            GlassPicker(
                              width: 160,
                              height: 36,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              value: _priority.name,
                              textStyle: TextStyle(
                                fontSize: AppTextSizes.small,
                                color: theme.colorScheme.onSurface,
                              ),
                              placeholderStyle: TextStyle(
                                fontSize: AppTextSizes.small,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.65,
                                ),
                              ),
                              icon: Icon(
                                Icons.expand_more,
                                size: 14,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.85,
                                ),
                              ),
                              onTap: _openPriorityPicker,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppElementSizes.spacingMd),
                      
                      Row(
                        children: [
                          Expanded(
                            child: GlassSquircleButton(
                              isPrimary: true,
                              onPressed: _pickStartTime,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 16,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      _timeLabel(_startTime, 'Start time'),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: AppTextSizes.small,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: AppElementSizes.spacingSm),
                          Expanded(
                            child: GlassSquircleButton(
                              isPrimary: true,
                              onPressed: _startTime != null
                                  ? _pickEndTime
                                  : null,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 16,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      _timeLabel(_endTime, 'End time'),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: AppTextSizes.small,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Flashcard-specific fields
                    if (!_isTaskList) ...[
                      GlassTextField(
                        controller: _frontController,
                        placeholder: 'Front (Question)',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      GlassTextField(
                        controller: _backController,
                        placeholder: 'Back (Answer)',
                        maxLines: 3,
                      ),
                    ],
                  ],
                ),
              ),
            ),
      actions: [
        GlassDialogAction(
          label: 'Cancel',
          onPressed: () => Navigator.pop(context),
        ),
        GlassDialogAction(
          label: _isTaskList ? 'Save Task' : 'Save Card',
          isPrimary: true,
          onPressed: _isTaskList ? _saveTask : _saveFlashcard,
        ),
      ],
    );
  }
}
