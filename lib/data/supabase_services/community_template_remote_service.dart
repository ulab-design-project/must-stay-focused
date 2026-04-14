import '../db/supabase_client.dart';

class CommunityTemplateRemoteService {
  static const String tableName = 'community_templates';

  String _formatServiceError({
    required String action,
    required Object error,
    required StackTrace stackTrace,
  }) {
    final message = error.toString();

    if (message.contains('PGRST205') ||
        message.contains('public.community_templates')) {
      return 'CommunityTemplateRemoteService $action failed: table public.community_templates is missing in Supabase schema cache. Run `dart run tool/reset_seed_supabase.dart` after setting SUPABASE_DB_URL. Original error: $error\n$stackTrace';
    }

    if (message.contains('42501') ||
        message.toLowerCase().contains('permission denied') ||
        message.toLowerCase().contains('row-level security')) {
      return 'CommunityTemplateRemoteService $action failed: Supabase denied access to public.community_templates. Re-run `dart run tool/reset_seed_supabase.dart` to apply GRANTs and disable RLS for community templates. Original error: $error\n$stackTrace';
    }

    return 'CommunityTemplateRemoteService $action failed: $error\n$stackTrace';
  }

  Future<List<Map<String, dynamic>>> fetchTemplates({
    required String type,
    required String sortBy,
    List<String>? tags,
  }) async {
    try {
      final orderColumn = sortBy == 'downloads' ? 'downloads' : 'created_at';
      dynamic query = sdb.client
          .from(tableName)
          .select()
          .eq('type', type)
          .order(orderColumn, ascending: false);

      if (tags != null && tags.isNotEmpty) {
        query = query.contains('tags', tags);
      }

      final rows = await query;
      return List<Map<String, dynamic>>.from(rows);
    } catch (e, stackTrace) {
      throw Exception(
        _formatServiceError(
          action: 'fetchTemplates',
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<Map<String, dynamic>?> fetchTemplateById({
    required String type,
    required String id,
  }) async {
    try {
      final row = await sdb.client
          .from(tableName)
          .select()
          .eq('type', type)
          .eq('id', id)
          .maybeSingle();

      if (row == null) {
        return null;
      }

      return Map<String, dynamic>.from(row);
    } catch (e, stackTrace) {
      throw Exception(
        _formatServiceError(
          action: 'fetchTemplateById',
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<void> uploadTemplate(Map<String, dynamic> row) async {
    try {
      await sdb.client.from(tableName).insert(row);
    } catch (e, stackTrace) {
      throw Exception(
        _formatServiceError(
          action: 'uploadTemplate',
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<void> incrementDownloads({
    required String type,
    required String id,
  }) async {
    try {
      final current = await sdb.client
          .from(tableName)
          .select('downloads')
          .eq('type', type)
          .eq('id', id)
          .maybeSingle();

      if (current == null) {
        throw StateError(
          'No $tableName row found for type=$type and id=$id while incrementing downloads.',
        );
      }

      final currentDownloads = (current['downloads'] as num?)?.toInt() ?? 0;

      await sdb.client
          .from(tableName)
          .update({'downloads': currentDownloads + 1})
          .eq('type', type)
          .eq('id', id);
    } catch (e, stackTrace) {
      throw Exception(
        _formatServiceError(
          action: 'incrementDownloads',
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
