import '../db/supabase_client.dart';

class ClientRepository
{
  final _supabase = SupabaseService().client;

  // ---------- TASKS ----------

  Future<List<Map<String, dynamic>>> fetchTasks(String userId) async
  {
    final response = await _supabase
        .from('tasks')
        .select()
        .eq('user_id', userId);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> insertTask(Map<String, dynamic> task) async
  {
    await _supabase.from('tasks').insert(task);
  }

  Future<void> deleteTask(String taskId) async
  {
    await _supabase.from('tasks').delete().eq('id', taskId);
  }

  // ---------- FLASHCARDS ----------

  Future<List<Map<String, dynamic>>> fetchFlashcards(String userId) async
  {
    final response = await _supabase
        .from('flashcards')
        .select()
        .eq('user_id', userId);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> insertFlashcard(Map<String, dynamic> card) async
  {
    await _supabase.from('flashcards').insert(card);
  }

  // ---------- USER SETTINGS (future use) ----------

  Future<Map<String, dynamic>?> getUserSettings(String userId) async
  {
    final response = await _supabase
        .from('user_settings')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    return response;
  }
}