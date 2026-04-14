import 'package:supabase_flutter/supabase_flutter.dart';

class TaskListService
{
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getAll() async
  {
    final data = await supabase
        .from('task_lists')
        .select();

    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> create(Map<String, dynamic> row) async
  {
    await supabase.from('task_lists').insert(row);
  }

  Future<void> update(String id, Map<String, dynamic> row) async
  {
    await supabase
        .from('task_lists')
        .update(row)
        .eq('id', id);
  }

  Future<void> delete(String id) async
  {
    await supabase
        .from('task_lists')
        .delete()
        .eq('id', id);
  }
}