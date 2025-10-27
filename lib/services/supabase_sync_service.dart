import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/fasting_session.dart';
import '../models/user_metrics.dart';
import 'supabase_error_handler.dart';

/// Centralized service for synchronizing data with Supabase
/// Handles fasting sessions and user metrics sync with conflict resolution
class SupabaseSyncService {
  static SupabaseSyncService? _instance;
  SupabaseSyncService._();

  /// Get singleton instance
  static SupabaseSyncService get instance {
    _instance ??= SupabaseSyncService._();
    return _instance!;
  }

  // ==========================================================================
  // Fasting Sessions Sync
  // ==========================================================================

  /// Sync fasting session to Supabase
  /// Handles both insert and update (upsert) with conflict resolution
  Future<void> syncFastingSession(FastingSession session) async {
    try {
      await SupabaseErrorHandler.retryOperation(
        operation: () async {
          final data = session.toJson();

          // Upsert to Supabase (insert or update based on id)
          await SupabaseConfig.from('fasting_sessions').upsert(
            data,
            onConflict: 'id',
          );

          debugPrint('Fasting session synced: ${session.id}');
        },
        maxAttempts: 3,
        initialDelay: const Duration(seconds: 1),
      );
    } on AuthException catch (e) {
      final error = SupabaseErrorHandler.handleAuthError(e);
      debugPrint('Auth error syncing session: ${error.message}');
      rethrow;
    } on PostgrestException catch (e) {
      final error = SupabaseErrorHandler.handleDatabaseError(e);
      debugPrint('Database error syncing session: ${error.message}');
      rethrow;
    } catch (e) {
      final error = SupabaseErrorHandler.handleNetworkError(e);
      debugPrint('Network error syncing session: ${error.message}');
      rethrow;
    }
  }

  /// Fetch a specific fasting session from Supabase
  Future<FastingSession?> fetchFastingSession(int sessionId) async {
    try {
      final response = await SupabaseConfig.from('fasting_sessions')
          .select()
          .eq('id', sessionId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return FastingSession.fromJson(response as Map<String, dynamic>);
    } on AuthException catch (e) {
      final error = SupabaseErrorHandler.handleAuthError(e);
      debugPrint('Auth error fetching session: ${error.message}');
      rethrow;
    } on PostgrestException catch (e) {
      final error = SupabaseErrorHandler.handleDatabaseError(e);
      debugPrint('Database error fetching session: ${error.message}');
      rethrow;
    } catch (e) {
      final error = SupabaseErrorHandler.handleNetworkError(e);
      debugPrint('Network error fetching session: ${error.message}');
      rethrow;
    }
  }

  /// Fetch all fasting sessions for a user from Supabase
  Future<List<FastingSession>> fetchUserFastingSessions(String userId) async {
    try {
      final response = await SupabaseConfig.from('fasting_sessions')
          .select()
          .eq('user_id', userId)
          .order('start_time', ascending: false);

      return (response as List)
          .map((json) => FastingSession.fromJson(json as Map<String, dynamic>))
          .toList();
    } on AuthException catch (e) {
      final error = SupabaseErrorHandler.handleAuthError(e);
      debugPrint('Auth error fetching sessions: ${error.message}');
      rethrow;
    } on PostgrestException catch (e) {
      final error = SupabaseErrorHandler.handleDatabaseError(e);
      debugPrint('Database error fetching sessions: ${error.message}');
      rethrow;
    } catch (e) {
      final error = SupabaseErrorHandler.handleNetworkError(e);
      debugPrint('Network error fetching sessions: ${error.message}');
      rethrow;
    }
  }

  // ==========================================================================
  // User Metrics Sync
  // ==========================================================================

  /// Sync user metrics to Supabase
  /// Handles both insert and update (upsert) with conflict resolution
  Future<void> syncUserMetrics(UserMetrics metrics) async {
    try {
      await SupabaseErrorHandler.retryOperation(
        operation: () async {
          final data = metrics.toJson();

          // Upsert to Supabase (insert or update based on user_id)
          await SupabaseConfig.from('user_metrics').upsert(
            data,
            onConflict: 'user_id',
          );

          debugPrint('User metrics synced for user: ${metrics.userId}');
        },
        maxAttempts: 3,
        initialDelay: const Duration(seconds: 1),
      );
    } on AuthException catch (e) {
      final error = SupabaseErrorHandler.handleAuthError(e);
      debugPrint('Auth error syncing metrics: ${error.message}');
      rethrow;
    } on PostgrestException catch (e) {
      final error = SupabaseErrorHandler.handleDatabaseError(e);
      debugPrint('Database error syncing metrics: ${error.message}');
      rethrow;
    } catch (e) {
      final error = SupabaseErrorHandler.handleNetworkError(e);
      debugPrint('Network error syncing metrics: ${error.message}');
      rethrow;
    }
  }

  /// Fetch user metrics from Supabase
  /// Returns null if metrics don't exist for the user
  Future<UserMetrics?> fetchUserMetrics(String userId) async {
    try {
      final response = await SupabaseConfig.from('user_metrics')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return UserMetrics.fromJson(response as Map<String, dynamic>);
    } on AuthException catch (e) {
      final error = SupabaseErrorHandler.handleAuthError(e);
      debugPrint('Auth error fetching metrics: ${error.message}');
      rethrow;
    } on PostgrestException catch (e) {
      final error = SupabaseErrorHandler.handleDatabaseError(e);
      debugPrint('Database error fetching metrics: ${error.message}');
      rethrow;
    } catch (e) {
      final error = SupabaseErrorHandler.handleNetworkError(e);
      debugPrint('Network error fetching metrics: ${error.message}');
      rethrow;
    }
  }

  // ==========================================================================
  // Sync Operations with Conflict Resolution
  // ==========================================================================

  /// Sync session and trigger metrics recalculation
  /// This combines session sync with metrics update
  Future<void> syncSessionWithMetrics({
    required FastingSession session,
    required UserMetrics metrics,
  }) async {
    try {
      // Sync session first
      await syncFastingSession(session);

      // Then sync metrics (local calculation)
      await syncUserMetrics(metrics);

      // Note: Supabase trigger will also update metrics on the backend
      // This serves as validation and ensures consistency
      debugPrint(
        'Session and metrics synced for user: ${session.userId}',
      );
    } catch (e) {
      debugPrint('Error syncing session with metrics: $e');
      rethrow;
    }
  }

  /// Fetch and merge metrics from Supabase with local metrics
  /// Useful for ensuring local metrics are in sync with server
  Future<UserMetrics?> fetchAndMergeMetrics({
    required String userId,
    required UserMetrics localMetrics,
  }) async {
    try {
      final remoteMetrics = await fetchUserMetrics(userId);

      if (remoteMetrics == null) {
        // No remote metrics, use local
        return localMetrics;
      }

      // Merge strategy: Trust server for authoritative data
      // But preserve local changes if sync_version is newer
      if (localMetrics.syncVersion != null &&
          remoteMetrics.syncVersion != null &&
          localMetrics.syncVersion! > remoteMetrics.syncVersion!) {
        // Local is newer, keep local
        debugPrint('Local metrics are newer, keeping local version');
        return localMetrics;
      }

      // Server is newer or equal, use server data
      debugPrint('Using server metrics (more recent)');
      return remoteMetrics;
    } catch (e) {
      debugPrint('Error fetching and merging metrics: $e');
      // On error, keep local metrics
      return localMetrics;
    }
  }
}
