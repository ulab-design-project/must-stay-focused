import 'dart:convert';
import 'package:flutter/material.dart';

import '../../../data/models/community_template.dart';
import '../../../data/models/task.dart';
import '../../../data/models/flash_card.dart';
import '../../../data/repositories/community_repository.dart';
import '../../../style/theme.dart';
import '../../../style/cards.dart';
import '../../../style/textfield.dart';
import '../task/task_list_selector.dart';
import '../flashcard/deck_selector.dart';

class TemplateUpload extends StatefulWidget {
  final VoidCallback onUploadComplete;

  const TemplateUpload({
    super.key,
    required this.onUploadComplete,
  });

  @override
  State<TemplateUpload> createState() => _TemplateUploadState();
}

class _TemplateUploadState extends State<TemplateUpload> {
  final _communityRepository = CommunityRepository();
  TemplateType _selectedType = TemplateType.todoList;
  String _authorName = '';
  String _description = '';
  final List<String> _tags = [];
  final List<String> _availableTags = ['Productivity', 'Study', 'Workout', 'Mindfulness', 'Habit'];
  
  dynamic _selectedItem; // Either TaskList or Deck
  bool _isUploading = false;

  void _addTag() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add Tag'),
          content: GlassTextField(
            controller: controller,
            hintText: 'Tag name',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() => _tags.add(controller.text));
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadTemplate() async {
    if (_selectedItem == null || _authorName.isEmpty) return;

    setState(() => _isUploading = true);

    try {
      String payload;
      if (_selectedType == TemplateType.todoList) {
        payload = _communityRepository.buildTodoPayload(_selectedItem.tasks);
      } else {
        payload = _communityRepository.buildFlashcardPayload(_selectedItem.cards);
      }

      await _communityRepository.uploadTemplateRaw(
        type: _selectedType,
        title: _selectedItem.title,
        authorName: _authorName,
        description: _description,
        jsonPayload: payload,
        tags: _tags,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Template uploaded successfully!')),
        );
        widget.onUploadComplete();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppElementSizes.spacingLg),
      child: GlassCard(
        padding: const EdgeInsets.all(AppElementSizes.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upload Template',
                  style: TextStyle(
                    fontSize: AppTextSizes.h3,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Switch(
                  value: _selectedType == TemplateType.flashcardDeck,
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value ? TemplateType.flashcardDeck : TemplateType.todoList;
                      _selectedItem = null;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: AppElementSizes.spacingMd),
            Text(
              _selectedType == TemplateType.todoList
                  ? 'Select Task List'
                  : 'Select Flashcard Deck',
              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: AppElementSizes.spacingSm),
            if (_selectedType == TemplateType.todoList)
              TaskListSelector(
                onListSelected: (list) => setState(() => _selectedItem = list),
              )
            else
              DeckSelector(
                onDeckSelected: (deck) => setState(() => _selectedItem = deck),
              ),
            const SizedBox(height: AppElementSizes.spacingLg),
            GlassTextField(
              hintText: 'Your Name',
              onChanged: (value) => _authorName = value,
            ),
            const SizedBox(height: AppElementSizes.spacingMd),
            GlassTextField(
              hintText: 'Description',
              maxLines: 3,
              onChanged: (value) => _description = value,
            ),
            const SizedBox(height: AppElementSizes.spacingLg),
            Text(
              'Tags',
              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: AppElementSizes.spacingSm),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _tags.length + 1,
                itemBuilder: (context, index) {
                  if (index == _tags.length) {
                    return Padding(
                      padding: const EdgeInsets.only(right: AppElementSizes.spacingSm),
                      child: InkWell(
                        onTap: _addTag,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(child: Icon(Icons.add, size: 20)),
                        ),
                      ),
                    );
                  }

                  final tag = _tags[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: AppElementSizes.spacingSm),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(tag),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () => setState(() => _tags.removeAt(index)),
                            child: const Icon(Icons.close, size: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppElementSizes.spacingLg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _uploadTemplate,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, AppElementSizes.buttonHeight),
                ),
                child: _isUploading
                    ? const CircularProgressIndicator()
                    : const Text('Upload Template'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}