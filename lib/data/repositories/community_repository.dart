// File: lib/data/repositories/community_repository.dart
// TODO: Implement Remote Templates Access
// Architecture: Uses `SupabaseClient` instance. Abstract interface for clean testing.
// Requirements:
// 1. Methods:
//    - `Future<List<CommunityTemplate>> fetchTemplates(TemplateType type, int page, int limit)`
//    - `Future<void> uploadTemplate(CommunityTemplate data)` (Uploads require minimal anonymous Auth).
//    - `Future<void> reportTemplate(String id)` (FR-39).
import 'dart:convert';
import '../db/supabase_client.dart';
import '../models/community_template.dart';
import '../models/task.dart';
import '../models/flash_card.dart';

class CommunityRepository
{
  final _supabase = SupabaseService().client;

  Future<List<CommunityTemplate>> fetchTemplates(
    TemplateType type,
    int page,
    int limit,
  ) async
  {
    final from = page * limit;
    final to = from + limit - 1;

    final response = await _supabase
        .from('community_templates')
        .select()
        .eq('type', type.name)
        .order('downloads', ascending: false)
        .range(from, to);

    return (response as List)
        .map((e) => CommunityTemplate.fromJson(e))
        .toList();
  }

  Future<void> uploadTemplate(CommunityTemplate data) async
  {
    // privacy: only safe fields already included
    await _supabase
        .from('community_templates')
        .insert(data.toJson());
  }

  Future<void> reportTemplate(String id) async
  {
    await _supabase
        .from('community_templates')
        .update({'reported': true})
        .eq('id', id);
  }

  // -------- Helpers (IMPORTANT) --------

  String buildTodoPayload(List<Task> tasks)
  {
    final payload = {
      "tasks": tasks.map((t) => { //TODO : add name and other metadata like upload.
        "title": t.title,
        "description": t.description,
        "priority": t.priority.name,
      }).toList()
    };

    return jsonEncode(payload);
  }

  String buildFlashcardPayload(
    List<FlashCard> cards,
  )
  {
    final payload = { //TODO : add name for the deck     
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
    required String jsonPayload,
  }) async
  {
    final template = CommunityTemplate(
      id: '',
      type: type,
      title: title,
      authorName: authorName,
      downloads: 0,
      starRating: 0,
      jsonPayload: jsonPayload,
    );

    await uploadTemplate(template);
  }
}
