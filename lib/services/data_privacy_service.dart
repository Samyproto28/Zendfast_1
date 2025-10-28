import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../config/supabase_config.dart';
import '../models/data_export_result.dart';
import '../models/fasting_session.dart';
import '../services/database_service.dart';
import '../utils/result.dart';

/// Service for exporting user data for GDPR compliance
/// Implements "Right to Data Portability" - Article 20 GDPR
class DataPrivacyService {
  static DataPrivacyService? _instance;
  static DataPrivacyService get instance {
    _instance ??= DataPrivacyService._();
    return _instance!;
  }

  DataPrivacyService._();

  /// Export all user data in JSON and CSV formats, compressed as ZIP
  /// Returns Result with DataExportResult on success
  Future<Result<DataExportResult, Exception>> exportUserData(
    String userId,
  ) async {
    try {
      debugPrint('[DataPrivacy] Starting data export for user: $userId');

      // Collect all user data
      final userData = await _collectUserData(userId);

      // Generate exports
      final jsonExport = _generateJsonExport(userData);
      final csvExports = _generateCsvExports(userData);

      // Create ZIP archive
      final zipFile = await _createZipArchive(
        userId: userId,
        jsonExport: jsonExport,
        csvExports: csvExports,
      );

      // Calculate statistics
      final recordCounts = {
        'user_profile': userData['user_profile'] != null ? 1 : 0,
        'fasting_sessions': (userData['fasting_sessions'] as List).length,
        'hydration_logs': (userData['hydration_logs'] as List).length,
        'user_metrics': userData['user_metrics'] != null ? 1 : 0,
        'content_interactions':
            (userData['content_interactions'] as List).length,
        'analytics_events': (userData['analytics_events'] as List).length,
      };

      final fileSizeBytes = await zipFile.length();

      // Log export in audit table
      await _logExportAudit(
        userId: userId,
        fileSizeBytes: fileSizeBytes,
        recordCounts: recordCounts,
      );

      final result = DataExportResult(
        file: zipFile,
        fileSizeBytes: fileSizeBytes,
        exportedAt: DateTime.now(),
        recordCounts: recordCounts,
        format: ExportFormat.zip,
      );

      debugPrint('[DataPrivacy] Export completed: ${result.summary}');

      return Success(result);
    } catch (e, stackTrace) {
      debugPrint('[DataPrivacy] Export failed: $e');
      debugPrint('[DataPrivacy] Stack trace: $stackTrace');
      return Failure(Exception('Failed to export user data: $e'));
    }
  }

  /// Collect all user data from Supabase and local storage
  Future<Map<String, dynamic>> _collectUserData(String userId) async {
    debugPrint('[DataPrivacy] Collecting user data...');

    // Fetch from Supabase
    final userProfile = await _fetchUserProfile(userId);
    final fastingSessions = await _fetchFastingSessions(userId);
    final hydrationLogs = await _fetchHydrationLogs(userId);
    final userMetrics = await _fetchUserMetrics(userId);
    final contentInteractions = await _fetchContentInteractions(userId);
    final analyticsEvents = await _fetchAnalyticsEvents(userId);
    final userConsents = await _fetchUserConsents(userId);

    // Fetch from local Isar database (for any unsynced data)
    final localSessions =
        await DatabaseService.instance.getUserFastingSessions(userId);
    final localHydration = await _getLocalHydrationLogs(userId);

    return {
      'user_profile': userProfile,
      'fasting_sessions': [...fastingSessions, ...localSessions],
      'hydration_logs': [...hydrationLogs, ...localHydration],
      'user_metrics': userMetrics,
      'content_interactions': contentInteractions,
      'analytics_events': analyticsEvents,
      'user_consents': userConsents,
      'export_metadata': {
        'export_date': DateTime.now().toIso8601String(),
        'user_id': userId,
        'data_version': '1.0',
        'app_version': '1.0.0',
      },
    };
  }

  /// Fetch user profile from Supabase
  Future<Map<String, dynamic>?> _fetchUserProfile(String userId) async {
    try {
      final response = await SupabaseConfig.from('user_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      debugPrint('[DataPrivacy] Error fetching user profile: $e');
      return null;
    }
  }

  /// Fetch fasting sessions from Supabase
  Future<List<Map<String, dynamic>>> _fetchFastingSessions(
    String userId,
  ) async {
    try {
      final response = await SupabaseConfig.from('fasting_sessions')
          .select()
          .eq('user_id', userId)
          .order('start_time', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('[DataPrivacy] Error fetching fasting sessions: $e');
      return [];
    }
  }

  /// Fetch hydration logs from Supabase
  Future<List<Map<String, dynamic>>> _fetchHydrationLogs(String userId) async {
    try {
      final response = await SupabaseConfig.from('hydration_logs')
          .select()
          .eq('user_id', userId)
          .order('timestamp', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('[DataPrivacy] Error fetching hydration logs: $e');
      return [];
    }
  }

  /// Fetch user metrics from Supabase
  Future<Map<String, dynamic>?> _fetchUserMetrics(String userId) async {
    try {
      final response = await SupabaseConfig.from('user_metrics')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      debugPrint('[DataPrivacy] Error fetching user metrics: $e');
      return null;
    }
  }

  /// Fetch content interactions from Supabase
  Future<List<Map<String, dynamic>>> _fetchContentInteractions(
    String userId,
  ) async {
    try {
      final response = await SupabaseConfig.from('user_content_interactions')
          .select()
          .eq('user_id', userId)
          .order('timestamp', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('[DataPrivacy] Error fetching content interactions: $e');
      return [];
    }
  }

  /// Fetch analytics events from Supabase
  Future<List<Map<String, dynamic>>> _fetchAnalyticsEvents(
    String userId,
  ) async {
    try {
      final response = await SupabaseConfig.from('analytics_events')
          .select()
          .eq('user_id', userId)
          .order('timestamp', ascending: false)
          .limit(1000); // Limit to last 1000 events
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('[DataPrivacy] Error fetching analytics events: $e');
      return [];
    }
  }

  /// Fetch user consents from Supabase
  Future<List<Map<String, dynamic>>> _fetchUserConsents(String userId) async {
    try {
      final response = await SupabaseConfig.from('user_consents')
          .select()
          .eq('user_id', userId)
          .order('updated_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('[DataPrivacy] Error fetching user consents: $e');
      return [];
    }
  }

  /// Get local hydration logs from Isar
  Future<List<Map<String, dynamic>>> _getLocalHydrationLogs(
    String userId,
  ) async {
    try {
      final logs = await DatabaseService.instance.getHydrationRange(
        userId: userId,
        startDate: DateTime.now().subtract(const Duration(days: 365)),
        endDate: DateTime.now(),
      );
      return logs
          .map((log) => {
                'user_id': log.userId,
                'amount_ml': log.amountMl,
                'timestamp': log.timestamp.toIso8601String(),
                'created_at': log.createdAt.toIso8601String(),
              })
          .toList();
    } catch (e) {
      debugPrint('[DataPrivacy] Error fetching local hydration logs: $e');
      return [];
    }
  }

  /// Generate JSON export of all user data
  Map<String, dynamic> _generateJsonExport(Map<String, dynamic> userData) {
    return {
      'metadata': userData['export_metadata'],
      'user_profile': userData['user_profile'],
      'fasting_sessions': _convertSessionsToJson(userData['fasting_sessions']),
      'hydration_logs': userData['hydration_logs'],
      'user_metrics': userData['user_metrics'],
      'content_interactions': userData['content_interactions'],
      'analytics_events': userData['analytics_events'],
      'user_consents': userData['user_consents'],
    };
  }

  /// Convert fasting sessions (mix of Supabase and Isar) to consistent JSON
  List<Map<String, dynamic>> _convertSessionsToJson(List<dynamic> sessions) {
    return sessions.map<Map<String, dynamic>>((session) {
      if (session is FastingSession) {
        return session.toJson();
      } else if (session is Map<String, dynamic>) {
        return session;
      } else {
        return <String, dynamic>{};
      }
    }).toList();
  }

  /// Generate CSV exports for each data type
  Map<String, String> _generateCsvExports(Map<String, dynamic> userData) {
    return {
      'user_profile.csv': _generateUserProfileCsv(userData['user_profile']),
      'fasting_sessions.csv':
          _generateFastingSessionsCsv(userData['fasting_sessions']),
      'hydration_logs.csv': _generateHydrationLogsCsv(userData['hydration_logs']),
      'user_metrics.csv': _generateUserMetricsCsv(userData['user_metrics']),
      'content_interactions.csv':
          _generateContentInteractionsCsv(userData['content_interactions']),
      'analytics_events.csv':
          _generateAnalyticsEventsCsv(userData['analytics_events']),
      'user_consents.csv': _generateUserConsentsCsv(userData['user_consents']),
    };
  }

  /// Generate user profile CSV
  String _generateUserProfileCsv(Map<String, dynamic>? profile) {
    if (profile == null) return '';

    final rows = [
      ['Field', 'Value'],
      ['User ID', profile['user_id']?.toString() ?? ''],
      ['Name', profile['name']?.toString() ?? ''],
      ['Weight (kg)', profile['weight_kg']?.toString() ?? ''],
      ['Height (cm)', profile['height_cm']?.toString() ?? ''],
      ['Age', profile['age']?.toString() ?? ''],
      ['Gender', profile['gender']?.toString() ?? ''],
      ['Daily Hydration Goal (ml)', profile['daily_hydration_goal']?.toString() ?? ''],
      ['Created At', profile['created_at']?.toString() ?? ''],
      ['Updated At', profile['updated_at']?.toString() ?? ''],
    ];

    return const ListToCsvConverter().convert(rows);
  }

  /// Generate fasting sessions CSV
  String _generateFastingSessionsCsv(List<dynamic> sessions) {
    if (sessions.isEmpty) return '';

    final rows = [
      [
        'ID',
        'User ID',
        'Start Time',
        'End Time',
        'Duration (minutes)',
        'Plan Type',
        'Completed',
        'Interrupted',
        'Interruption Reason',
        'Created At'
      ],
    ];

    for (final session in sessions) {
      final data = session is FastingSession ? session.toJson() : session;
      rows.add([
        data['id']?.toString() ?? '',
        data['user_id']?.toString() ?? '',
        data['start_time']?.toString() ?? '',
        data['end_time']?.toString() ?? '',
        data['duration_minutes']?.toString() ?? '',
        data['plan_type']?.toString() ?? '',
        data['completed']?.toString() ?? '',
        data['interrupted']?.toString() ?? '',
        data['interruption_reason']?.toString() ?? '',
        data['created_at']?.toString() ?? '',
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  /// Generate hydration logs CSV
  String _generateHydrationLogsCsv(List<dynamic> logs) {
    if (logs.isEmpty) return '';

    final rows = [
      ['ID', 'User ID', 'Amount (ml)', 'Timestamp', 'Created At'],
    ];

    for (final log in logs) {
      rows.add([
        log['id']?.toString() ?? '',
        log['user_id']?.toString() ?? '',
        log['amount_ml']?.toString() ?? '',
        log['timestamp']?.toString() ?? '',
        log['created_at']?.toString() ?? '',
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  /// Generate user metrics CSV
  String _generateUserMetricsCsv(Map<String, dynamic>? metrics) {
    if (metrics == null) return '';

    final rows = [
      ['Field', 'Value'],
      ['User ID', metrics['user_id']?.toString() ?? ''],
      ['Total Fasts', metrics['total_fasts']?.toString() ?? ''],
      ['Total Duration (hours)', metrics['total_duration_hours']?.toString() ?? ''],
      ['Streak (days)', metrics['streak_days']?.toString() ?? ''],
      ['Last Fast Date', metrics['last_fast_date']?.toString() ?? ''],
      ['Created At', metrics['created_at']?.toString() ?? ''],
      ['Updated At', metrics['updated_at']?.toString() ?? ''],
    ];

    return const ListToCsvConverter().convert(rows);
  }

  /// Generate content interactions CSV
  String _generateContentInteractionsCsv(List<dynamic> interactions) {
    if (interactions.isEmpty) return '';

    final rows = [
      [
        'Interaction ID',
        'User ID',
        'Content ID',
        'Interaction Type',
        'Time Spent (seconds)',
        'Progress (%)',
        'Timestamp'
      ],
    ];

    for (final interaction in interactions) {
      rows.add([
        interaction['interaction_id']?.toString() ?? '',
        interaction['user_id']?.toString() ?? '',
        interaction['content_id']?.toString() ?? '',
        interaction['interaction_type']?.toString() ?? '',
        interaction['time_spent_seconds']?.toString() ?? '',
        interaction['progress_percentage']?.toString() ?? '',
        interaction['timestamp']?.toString() ?? '',
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  /// Generate analytics events CSV
  String _generateAnalyticsEventsCsv(List<dynamic> events) {
    if (events.isEmpty) return '';

    final rows = [
      ['Event ID', 'User ID', 'Event Type', 'Session ID', 'Event Data', 'Timestamp'],
    ];

    for (final event in events) {
      rows.add([
        event['event_id']?.toString() ?? '',
        event['user_id']?.toString() ?? '',
        event['event_type']?.toString() ?? '',
        event['session_id']?.toString() ?? '',
        jsonEncode(event['event_data'] ?? {}),
        event['timestamp']?.toString() ?? '',
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  /// Generate user consents CSV
  String _generateUserConsentsCsv(List<dynamic> consents) {
    if (consents.isEmpty) return '';

    final rows = [
      [
        'ID',
        'User ID',
        'Consent Type',
        'Consent Given',
        'Version',
        'Created At',
        'Updated At'
      ],
    ];

    for (final consent in consents) {
      rows.add([
        consent['id']?.toString() ?? '',
        consent['user_id']?.toString() ?? '',
        consent['consent_type']?.toString() ?? '',
        consent['consent_given']?.toString() ?? '',
        consent['consent_version']?.toString() ?? '',
        consent['created_at']?.toString() ?? '',
        consent['updated_at']?.toString() ?? '',
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  /// Create ZIP archive with all export files
  Future<File> _createZipArchive({
    required String userId,
    required Map<String, dynamic> jsonExport,
    required Map<String, String> csvExports,
  }) async {
    debugPrint('[DataPrivacy] Creating ZIP archive...');

    // Create archive
    final archive = Archive();

    // Add metadata.json
    final metadataJson = jsonEncode({
      'export_date': DateTime.now().toIso8601String(),
      'user_id': userId,
      'data_version': '1.0',
      'app_version': '1.0.0',
      'files_included': [
        'user_data.json',
        ...csvExports.keys,
      ],
    });
    archive.addFile(
      ArchiveFile('metadata.json', metadataJson.length, metadataJson.codeUnits),
    );

    // Add user_data.json
    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonExport);
    archive.addFile(
      ArchiveFile('user_data.json', jsonString.length, jsonString.codeUnits),
    );

    // Add CSV files
    for (final entry in csvExports.entries) {
      if (entry.value.isNotEmpty) {
        archive.addFile(
          ArchiveFile(entry.key, entry.value.length, entry.value.codeUnits),
        );
      }
    }

    // Encode archive
    final zipEncoder = ZipEncoder();
    final zipBytes = zipEncoder.encode(archive);

    if (zipBytes == null) {
      throw Exception('Failed to encode ZIP archive');
    }

    // Save to temporary directory
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = 'zendfast_export_${userId.substring(0, 8)}_$timestamp.zip';

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(zipBytes);

    debugPrint('[DataPrivacy] ZIP archive created: ${file.path}');

    return file;
  }

  /// Log export operation in audit table
  Future<void> _logExportAudit({
    required String userId,
    required int fileSizeBytes,
    required Map<String, int> recordCounts,
  }) async {
    try {
      await SupabaseConfig.from('data_export_audit').insert({
        'user_id': userId,
        'export_type': 'full',
        'exported_at': DateTime.now().toIso8601String(),
        'file_size_bytes': fileSizeBytes,
        'record_counts': recordCounts,
        'export_format': 'zip',
      });
      debugPrint('[DataPrivacy] Export audit logged');
    } catch (e) {
      debugPrint('[DataPrivacy] Failed to log export audit: $e');
      // Don't throw - audit logging failure shouldn't block export
    }
  }
}
