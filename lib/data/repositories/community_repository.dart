// File: lib/data/repositories/community_repository.dart
// Remote Templates Access
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../db/supabase_client.dart';
import '../models/community_template.dart';
import '../models/task.dart';
import '../models/flash_card.dart';

class CommunityRepository {
  final _supabase = SupabaseService().client;

  Future<List<CommunityTemplate>> fetchTemplates(
    TemplateType type, {
    int page = 0,
    int limit = 20,
    String? searchQuery,
    List<String>? tags,
    String sortBy = 'downloads',
    bool ascending = false,
  }) async {
    try {
      final from = page * limit;
      final to = from + limit - 1;

      dynamic query = _supabase
          .from('community_templates')
          .select();
      
      query = query.eq('type', type.name);

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('title', '%$searchQuery%');
      }

      if (tags != null && tags.isNotEmpty) {
        query = query.contains('tags', tags);
      }

      query = query.order(sortBy, ascending: ascending).range(from, to);

      final response = await query;

      return (response as List)
          .map((e) => CommunityTemplate.fromJson(e))
          .toList();
    } catch (e, stackTrace) {
      debugPrint('CommunityRepository fetchTemplates error: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> uploadTemplate(CommunityTemplate data) async {
    try {
      await _supabase
          .from('community_templates')
          .insert(data.toJson());
    } catch (e, stackTrace) {
      debugPrint('CommunityRepository uploadTemplate error: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> reportTemplate(String id) async {
    try {
      await _supabase
          .from('community_templates')
          .update({'reported': true})
          .eq('id', id);
    } catch (e, stackTrace) {
      debugPrint('CommunityRepository reportTemplate error: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> incrementDownloads(String id) async {
    try {
      // await _supabase
      //     .from('community_templates')
      //     .update({'downloads': raw('downloads + 1')})
      //     .eq('id', id);
    } catch (e, stackTrace) {
      debugPrint('CommunityRepository incrementDownloads error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  String buildTodoPayload(List<Task> tasks) {
    final payload = {
      "tasks": tasks.map((t) => {
        "title": t.title,
        "description": t.description,
        "priority": t.priority.name,
      }).toList()
    };

    return jsonEncode(payload);
  }

  String buildFlashcardPayload(List<FlashCard> cards) {
    final payload = {
      "cards": cards.map((c) => {
        "frontText": c.front,
        "backText": c.back,
      }).toList()
    };

    return jsonEncode(payload);
  }

  Future<void> uploadTemplateRaw({
    required TemplateType type,
    required String title,
    required String authorName,
    required String description,
    required String jsonPayload,
    List<String> tags = const [],
  }) async {
    final template = CommunityTemplate(
      id: '',
      type: type,
      title: title,
      authorName: authorName,
      downloads: 0,
      starRating: 0,
      jsonPayload: jsonPayload,
      tags: tags,
      description: description,
    );

    await uploadTemplate(template);
  }
}