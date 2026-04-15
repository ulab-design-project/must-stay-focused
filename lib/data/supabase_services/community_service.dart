import 'package:supabase_flutter/supabase_flutter.dart';

class CommunityService
{
    final supabase = Supabase.instance.client;

    Future<void> uploadDeck({
        required String title,
        required String description,
        required String authorName,
        required List<String> tags,
        required Map<String, dynamic> jsonPayload,
    }) async
    {
        await supabase.from('community_templates').insert({
            'type': 'deck',
            'title': title,
            'description': description,
            'author_name': authorName,
            'tags': tags,
            'downloads': 0,
            'json_payload': jsonPayload,
        });
    }

    Future<void> uploadTaskList({
        required String title,
        required String description,
        required String authorName,
        required List<String> tags,
        required Map<String, dynamic> jsonPayload,
    }) async
    {
        await supabase.from('community_templates').insert({
            'type': 'task',
            'title': title,
            'description': description,
            'author_name': authorName,
            'tags': tags,
            'downloads': 0,
            'json_payload': jsonPayload,
        });
    }
}