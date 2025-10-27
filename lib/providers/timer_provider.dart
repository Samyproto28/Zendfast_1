import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/timer_state.dart';
import '../models/fasting_state.dart';
import '../services/timer_service.dart';

/// Provider for timer state
/// Manages timer state using Riverpod StateNotifier
final timerProvider = StateNotifierProvider<TimerNotifier, TimerState?>((ref) {
  return TimerNotifier();
});

/// Timer State Notifier
/// Handles synchronization between background service and UI
class TimerNotifier extends StateNotifier<TimerState?> {
  final TimerService _timerService = TimerService.instance;
  StreamSubscription<TimerState>? _stateSubscription;

  TimerNotifier() : super(null) {
    _initialize();
  }

  /// Initialize provider and listen to state changes
  void _initialize() {
    // Load initial state
    _syncState();

    // Listen to state updates from background service
    _stateSubscription = _timerService.stateStream.listen((newState) {
      state = newState;
    });
  }

  /// Current timer state
  TimerState? get currentState => state;

  /// Whether a timer is currently running
  bool get isRunning => state?.isRunning ?? false;

  /// Remaining time in milliseconds
  int get remainingMilliseconds => state?.remainingMilliseconds ?? 0;

  /// Elapsed time in milliseconds
  int get elapsedMilliseconds => state?.elapsedMilliseconds ?? 0;

  /// Timer progress (0.0 to 1.0)
  double get progress => state?.progress ?? 0.0;

  /// Whether timer has completed
  bool get isCompleted => state?.isCompleted ?? false;

  /// Formatted remaining time
  String get formattedRemainingTime =>
      state?.formattedRemainingTime ?? '00:00:00';

  /// Formatted elapsed time
  String get formattedElapsedTime =>
      state?.formattedElapsedTime ?? '00:00:00';

  /// Current fasting state
  FastingState get fastingState =>
      state?.state ?? FastingState.idle;

  /// Start a new timer
  Future<void> startTimer({
    required String userId,
    required int durationMinutes,
    required String planType,
  }) async {
    try {
      await _timerService.startTimer(
        userId: userId,
        durationMinutes: durationMinutes,
        planType: planType,
      );

      // State will be updated via stream listener
    } catch (e) {
      debugPrint('Error starting timer in provider: $e');
      rethrow;
    }
  }

  // ==========================================================================
  // Task 8 Specification Methods
  // ==========================================================================

  /// Start a new fast (Task 8 specification)
  Future<void> startFast({
    required String userId,
    required int durationMinutes,
    required String planType,
  }) async {
    try {
      await _timerService.startFast(
        userId: userId,
        durationMinutes: durationMinutes,
        planType: planType,
      );
      // State will be updated via stream listener
    } catch (e) {
      debugPrint('Error starting fast in provider: $e');
      rethrow;
    }
  }

  /// Pause the current fast (Task 8 specification)
  Future<void> pauseFast() async {
    try {
      await _timerService.pauseFast();
      // State will be updated via stream listener
    } catch (e) {
      debugPrint('Error pausing fast in provider: $e');
      rethrow;
    }
  }

  /// Resume a paused fast (Task 8 specification)
  Future<void> resumeFast() async {
    try {
      await _timerService.resumeFast();
      // State will be updated via stream listener
    } catch (e) {
      debugPrint('Error resuming fast in provider: $e');
      rethrow;
    }
  }

  /// Complete the current fast (Task 8 specification)
  Future<void> completeFast() async {
    try {
      await _timerService.completeFast();
      // State will be updated via stream listener
    } catch (e) {
      debugPrint('Error completing fast in provider: $e');
      rethrow;
    }
  }

  /// Interrupt the current fast (Task 8 specification)
  Future<void> interruptFast() async {
    try {
      await _timerService.interruptFast();
      // State will be updated via stream listener
    } catch (e) {
      debugPrint('Error interrupting fast in provider: $e');
      rethrow;
    }
  }

  /// Pause the current timer
  Future<void> pauseTimer() async {
    try {
      await _timerService.pauseTimer();
      // State will be updated via stream listener
    } catch (e) {
      debugPrint('Error pausing timer in provider: $e');
      rethrow;
    }
  }

  /// Resume a paused timer
  Future<void> resumeTimer() async {
    try {
      await _timerService.resumeTimer();
      // State will be updated via stream listener
    } catch (e) {
      debugPrint('Error resuming timer in provider: $e');
      rethrow;
    }
  }

  /// Cancel the current timer
  Future<void> cancelTimer({bool wasInterrupted = true}) async {
    try {
      await _timerService.cancelTimer(wasInterrupted: wasInterrupted);
      // State will be updated via stream listener
    } catch (e) {
      debugPrint('Error canceling timer in provider: $e');
      rethrow;
    }
  }

  /// Sync state from background service (called when app resumes)
  Future<void> syncState() async {
    await _syncState();
  }

  /// Internal method to sync state
  Future<void> _syncState() async {
    try {
      await _timerService.syncState();
      state = _timerService.currentState;
    } catch (e) {
      debugPrint('Error syncing timer state: $e');
    }
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    super.dispose();
  }
}
