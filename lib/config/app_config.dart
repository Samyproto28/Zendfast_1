import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application environment types
enum AppEnvironment {
  development,
  production,
}

/// Centralized application configuration
/// Supports both --dart-define (compile-time) and .env (runtime) configuration
///
/// Usage:
/// - Development: flutter run --flavor development --dart-define=ENV=development
/// - Production: flutter run --flavor production --dart-define=ENV=production
class AppConfig {
  // Singleton pattern
  AppConfig._internal();
  static final AppConfig _instance = AppConfig._internal();
  static AppConfig get instance => _instance;

  late AppEnvironment _environment;
  bool _isInitialized = false;

  /// Initialize the configuration
  /// Must be called before accessing any configuration values
  ///
  /// Reads from --dart-define first, falls back to .env file
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Try to get environment from dart-define first (compile-time)
    const envString = String.fromEnvironment('ENV', defaultValue: '');

    if (envString.isNotEmpty) {
      // Use dart-define environment
      _environment = _parseEnvironment(envString);
    } else {
      // Fall back to .env file (for local development)
      final envValue = dotenv.env['ENVIRONMENT'] ?? 'development';
      _environment = _parseEnvironment(envValue);
    }

    _isInitialized = true;
  }

  /// Parse environment string to enum
  AppEnvironment _parseEnvironment(String env) {
    switch (env.toLowerCase()) {
      case 'production':
      case 'prod':
        return AppEnvironment.production;
      case 'development':
      case 'dev':
      default:
        return AppEnvironment.development;
    }
  }

  /// Check if configuration has been initialized
  bool get isInitialized => _isInitialized;

  /// Get current environment
  AppEnvironment get environment {
    _ensureInitialized();
    return _environment;
  }

  /// Check if running in development mode
  bool get isDevelopment => environment == AppEnvironment.development;

  /// Check if running in production mode
  bool get isProduction => environment == AppEnvironment.production;

  /// Check if debug mode should be enabled
  bool get isDebugMode => isDevelopment;

  /// Get application name based on environment
  String get appName {
    return isDevelopment ? 'Zendfast Dev' : 'Zendfast';
  }

  /// Get application ID suffix for Android
  String get androidApplicationIdSuffix {
    return isDevelopment ? '.dev' : '';
  }

  /// Get bundle identifier for iOS
  String get iosBundleIdentifier {
    return isDevelopment ? 'com.zendfast.app.dev' : 'com.zendfast.app';
  }

  /// Get deep link scheme based on environment
  String get deepLinkScheme {
    return isDevelopment ? 'zendfast-dev' : 'zendfast';
  }

  // ===== Supabase Configuration =====

  /// Get Supabase URL for current environment
  String get supabaseUrl {
    // Try dart-define first
    const defineUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    if (defineUrl.isNotEmpty) return defineUrl;

    // Fall back to .env
    final url = dotenv.env['SUPABASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception(
        'SUPABASE_URL not configured. Set via --dart-define=SUPABASE_URL=... '
        'or in .env file.',
      );
    }
    return url;
  }

  /// Get Supabase anonymous key for current environment
  String get supabaseAnonKey {
    // Try dart-define first
    const defineKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
    if (defineKey.isNotEmpty) return defineKey;

    // Fall back to .env
    final key = dotenv.env['SUPABASE_ANON_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception(
        'SUPABASE_ANON_KEY not configured. Set via --dart-define=SUPABASE_ANON_KEY=... '
        'or in .env file.',
      );
    }
    return key;
  }

  /// Get Supabase service role key (optional, for admin operations)
  String? get supabaseServiceRoleKey {
    const defineKey = String.fromEnvironment('SUPABASE_SERVICE_ROLE_KEY', defaultValue: '');
    if (defineKey.isNotEmpty) return defineKey;

    return dotenv.env['SUPABASE_SERVICE_ROLE_KEY'];
  }

  // ===== OneSignal Configuration =====

  /// Get OneSignal App ID for current environment
  String get oneSignalAppId {
    // Try dart-define first
    const defineId = String.fromEnvironment('ONESIGNAL_APP_ID', defaultValue: '');
    if (defineId.isNotEmpty) return defineId;

    // Fall back to .env
    final appId = dotenv.env['ONESIGNAL_APP_ID'];
    if (appId == null || appId.isEmpty) {
      throw Exception(
        'ONESIGNAL_APP_ID not configured. Set via --dart-define=ONESIGNAL_APP_ID=... '
        'or in .env file. Create separate OneSignal apps for dev/prod.',
      );
    }
    return appId;
  }

  /// Get OneSignal REST API Key (optional, for server-side operations)
  String? get oneSignalRestApiKey {
    const defineKey = String.fromEnvironment('ONESIGNAL_REST_API_KEY', defaultValue: '');
    if (defineKey.isNotEmpty) return defineKey;

    return dotenv.env['ONESIGNAL_REST_API_KEY'];
  }

  // ===== Superwall Configuration =====

  /// Get Superwall API key for current environment
  String get superwallApiKey {
    // Try dart-define first
    const defineKey = String.fromEnvironment('SUPERWALL_API_KEY', defaultValue: '');
    if (defineKey.isNotEmpty) return defineKey;

    // Fall back to .env
    final key = dotenv.env['SUPERWALL_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception(
        'SUPERWALL_API_KEY not configured. Set via --dart-define=SUPERWALL_API_KEY=... '
        'or in .env file.',
      );
    }
    return key;
  }

  // ===== Sentry Configuration =====

  /// Get Sentry DSN for error tracking
  String? get sentryDsn {
    const defineDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');
    if (defineDsn.isNotEmpty) return defineDsn;

    return dotenv.env['SENTRY_DSN'];
  }

  /// Check if Sentry is enabled
  bool get isSentryEnabled => sentryDsn != null && sentryDsn!.isNotEmpty;

  // ===== Helper Methods =====

  /// Ensure configuration has been initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception(
        'AppConfig not initialized. Call AppConfig.instance.initialize() '
        'before accessing configuration values.',
      );
    }
  }

  /// Get a summary of current configuration (for debugging)
  Map<String, dynamic> getConfigSummary() {
    _ensureInitialized();

    return {
      'environment': environment.name,
      'isDevelopment': isDevelopment,
      'isProduction': isProduction,
      'isDebugMode': isDebugMode,
      'appName': appName,
      'deepLinkScheme': deepLinkScheme,
      'supabaseUrl': supabaseUrl,
      'oneSignalAppId': oneSignalAppId,
      'sentryEnabled': isSentryEnabled,
      // Don't include sensitive keys in summary
    };
  }

  /// Print configuration summary to console (development only)
  void printConfigSummary() {
    if (!isDebugMode) return;

    print('=== AppConfig Summary ===');
    getConfigSummary().forEach((key, value) {
      print('  $key: $value');
    });
    print('========================');
  }
}
