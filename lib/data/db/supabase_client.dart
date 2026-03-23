// File: lib/data/db/supabase_client.dart
// TODO: Setup Remote Database Client
// Architecture: Singleton/Provider for initialized Supabase.
// Requirements:
// 1. `class SupabaseService`:
//    - Method: `Future<void> init()` reading URL and ANON_KEY from Env configs.
//    - Warning: Strictly configured to reject storing any primary user behavioral data (NFR-07 Privacy by Design rule).
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService
{
  static Future<void> init() async
  {
    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL'),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
