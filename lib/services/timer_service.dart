import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../models/timer_state.dart';
import '../models/fasting_state.dart';
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

  /// Stream controller for fasting state updates
  final _fastingStateController = StreamController<FastingState>.broadcast();

  /// Stream of timer state updates
  Stream<TimerState> get stateStream => _stateController.stream;

  /// Stream of fasting state updates
  Stream<FastingState> get fastingStateStream =>
      _fastingStateController.stream;

  /// Current timer state (cached)
  TimerState? _currentState;

  /// Current timer state
  TimerState? get currentState => _currentState;

  /// Current fasting state
  FastingState? get currentFastingState => _currentState?.state;

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

      // Create timer state with timezone offset and fasting state
      final now = DateTime.now();
      final state = TimerState(
        startTime: now,
        durationMinutes: durationMinutes,
        isRunning: true,
        planType: planType,
        userId: userId,
        sessionId: sessionId,
        timezoneOffset: now.timeZoneOffset,
        state: FastingState.fasting,
      );

      // Save state to SharedPreferences
      await BackgroundTimerService.saveTimerState(state);

      // Update cached state and emit to both streams
      _currentState = state;
      _stateController.add(state);
      _fastingStateController.add(state.state);

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

    final pausedState = _currentState!.copyWith(
      isRunning: false,
      state: FastingState.paused,
    );

    await BackgroundTimerService.saveTimerState(pausedState);
    _currentState = pausedState;
    _stateController.add(pausedState);
    _fastingStateController.add(pausedState.state);

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

    final resumedState = _currentState!.copyWith(
      isRunning: true,
      state: FastingState.fasting,
    );

    await BackgroundTimerService.saveTimerState(resumedState);
    _currentState = resumedState;
    _stateController.add(resumedState);
    _fastingStateController.add(resumedState.state);

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

      // Create idle state before clearing
      final idleState = TimerState.empty(_currentState!.userId);
      _currentState = idleState;
      _stateController.add(idleState);
      _fastingStateController.add(idleState.state);

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

    // Mark as completed before canceling
    if (_currentState != null) {
      final completedState = _currentState!.copyWith(
        isRunning: false,
        state: FastingState.completed,
      );

      await BackgroundTimerService.saveTimerState(completedState);
      _currentState = completedState;
      _stateController.add(completedState);
      _fastingStateController.add(completedState.state);
    }

    await cancelTimer(wasInterrupted: false);
  }

  /// Load and sync timer state from persistence
  /// Handles timezone changes and inconsistent states
  Future<void> syncState() async {
    final loadedState = await BackgroundTimerService.loadTimerState();

    if (loadedState != null) {
      // Check for timezone changes
      TimerState adjustedState = loadedState;
      if (loadedState.hasTimezoneChanged()) {
        debugPrint(
          'Timezone changed detected: ${loadedState.timezoneOffsetDifferenceHours} hours',
        );
        adjustedState = _handleTimezoneChange(loadedState);
      }

      // Detect and handle inconsistent states
      adjustedState = _validateAndFixState(adjustedState);

      _currentState = adjustedState;
      _stateController.add(adjustedState);
      _fastingStateController.add(adjustedState.state);

      // If timer is running but service isn't, start it
      if (adjustedState.isRunning) {
        await BackgroundTimerService.startService();
      }

      // Save adjusted state if it was modified
      if (adjustedState != loadedState) {
        await BackgroundTimerService.saveTimerState(adjustedState);
      }
    }
  }

  /// Handle timezone change by updating the timer state
  /// Recalculates times based on new timezone offset
  TimerState _handleTimezoneChange(TimerState state) {
    if (state.startTime == null) return state;

    // Get the current timezone offset
    final currentOffset = DateTime.now().timeZoneOffset;

    // Update the state with new timezone offset
    // Note: We keep startTime as-is (it's in UTC internally)
    // but update the offset for future comparisons
    return state.copyWith(
      timezoneOffset: currentOffset,
    );
  }

  /// Validate and fix inconsistent timer states
  /// Handles edge cases like invalid combinations of fields
  TimerState _validateAndFixState(TimerState state) {
    TimerState fixedState = state;

    // Edge case 1: isRunning=true but no startTime
    if (state.isRunning && state.startTime == null) {
      debugPrint('Inconsistent state: running without startTime, fixing...');
      fixedState = state.copyWith(
        isRunning: false,
        state: FastingState.idle,
      );
    }

    // Edge case 2: startTime in the future (clock was set backward)
    if (state.startTime != null &&
        state.startTime!.isAfter(DateTime.now().add(Duration(minutes: 1)))) {
      debugPrint('Inconsistent state: startTime in future, resetting...');
      fixedState = TimerState.empty(state.userId);
    }

    // Edge case 3: Timer has been running for impossibly long (> 48 hours)
    if (state.isRunning &&
        state.startTime != null &&
        DateTime.now().difference(state.startTime!).inHours > 48) {
      debugPrint(
        'Inconsistent state: timer running for > 48 hours, marking complete...',
      );
      fixedState = state.copyWith(
        isRunning: false,
        state: FastingState.completed,
      );
    }

    // Edge case 4: State enum doesn't match boolean flags
    final derivedState = fixedState.derivedState;
    if (fixedState.state != derivedState) {
      debugPrint(
        'State mismatch: ${fixedState.state.name} vs derived ${derivedState.name}, using derived...',
      );
      fixedState = fixedState.copyWith(state: derivedState);
    }

    return fixedState;
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
        _fastingStateController.add(_currentState!.state);
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

  // ==========================================================================
  // Task 8 Specification Methods
  // ==========================================================================

  /// Start a new fast (Task 8 specification)
  /// Validates state before starting
  Future<void> startFast({
    required String userId,
    required int durationMinutes,
    required String planType,
  }) async {
    // Validate can start from current state
    final currentFastingState = _currentState?.state ?? FastingState.idle;
    if (!currentFastingState.canStart) {
      throw StateError(
        'Cannot start fast from state: ${currentFastingState.displayName}',
      );
    }

    // Delegate to existing startTimer method
    await startTimer(
      userId: userId,
      durationMinutes: durationMinutes,
      planType: planType,
    );
  }

  /// Pause the current fast (Task 8 specification)
  /// Validates state before pausing
  Future<void> pauseFast() async {
    // Validate can pause from current state
    final currentFastingState = _currentState?.state ?? FastingState.idle;
    if (!currentFastingState.canPause) {
      throw StateError(
        'Cannot pause fast from state: ${currentFastingState.displayName}',
      );
    }

    // Delegate to existing pauseTimer method
    await pauseTimer();
  }

  /// Resume a paused fast (Task 8 specification)
  /// Validates state before resuming
  Future<void> resumeFast() async {
    // Validate can resume from current state
    final currentFastingState = _currentState?.state ?? FastingState.idle;
    if (!currentFastingState.canResume) {
      throw StateError(
        'Cannot resume fast from state: ${currentFastingState.displayName}',
      );
    }

    // Delegate to existing resumeTimer method
    await resumeTimer();
  }

  /// Complete the current fast successfully (Task 8 specification)
  /// Validates state before completing
  Future<void> completeFast() async {
    // Validate can complete from current state
    final currentFastingState = _currentState?.state ?? FastingState.idle;
    if (!currentFastingState.canComplete) {
      throw StateError(
        'Cannot complete fast from state: ${currentFastingState.displayName}',
      );
    }

    // Delegate to existing completeTimer method
    await completeTimer();
  }

  /// Interrupt/cancel the current fast (Task 8 specification)
  /// Validates state before interrupting
  Future<void> interruptFast() async {
    // Validate can interrupt from current state
    final currentFastingState = _currentState?.state ?? FastingState.idle;
    if (!currentFastingState.canInterrupt) {
      throw StateError(
        'Cannot interrupt fast from state: ${currentFastingState.displayName}',
      );
    }

    // Delegate to existing cancelTimer method (with interruption flag)
    await cancelTimer(wasInterrupted: true);
  }

  /// Dispose resources
  void dispose() {
    _stateController.close();
    _fastingStateController.close();
  }
}
