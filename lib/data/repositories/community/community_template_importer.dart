import 'package:flutter/material.dart';

import '../../models/community_template.dart';
import '../../models/flash_card.dart';
import '../../models/task.dart';
import '../flashcard_repository.dart';
import '../task_repository.dart';

class CommunityTemplateImporter {
  Future<void> importTaskListTemplate(CommunityTemplate template) async {
    try {
      final importedList = TaskList()
        ..name = template.title
        ..tags = template.tags.isEmpty
            ? <String>['community']
            : List<String>.from(template.tags)
        ..iconCodePoint = Icons.download.codePoint
        ..isDefault = false;

      await taskRepo.upsertTaskList(importedList);

      final rawTasks = (template.payload['tasks'] as List?) ?? <dynamic>[];

      for (final rawTask in rawTasks) {
        final taskMap = Map<String, dynamic>.from(rawTask as Map);
        final task = Task()
          ..title = (taskMap['title'] ?? 'Untitled Task').toString()
          ..description = taskMap['description']?.toString()
          ..priority = _parsePriority(taskMap['priority']?.toString())
          ..startTime = DateTime.tryParse(
            (taskMap['start_time'] ?? '').toString(),
          )
          ..endTime = DateTime.tryParse((taskMap['end_time'] ?? '').toString())
          ..days = (taskMap['days'] as List?)
              ?.map((day) => (day as num).toInt())
              .toList()
          ..creationTime = DateTime.now()
          ..isCompleted = false
          ..isArchived = false;

        task.taskList.value = importedList;
        await taskRepo.upsertTask(task);
      }
    } catch (e, stackTrace) {
      throw Exception(
        'CommunityTemplateImporter importTaskListTemplate failed: $e\n$stackTrace',
      );
    }
  }

  Future<void> importFlashCardTemplate(CommunityTemplate template) async {
    try {
      final importedDeck = Deck()
        ..name = template.title
        ..description = template.description
        ..tags = template.tags.isEmpty
            ? <String>['community']
            : List<String>.from(template.tags);

      await flashcardRepo.upsertDeck(importedDeck);

      final rawCards = (template.payload['cards'] as List?) ?? <dynamic>[];

      for (final rawCard in rawCards) {
        final cardMap = Map<String, dynamic>.from(rawCard as Map);
        final card = FlashCard()
          ..front = (cardMap['front'] ?? '').toString()
          ..back = (cardMap['back'] ?? '').toString()
          ..creationDate = DateTime.now()
          ..nextReviewDate = DateTime.now();

        card.deck.value = importedDeck;
        await flashcardRepo.upsertFlashCard(card);
      }
    } catch (e, stackTrace) {
      throw Exception(
        'CommunityTemplateImporter importFlashCardTemplate failed: $e\n$stackTrace',
      );
    }
  }

  TaskPriority _parsePriority(String? rawPriority) {
    switch (rawPriority) {
      case 'critical':
        return TaskPriority.critical;
      case 'high':
        return TaskPriority.high;
      case 'low':
        return TaskPriority.low;
      default:
        return TaskPriority.medium;
    }
  }
}
