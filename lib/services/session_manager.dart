import 'package:flutter/material.dart';
import '../models/fasting_session.dart';
import '../models/user_metrics.dart';
import '../widgets/fasting/completion_bottom_sheet.dart';
import '../widgets/fasting/interruption_dialog.dart';
import 'database_service.dart';
import 'supabase_sync_service.dart';
import 'timer_service.dart';

/// Central session manager that orchestrates fasting session flows
/// Handles completion and interruption with UI, persistence, and sync
class SessionManager {
  final TimerService _timerService;
  final DatabaseService _databaseService;
  final SupabaseSyncService _syncService;

  SessionManager({
    TimerService? timerService,
    DatabaseService? databaseService,
    SupabaseSyncService? syncService,
  })  : _timerService = timerService ?? TimerService.instance,
        _databaseService = databaseService ?? DatabaseService.instance,
        _syncService = syncService ?? SupabaseSyncService.instance;

  // ==========================================================================
  // Complete Session Flow
  // ==========================================================================

  /// Complete the current fasting session
  /// Shows congratulations UI, updates metrics, and syncs to Supabase
  Future<void> completeSession(BuildContext context) async {
    try {
      final currentState = _timerService.currentState;

      if (currentState == null || currentState.sessionId == null) {
        debugPrint('No active session to complete');
        return;
      }

      // 1. Get the session from database
      final session = await _databaseService.getFastingSession(
        currentState.sessionId!,
      );

      if (session == null) {
        debugPrint('Session not found in database');
        return;
      }

      // 2. Mark session as completed
      session.endSession(wasInterrupted: false);
      await _databaseService.updateFastingSession(session);

      // 3. Update user metrics (local-first)
      final metrics = await _databaseService.getOrCreateUserMetrics(
        currentState.userId,
      );
      metrics.addCompletedFast(
        durationMinutes: session.durationMinutes!,
        completedAt: session.endTime!,
      );
      await _databaseService.saveUserMetrics(metrics);

      // 4. Complete timer in TimerService
      await _timerService.completeFast();

      // 5. Sync to Supabase in background (don't await)
      _syncToSupabase(session, metrics);

      // 6. Show congratulations UI
      if (context.mounted) {
        await _showCompletionUI(context, session);
      }

      debugPrint('Session completed successfully: ${session.id}');
    } catch (e) {
      debugPrint('Error completing session: $e');
      rethrow;
    }
  }

  /// Show congratulations bottom sheet
  Future<void> _showCompletionUI(
    BuildContext context,
    FastingSession session,
  ) async {
    await CompletionBottomSheet.show(
      context: context,
      session: session,
    );
  }

  // ==========================================================================
  // Interrupt Session Flow
  // ==========================================================================

  /// Interrupt the current fasting session
  /// Shows reason dialog, saves partial session, and syncs to Supabase
  Future<void> interruptSession(BuildContext context) async {
    try {
      // 1. Show interruption reason dialog
      final reason = await _showInterruptionDialog(context);

      // User cancelled the dialog
      if (reason == null && context.mounted) {
        return;
      }

      final currentState = _timerService.currentState;

      if (currentState == null || currentState.sessionId == null) {
        debugPrint('No active session to interrupt');
        return;
      }

      // 2. Get the session from database
      final session = await _databaseService.getFastingSession(
        currentState.sessionId!,
      );

      if (session == null) {
        debugPrint('Session not found in database');
        return;
      }

      // 3. Mark session as interrupted with reason
      session.endSession(wasInterrupted: true, reason: reason);
      await _databaseService.updateFastingSession(session);

      // 4. Update user metrics with partial credit
      final metrics = await _databaseService.getOrCreateUserMetrics(
        currentState.userId,
      );
      metrics.addInterruptedFast(
        durationMinutes: session.durationMinutes!,
        interruptedAt: session.endTime!,
      );
      await _databaseService.saveUserMetrics(metrics);

      // 5. Interrupt timer in TimerService
      await _timerService.interruptFast();

      // 6. Sync to Supabase in background (don't await)
      _syncToSupabase(session, metrics);

      debugPrint('Session interrupted: ${session.id}, reason: $reason');

      // 7. Show confirmation snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ayuno interrumpido. Tu progreso ha sido guardado.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error interrupting session: $e');
      rethrow;
    }
  }

  /// Show interruption reason dialog
  /// Returns the selected reason or null if cancelled
  Future<String?> _showInterruptionDialog(BuildContext context) async {
    return await showDialog<String>(
      context: context,
      builder: (context) => const InterruptionDialog(),
    );
  }

  // ==========================================================================
  // Sync Operations
  // ==========================================================================

  /// Sync session and metrics to Supabase
  /// Runs in background without blocking UI
  void _syncToSupabase(FastingSession session, UserMetrics metrics) {
    // Run sync in background
    _syncService
        .syncSessionWithMetrics(
      session: session,
      metrics: metrics,
    )
        .then((_) {
      debugPrint('Background sync completed successfully');
    }).catchError((error) {
      debugPrint('Background sync failed: $error');
      // Don't rethrow - sync failures shouldn't break the UI flow
      // Data is already saved locally and will be synced later
    });
  }

  // ==========================================================================
  // Utility Methods
  // ==========================================================================

  /// Fetch latest metrics from Supabase and merge with local
  /// Useful for ensuring metrics are up-to-date
  Future<UserMetrics?> syncMetrics(String userId) async {
    try {
      final localMetrics = await _databaseService.getUserMetrics(userId);

      if (localMetrics == null) {
        return null;
      }

      final mergedMetrics = await _syncService.fetchAndMergeMetrics(
        userId: userId,
        localMetrics: localMetrics,
      );

      if (mergedMetrics != null) {
        await _databaseService.saveUserMetrics(mergedMetrics);
        return mergedMetrics;
      }

      return localMetrics;
    } catch (e) {
      debugPrint('Error syncing metrics: $e');
      return null;
    }
  }

  /// Get current session statistics
  /// Returns null if no active session
  Future<Map<String, dynamic>?> getCurrentSessionStats() async {
    final currentState = _timerService.currentState;

    if (currentState == null || currentState.sessionId == null) {
      return null;
    }

    final session = await _databaseService.getFastingSession(
      currentState.sessionId!,
    );

    if (session == null) {
      return null;
    }

    return {
      'duration_minutes': session.currentDuration.inMinutes,
      'duration_hours': session.currentDuration.inMinutes / 60,
      'plan_type': session.planType,
      'start_time': session.startTime,
      'is_active': session.isActive,
    };
  }
}
