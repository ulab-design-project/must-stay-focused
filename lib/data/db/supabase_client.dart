// File: lib/data/db/supabase_client.dart
// TODO: Setup Remote Database Client
// Architecture: Singleton/Provider for initialized Supabase.
// Requirements:
// 1. `class SupabaseService`:
//    - Method: `Future<void> init()` reading URL and ANON_KEY from Env configs.
//    - Warning: Strictly configured to reject storing any primary user behavioral data (NFR-07 Privacy by Design rule).

//note: 'reject storing primary user behavioral data' has not been implemented here. it should be implemented in lib/data/repository
import 'package:supabase_flutter/supabase_flutter.dart';

final SupabaseService sdb = SupabaseService();

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    if (_isInitialized) {
      return;
    }

    const url = String.fromEnvironment('SUPABASE_URL');
    const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

    if (url.isEmpty || anonKey.isEmpty) {
      throw Exception(
        'SupabaseService init failed: SUPABASE_URL or SUPABASE_ANON_KEY is empty. Pass them with --dart-define.',
      );
    }

    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      throw Exception(
        'SupabaseService init failed: SUPABASE_URL is invalid: $url',
      );
    }

    await Supabase.initialize(url: url, anonKey: anonKey);
    _isInitialized = true;
  }

  SupabaseClient get client => Supabase.instance.client;
}
