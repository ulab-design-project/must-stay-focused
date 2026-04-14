import 'package:supabase_flutter/supabase_flutter.dart';

class DeckService
{
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getAll() async
  {
    final data = await supabase
        .from('decks')
        .select();

    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> create(Map<String, dynamic> row) async
  {
    await supabase.from('decks').insert(row);
  }

  Future<void> update(String id, Map<String, dynamic> row) async
  {
    await supabase
        .from('decks')
        .update(row)
        .eq('id', id);
  }

  Future<void> delete(String id) async
  {
    await supabase
        .from('decks')
        .delete()
        .eq('id', id);
  }
}