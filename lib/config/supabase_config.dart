import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration helper for Supabase client
/// Provides typed access to Supabase services and environment variables
class SupabaseConfig {
  // Private constructor to prevent instantiation
  SupabaseConfig._();

  /// Get the Supabase URL from environment variables
  static String get supabaseUrl {
    final url = dotenv.env['SUPABASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception(
        'SUPABASE_URL not found in .env file. '
        'Please ensure .env contains SUPABASE_URL.',
      );
    }
    return url;
  }

  /// Get the Supabase anonymous key from environment variables
  static String get supabaseAnonKey {
    final key = dotenv.env['SUPABASE_ANON_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception(
        'SUPABASE_ANON_KEY not found in .env file. '
        'Please ensure .env contains SUPABASE_ANON_KEY.',
      );
    }
    return key;
  }

  /// Get the singleton Supabase client instance
  /// Must call [initialize] first before accessing this
  static SupabaseClient get client {
    try {
      return Supabase.instance.client;
    } catch (e) {
      throw Exception(
        'Supabase client not initialized. '
        'Call SupabaseConfig.initialize() before accessing the client.',
      );
    }
  }

  /// Check if Supabase has been initialized
  static bool get isInitialized {
    try {
      Supabase.instance.client;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Initialize Supabase with environment variables
  /// Should be called once at app startup, before runApp()
  static Future<void> initialize() async {
    // Validate environment variables first
    final url = supabaseUrl;
    final anonKey = supabaseAnonKey;

    // Initialize Supabase
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  /// Get typed access to Auth service
  static GoTrueClient get auth => client.auth;

  /// Get typed access to Database service
  static SupabaseQueryBuilder from(String table) => client.from(table);

  /// Get typed access to Storage service
  static SupabaseStorageClient get storage => client.storage;

  /// Get typed access to Realtime service
  static RealtimeClient get realtime => client.realtime;

  /// Get typed access to Functions service
  static FunctionsClient get functions => client.functions;
}
