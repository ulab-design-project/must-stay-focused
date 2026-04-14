import 'package:uuid/uuid.dart';

import '../db/supabase_client.dart';

class UserService {
  dynamic get _db => sdb.client.from('app_users');

  Future<List<Map<String, dynamic>>> getUsers() async {
    final data = await _db.select();
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> addUser(String name, String email) async {
    final uuid = const Uuid();

    final id = uuid.v4();

    final res = await _db.insert({
      'id': id,
      'name': name,
      'email': email,
    }).select();

    print("SUCCESS INSERT: $res");
  }

  Future<void> deleteUser(String id) async {
    await _db.delete().eq('id', id);
  }
}
