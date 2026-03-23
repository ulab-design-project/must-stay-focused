// File: lib/data/db/supabase_client.dart
// TODO: Setup Remote Database Client
// Architecture: Singleton/Provider for initialized Supabase.
// Requirements:
// 1. `class SupabaseService`:
//    - Method: `Future<void> init()` reading URL and ANON_KEY from Env configs.
//    - Warning: Strictly configured to reject storing any primary user behavioral data (NFR-07 Privacy by Design rule).


//note: 'reject storing primary user behavioral data' has not been implemented here. it should be implemented in lib/data/repository
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService
{
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService()
  {
    return _instance;
  }

  SupabaseService._internal();

  Future<void> init() async
  {
    const url = String.fromEnvironment('SUPABASE_URL');
    const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

    if (url.isEmpty || anonKey.isEmpty)
    {
      throw Exception('Supabase env variables not set');
    }

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }

  SupabaseClient get client => Supabase.instance.client;
}
