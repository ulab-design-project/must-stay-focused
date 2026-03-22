// File: lib/data/repositories/community_repository.dart
// TODO: Implement Remote Templates Access
// Architecture: Uses `SupabaseClient` instance. Abstract interface for clean testing.
// Requirements:
// 1. Methods:
//    - `Future<List<CommunityTemplate>> fetchTemplates(TemplateType type, int page, int limit)`
//    - `Future<void> uploadTemplate(CommunityTemplate data)` (Uploads require minimal anonymous Auth).
//    - `Future<void> reportTemplate(String id)` (FR-39).
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/community_template.dart';

class CommunityRepository
{
  final supabase = Supabase.instance.client;

  /// Fetch templates with type + pagination
  Future<List<CommunityTemplate>> fetchTemplates(
    TemplateType type,
    int page,
    int limit,
  ) async
  {
    final from = page * limit;
    final to = from + limit - 1;

    final response = await supabase
        .from('community_templates')
        .select()
        .eq('type', type.name)
        .order('downloads', ascending: false)
        .range(from, to);

    return (response as List)
        .map((e) => CommunityTemplate.fromJson(e))
        .toList();
  }

  /// Upload template
  Future<void> uploadTemplate(CommunityTemplate data) async
  {
    await supabase
        .from('community_templates')
        .insert(data.toJson());
  }

  /// Report template (simple version)
  Future<void> reportTemplate(String id) async
  {
    await supabase
        .from('community_templates')
        .update({'reported': true})
        .eq('id', id);
  }
}

//helper functions
//Convert Tasks → jsonPayload
Map<String, dynamic> buildTodoPayload(List<Task> tasks)
{
  return {
    "tasks": tasks.map((t) => {
      "title": t.title,
      "description": t.description,
      "priority": t.priority.name,
      "category": t.category.name,
      "isCompleted": false,
    }).toList()
  };
}

//Convert Deck + Cards → jsonPayload
Map<String, dynamic> buildFlashcardPayload(
  Deck deck,
  List<FlashCard> cards,
)
{
  return {
    "deck": {
      "name": deck.name,
      "subjectColorHex": deck.subjectColorHex,
    },
    "cards": cards.map((c) => {
      "frontText": c.frontText,
      "backText": c.backText,
    }).toList()
  };
}

//Upload TODO template
Future<void> uploadTodoTemplate({
  required String title,
  required String authorName,
  required List<Task> tasks,
}) async
{
  final payload = buildTodoPayload(tasks);

  final template = CommunityTemplate(
    id: '', // Supabase will generate
    type: TemplateType.todoList,
    title: title,
    authorName: authorName,
    downloads: 0,
    starRating: 0,
    jsonPayload: payload,
  );

  await uploadTemplate(template);
}

//Upload FLASHCARD template
Future<void> uploadFlashcardTemplate({
  required String title,
  required String authorName,
  required Deck deck,
  required List<FlashCard> cards,
}) async
{
  final payload = buildFlashcardPayload(deck, cards);

  final template = CommunityTemplate(
    id: '',
    type: TemplateType.flashcardDeck,
    title: title,
    authorName: authorName,
    downloads: 0,
    starRating: 0,
    jsonPayload: payload,
  );

  await uploadTemplate(template);
}
