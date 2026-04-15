import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../data/models/community_template.dart';
import '../../data/models/flash_card.dart';
import '../../data/models/task.dart';
import '../../data/repositories/community_repository.dart';
import '../../data/repositories/flashcard_repository.dart';
import '../../data/repositories/task_repository.dart';
import '../../style/buttons.dart';
import '../../style/theme.dart';
import '../flashcard/deck_selector.dart';
import '../task/task_list_selector.dart';

class TemplateUpload extends StatefulWidget {
  final VoidCallback? onUploaded;

  const TemplateUpload({super.key, this.onUploaded});

  @override
  State<TemplateUpload> createState() => _TemplateUploadState();
}

class _TemplateUploadState extends State<TemplateUpload> {
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedType = CommunityTemplateType.taskList;
  TaskList? _selectedTaskList;
  Deck? _selectedDeck;
  final List<String> _tags = <String>[];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadDefaultSelections();
  }

  @override
  void dispose() {
    _authorController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadDefaultSelections() async {
    try {
      final taskLists = await taskRepo.getTaskLists();
      final decks = await flashcardRepo.getAllDecks();
      if (!mounted) {
        return;
      }

      setState(() {
        if (taskLists.isNotEmpty) {
          _selectedTaskList = taskLists.first;
        }
        if (decks.isNotEmpty) {
          _selectedDeck = decks.first;
        }
      });
    } catch (e, stackTrace) {
      debugPrint('TemplateUpload _loadDefaultSelections error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _addTagDialog() async {
    try {
      final controller = TextEditingController();

      final tag = await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          return GlassDialog(
            title: 'Add Tag',
            content: GlassTextField(
              controller: controller,
              placeholder: 'Tag name',
              autofocus: true,
            ),
            actions: [
              GlassDialogAction(
                label: 'Cancel',
                onPressed: () => Navigator.pop(dialogContext),
              ),
              GlassDialogAction(
                label: 'Add',
                isPrimary: true,
                onPressed: () => Navigator.pop(dialogContext, controller.text),
              ),
            ],
          );
        },
      );

      final trimmedTag = tag?.trim();
      if (trimmedTag == null || trimmedTag.isEmpty || !mounted) {
        return;
      }

      if (_tags.contains(trimmedTag)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Tag already added.')));
        return;
      }

      setState(() => _tags.add(trimmedTag));
    } catch (e, stackTrace) {
      debugPrint('TemplateUpload _addTagDialog error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _uploadTemplate() async {
    if (_isUploading) {
      return;
    }

    final authorName = _authorController.text.trim();
    if (authorName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Author name is required.')));
      return;
    }

    try {
      setState(() => _isUploading = true);

      if (_selectedType == CommunityTemplateType.taskList) {
        if (_selectedTaskList == null) {
          throw Exception('No task list selected for upload.');
        }

        await communityRepo.uploadTaskListTemplate(
          taskList: _selectedTaskList!,
          authorName: authorName,
          description: _descriptionController.text.trim(),
          tags: List<String>.from(_tags),
        );
      } else {
        if (_selectedDeck == null) {
          throw Exception('No deck selected for upload.');
        }

        await communityRepo.uploadFlashCardTemplate(
          deck: _selectedDeck!,
          authorName: authorName,
          description: _descriptionController.text.trim(),
          tags: List<String>.from(_tags),
        );
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Template uploaded successfully.')),
      );
      _descriptionController.clear();
      setState(() => _tags.clear());
      widget.onUploaded?.call();
    } catch (e, stackTrace) {
      debugPrint('TemplateUpload _uploadTemplate error: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTaskList = _selectedType == CommunityTemplateType.taskList;

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(AppElementSizes.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'TaskList',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontSize: AppTextSizes.body,
                  ),
                ),
                const SizedBox(width: AppElementSizes.spacingSm),
                GlassSwitch(
                  value: !isTaskList,
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
            if (isTaskList)
              TaskListSelector(
                width: null,
                selectedList: _selectedTaskList,
                onListSelected: (list) =>
                    setState(() => _selectedTaskList = list),
                onListChanged: _loadDefaultSelections,
              )
            else
              DeckSelector(
                width: null,
                selectedDeck: _selectedDeck,
                onDeckSelected: (deck) => setState(() => _selectedDeck = deck),
                onDeckChanged: _loadDefaultSelections,
              ),
            const SizedBox(height: AppElementSizes.spacingMd),
            GlassTextField(
              controller: _authorController,
              placeholder: 'Author Name',
            ),
            const SizedBox(height: AppElementSizes.spacingSm),
            GlassTextField(
              controller: _descriptionController,
              placeholder: 'Description',
              maxLines: 3,
            ),
            const SizedBox(height: AppElementSizes.spacingSm),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _tags.length,
                      itemBuilder: (context, index) {
                        final tag = _tags[index];
                        return Padding(
                          padding: const EdgeInsets.only(
                            right: AppElementSizes.spacingXs,
                          ),
                          child: GlassChip(
                            label: tag,
                            selected: false,
                            onTap: () {
                              setState(() => _tags.removeAt(index));
                            },
                            icon: const Icon(Icons.close, size: 14),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: AppElementSizes.spacingSm),
                GlassSquircleIconButton(
                  onPressed: _addTagDialog,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const Spacer(),
            GlassSquircleButton(
              onPressed: _isUploading ? null : _uploadTemplate,
              isPrimary: true,
              width: 200,
              child: Text(
                _isUploading ? 'Uploading...' : 'Upload',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: AppTextSizes.body,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
