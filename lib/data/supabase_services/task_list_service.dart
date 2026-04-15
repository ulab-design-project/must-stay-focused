import '../db/supabase_client.dart';
import 'community_template_remote_service.dart';

class TaskListService {
  static const String _communityType = 'tasklist';
  final CommunityTemplateRemoteService _communityRemoteService;

  TaskListService({CommunityTemplateRemoteService? communityRemoteService})
    : _communityRemoteService =
          communityRemoteService ?? CommunityTemplateRemoteService();

  Future<List<Map<String, dynamic>>> getAll() async {
    try {
      final data = await sdb.client.from('task_lists').select();
      return List<Map<String, dynamic>>.from(data);
    } catch (e, stackTrace) {
      throw Exception('TaskListService getAll failed: $e\n$stackTrace');
    }
  }

  Future<void> create(Map<String, dynamic> row) async {
    try {
      await sdb.client.from('task_lists').insert(row);
    } catch (e, stackTrace) {
      throw Exception('TaskListService create failed: $e\n$stackTrace');
    }
  }

  Future<void> update(String id, Map<String, dynamic> row) async {
    try {
      await sdb.client.from('task_lists').update(row).eq('id', id);
    } catch (e, stackTrace) {
      throw Exception('TaskListService update failed: $e\n$stackTrace');
    }
  }

  Future<void> delete(String id) async {
    try {
      await sdb.client.from('task_lists').delete().eq('id', id);
    } catch (e, stackTrace) {
      throw Exception('TaskListService delete failed: $e\n$stackTrace');
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
        'TaskListService fetchCommunityTemplates failed: $e\n$stackTrace',
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
        'TaskListService fetchCommunityTemplateById failed: $e\n$stackTrace',
      );
    }
  }

  Future<void> uploadCommunityTemplate(Map<String, dynamic> row) async {
    try {
      await _communityRemoteService.uploadTemplate(row);
    } catch (e, stackTrace) {
      throw Exception(
        'TaskListService uploadCommunityTemplate failed: $e\n$stackTrace',
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
        'TaskListService incrementCommunityTemplateDownloads failed: $e\n$stackTrace',
      );
    }
  }
}
