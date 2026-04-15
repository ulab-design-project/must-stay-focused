import '../db/supabase_client.dart';
import 'community_template_remote_service.dart';

class DeckService {
  static const String _communityType = 'flashcard';
  final CommunityTemplateRemoteService _communityRemoteService;

  DeckService({CommunityTemplateRemoteService? communityRemoteService})
    : _communityRemoteService =
          communityRemoteService ?? CommunityTemplateRemoteService();

  Future<List<Map<String, dynamic>>> getAll() async {
    try {
      final data = await sdb.client.from('decks').select();
      return List<Map<String, dynamic>>.from(data);
    } catch (e, stackTrace) {
      throw Exception('DeckService getAll failed: $e\n$stackTrace');
    }
  }

  Future<void> create(Map<String, dynamic> row) async {
    try {
      await sdb.client.from('decks').insert(row);
    } catch (e, stackTrace) {
      throw Exception('DeckService create failed: $e\n$stackTrace');
    }
  }

  Future<void> update(String id, Map<String, dynamic> row) async {
    try {
      await sdb.client.from('decks').update(row).eq('id', id);
    } catch (e, stackTrace) {
      throw Exception('DeckService update failed: $e\n$stackTrace');
    }
  }

  Future<void> delete(String id) async {
    try {
      await sdb.client.from('decks').delete().eq('id', id);
    } catch (e, stackTrace) {
      throw Exception('DeckService delete failed: $e\n$stackTrace');
    }
  }

  Future<List<Map<String, dynamic>>> fetchCommunityTemplates({
    required String sortBy,
    List<String>? tags,
  }) async {
    try {
      return await _communityRemoteService.fetchTemplates(
        type: _communityType,
        sortBy: sortBy,
        tags: tags,
      );
    } catch (e, stackTrace) {
      throw Exception(
        'DeckService fetchCommunityTemplates failed: $e\n$stackTrace',
      );
    }
  }

  Future<Map<String, dynamic>?> fetchCommunityTemplateById(String id) async {
    try {
      return await _communityRemoteService.fetchTemplateById(
        type: _communityType,
        id: id,
      );
    } catch (e, stackTrace) {
      throw Exception(
        'DeckService fetchCommunityTemplateById failed: $e\n$stackTrace',
      );
    }
  }

  Future<void> uploadCommunityTemplate(Map<String, dynamic> row) async {
    try {
      await _communityRemoteService.uploadTemplate(row);
    } catch (e, stackTrace) {
      throw Exception(
        'DeckService uploadCommunityTemplate failed: $e\n$stackTrace',
      );
    }
  }

  Future<void> incrementCommunityTemplateDownloads(String id) async {
    try {
      await _communityRemoteService.incrementDownloads(
        type: _communityType,
        id: id,
      );
    } catch (e, stackTrace) {
      throw Exception(
        'DeckService incrementCommunityTemplateDownloads failed: $e\n$stackTrace',
      );
    }
  }
}
