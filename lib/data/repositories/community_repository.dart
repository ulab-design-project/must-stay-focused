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

