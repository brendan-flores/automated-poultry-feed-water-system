import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';

/// Supabase client initialization
/// Loads credentials from --dart-define or uses a null client (for mock mode)
class SupabaseClient {
  static SupabaseClient? _instance;
  static Supabase? _client;

  SupabaseClient._();

  static SupabaseClient get instance {
    _instance ??= SupabaseClient._();
    return _instance!;
  }

  /// Initialize Supabase with credentials from environment variables
  /// Returns true if initialization succeeded, false if keys are missing
  static Future<bool> initialize() async {
    final supabaseUrl = const String.fromEnvironment(
      AppConstants.supabaseUrlKey,
      defaultValue: '',
    );
    final supabaseAnonKey = const String.fromEnvironment(
      AppConstants.supabaseAnonKeyKey,
      defaultValue: '',
    );

    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      // Keys not provided - will use mock repositories
      return false;
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey, // ignore: deprecated_member_use
    );
    _client = Supabase.instance;
    return true;
  }

  /// Get the Supabase client (null if not initialized)
  static Supabase? get client => _client;

  /// Check if Supabase is initialized
  static bool get isInitialized => _client != null;
}
