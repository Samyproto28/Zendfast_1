import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../models/timer_state.dart';
import '../models/fasting_session.dart';
import 'background_timer_service.dart';
import 'database_service.dart';

/// Service for managing fasting timer operations
/// Handles timer lifecycle, persistence, and database integration
class TimerService {
  static TimerService? _instance;
  TimerService._();

  /// Get singleton instance
  static TimerService get instance {
    _instance ??= TimerService._();
    return _instance!;
  }

  /// Stream controller for timer state updates
  final _stateController = StreamController<TimerState>.broadcast();

  /// Stream of timer state updates
  Stream<TimerState> get stateStream => _stateController.stream;

  /// Current timer state (cached)
  TimerState? _currentState;

  /// Current timer state
  TimerState? get currentState => _currentState;

  /// Initialize the timer service and background service
  Future<void> initialize() async {
    await BackgroundTimerService.initialize();

    // Load saved timer state
    _currentState = await BackgroundTimerService.loadTimerState();

    // Listen to background service events
    _listenToBackgroundService();

    // If there's a running timer, ensure background service is active
    if (_currentState?.isRunning == true) {
      await BackgroundTimerService.startService();
    }
  }

  /// Start a new fasting timer
  Future<void> startTimer({
    required String userId,
    required int durationMinutes,
    required String planType,
  }) async {
    try {
      // Create fasting session in database
      final session = FastingSession(
        userId: userId,
        startTime: DateTime.now(),
        planType: planType,
      );

      final sessionId = await DatabaseService.instance.createFastingSession(
        session,
      );

      // Create timer state
      final state = TimerState(
        startTime: DateTime.now(),
        durationMinutes: durationMinutes,
        isRunning: true,
        planType: planType,
        userId: userId,
        sessionId: sessionId,
      );

      // Save state to SharedPreferences
      await BackgroundTimerService.saveTimerState(state);

      // Update cached state
      _currentState = state;
      _stateController.add(state);

      // Start background service
      await BackgroundTimerService.startService();

      // Send state to background service
      final service = FlutterBackgroundService();
      service.invoke('updateTimerState', {
        'state': state.toJson(),
      });
    } catch (e) {
      debugPrint('Error starting timer: $e');
      rethrow;
    }
  }

  /// Pause the current timer
  Future<void> pauseTimer() async {
    if (_currentState == null || !_currentState!.isRunning) {
      return;
    }

    final pausedState = _currentState!.copyWith(isRunning: false);

    await BackgroundTimerService.saveTimerState(pausedState);
    _currentState = pausedState;
    _stateController.add(pausedState);

    // Update background service
    final service = FlutterBackgroundService();
    service.invoke('updateTimerState', {
      'state': pausedState.toJson(),
    });
  }

  /// Resume a paused timer
  Future<void> resumeTimer() async {
    if (_currentState == null || _currentState!.isRunning) {
      return;
    }

    final resumedState = _currentState!.copyWith(isRunning: true);

    await BackgroundTimerService.saveTimerState(resumedState);
    _currentState = resumedState;
    _stateController.add(resumedState);

    // Ensure background service is running
    await BackgroundTimerService.startService();

    // Update background service
    final service = FlutterBackgroundService();
    service.invoke('updateTimerState', {
      'state': resumedState.toJson(),
    });
  }

  /// Stop and cancel the current timer
  Future<void> cancelTimer({bool wasInterrupted = true}) async {
    if (_currentState == null) {
      return;
    }

    try {
      // Update database session
      if (_currentState!.sessionId != null) {
        final session = await DatabaseService.instance.getFastingSession(
          _currentState!.sessionId!,
        );

        if (session != null) {
          session.endSession(wasInterrupted: wasInterrupted);
          await DatabaseService.instance.updateFastingSession(session);
        }
      }

      // Clear timer state
      await BackgroundTimerService.clearTimerState();
      _currentState = null;
      _stateController.add(TimerState.empty(''));

      // Stop background service
      await BackgroundTimerService.stopService();
    } catch (e) {
      debugPrint('Error canceling timer: $e');
      rethrow;
    }
  }

  /// Complete the current timer (called when timer finishes)
  Future<void> completeTimer() async {
    if (_currentState == null) {
      return;
    }

    await cancelTimer(wasInterrupted: false);
  }

  /// Load and sync timer state from persistence
  Future<void> syncState() async {
    final loadedState = await BackgroundTimerService.loadTimerState();

    if (loadedState != null) {
      _currentState = loadedState;
      _stateController.add(loadedState);

      // If timer is running but service isn't, start it
      if (loadedState.isRunning) {
        await BackgroundTimerService.startService();
      }
    }
  }

  /// Listen to background service events
  void _listenToBackgroundService() {
    final service = FlutterBackgroundService();

    // Listen for timer tick updates
    service.on('timerTick').listen((event) {
      if (_currentState != null && event != null) {
        // Background service sends updates, we can use them to keep UI in sync
        // The state is already in SharedPreferences, so we just emit current state
        _stateController.add(_currentState!);
      }
    });

    // Listen for timer completion
    service.on('timerCompleted').listen((event) async {
      if (event != null) {
        debugPrint('Timer completed: $event');
        await completeTimer();
      }
    });
  }

  /// Get active fasting session from database
  Future<FastingSession?> getActiveSession(String userId) async {
    return await DatabaseService.instance.getActiveFastingSession(userId);
  }

  /// Get all fasting sessions for a user
  Future<List<FastingSession>> getUserSessions(String userId) async {
    return await DatabaseService.instance.getUserFastingSessions(userId);
  }

  /// Get completed sessions for a user
  Future<List<FastingSession>> getCompletedSessions(String userId) async {
    return await DatabaseService.instance.getCompletedFastingSessions(userId);
  }

  /// Dispose resources
  void dispose() {
    _stateController.close();
  }
}
