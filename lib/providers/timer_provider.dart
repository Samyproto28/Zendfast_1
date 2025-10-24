import 'dart:async';
import 'package:flutter/material.dart';
import '../models/timer_state.dart';
import '../services/timer_service.dart';

/// Provider for managing timer state in the UI
/// Handles synchronization between background service and UI
class TimerProvider extends ChangeNotifier {
  final TimerService _timerService = TimerService.instance;

  TimerState? _currentState;
  StreamSubscription<TimerState>? _stateSubscription;

  /// Current timer state
  TimerState? get currentState => _currentState;

  /// Whether a timer is currently running
  bool get isRunning => _currentState?.isRunning ?? false;

  /// Remaining time in milliseconds
  int get remainingMilliseconds =>
      _currentState?.remainingMilliseconds ?? 0;

  /// Elapsed time in milliseconds
  int get elapsedMilliseconds =>
      _currentState?.elapsedMilliseconds ?? 0;

  /// Timer progress (0.0 to 1.0)
  double get progress => _currentState?.progress ?? 0.0;

  /// Whether timer has completed
  bool get isCompleted => _currentState?.isCompleted ?? false;

  /// Formatted remaining time
  String get formattedRemainingTime =>
      _currentState?.formattedRemainingTime ?? '00:00:00';

  /// Formatted elapsed time
  String get formattedElapsedTime =>
      _currentState?.formattedElapsedTime ?? '00:00:00';

  /// Initialize provider and listen to state changes
  void initialize() {
    // Load initial state
    _syncState();

    // Listen to state updates from background service
    _stateSubscription = _timerService.stateStream.listen((state) {
      _currentState = state;
      notifyListeners();
    });
  }

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
      _currentState = _timerService.currentState;
      notifyListeners();
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
