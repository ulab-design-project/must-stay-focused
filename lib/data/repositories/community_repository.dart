import 'package:flutter/material.dart';

import 'community/community_payload_builder.dart';
import 'community/community_template_importer.dart';
import '../models/community_template.dart';
import '../models/flash_card.dart';
import '../models/task.dart';
import '../supabase_services/deck_service.dart';
import '../supabase_services/task_list_service.dart';

final CommunityRepository communityRepo = CommunityRepository();

class CommunityRepository {
  final TaskListService _taskListService;
  final DeckService _deckService;
  final CommunityPayloadBuilder _payloadBuilder;
  final CommunityTemplateImporter _templateImporter;

  CommunityRepository({
    TaskListService? taskListService,
    DeckService? deckService,
    CommunityPayloadBuilder? payloadBuilder,
    CommunityTemplateImporter? templateImporter,
  }) : _taskListService = taskListService ?? TaskListService(),
       _deckService = deckService ?? DeckService(),
       _payloadBuilder = payloadBuilder ?? CommunityPayloadBuilder(),
       _templateImporter = templateImporter ?? CommunityTemplateImporter();

  Future<List<CommunityTemplate>> fetchTemplates({
    required String type,
    String sortBy = 'recent',
    List<String>? tags,
  }) async {
    try {
      final serviceSortBy = sortBy == 'downloads' ? 'downloads' : 'recent';
      final rows = type == CommunityTemplateType.flashCard
          ? await _deckService.fetchCommunityTemplates(
              sortBy: serviceSortBy,
              tags: tags,
            )
          : await _taskListService.fetchCommunityTemplates(
              sortBy: serviceSortBy,
              tags: tags,
            );

      final templates = rows
          .map((row) => CommunityTemplate.fromJson(row))
          .toList();

      if (sortBy == 'downloads') {
        templates.sort((a, b) => b.downloads.compareTo(a.downloads));
      } else {
        templates.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }

      return templates;
    } catch (e, stackTrace) {
      debugPrint('CommunityRepository fetchTemplates error: $e');
      debugPrintStack(stackTrace: stackTrace);
      throw Exception('CommunityRepository fetchTemplates failed: $e');
    }
  }

  Future<CommunityTemplate?> fetchTemplateById({
    required String type,
    required String id,
  }) async {
    try {
      final row = type == CommunityTemplateType.flashCard
          ? await _deckService.fetchCommunityTemplateById(id)
          : await _taskListService.fetchCommunityTemplateById(id);

      if (row == null) {
        return null;
      }

      return CommunityTemplate.fromJson(row);
    } catch (e, stackTrace) {
      debugPrint('CommunityRepository fetchTemplateById error: $e');
      debugPrintStack(stackTrace: stackTrace);
      throw Exception('CommunityRepository fetchTemplateById failed: $e');
    }
  }

  Future<void> uploadTaskListTemplate({
    required TaskList taskList,
    required String authorName,
    required String description,
    required List<String> tags,
  }) async {
    try {
      final payload = await _payloadBuilder.buildTaskListPayload(taskList);
      final template = CommunityTemplate(
        id: '',
        type: CommunityTemplateType.taskList,
        title: taskList.name,
        authorName: authorName,
        description: description,
        tags: tags,
        downloads: 0,
        createdAt: DateTime.now(),
        payload: payload,
      );

      await _taskListService.uploadCommunityTemplate(template.toJson());
    } catch (e, stackTrace) {
      debugPrint('CommunityRepository uploadTaskListTemplate error: $e');
      debugPrintStack(stackTrace: stackTrace);
      throw Exception('CommunityRepository uploadTaskListTemplate failed: $e');
    }
  }

  Future<void> uploadFlashCardTemplate({
    required Deck deck,
    required String authorName,
    required String description,
    required List<String> tags,
  }) async {
    try {
      final payload = await _payloadBuilder.buildFlashCardPayload(deck);
      final template = CommunityTemplate(
        id: '',
        type: CommunityTemplateType.flashCard,
        title: deck.name,
        authorName: authorName,
        description: description,
        tags: tags,
        downloads: 0,
        createdAt: DateTime.now(),
        payload: payload,
      );

      await _deckService.uploadCommunityTemplate(template.toJson());
    } catch (e, stackTrace) {
      debugPrint('CommunityRepository uploadFlashCardTemplate error: $e');
      debugPrintStack(stackTrace: stackTrace);
      throw Exception('CommunityRepository uploadFlashCardTemplate failed: $e');
    }
  }

  Future<void> downloadTemplate(CommunityTemplate template) async {
    try {
      if (template.isTaskList) {
        await _templateImporter.importTaskListTemplate(template);
        await _taskListService.incrementCommunityTemplateDownloads(template.id);
      } else {
        await _templateImporter.importFlashCardTemplate(template);
        await _deckService.incrementCommunityTemplateDownloads(template.id);
      }
    } catch (e, stackTrace) {
      debugPrint('CommunityRepository downloadTemplate error: $e');
      debugPrintStack(stackTrace: stackTrace);
      throw Exception('CommunityRepository downloadTemplate failed: $e');
    }
  }
}
