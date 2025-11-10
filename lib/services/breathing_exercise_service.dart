import 'dart:async';

import 'package:zendfast_1/models/breathing_state.dart';

/// Service that manages breathing exercise sessions with 4-7-8 technique.
///
/// This service handles:
/// - 5-minute breathing exercise timer
/// - Breathing phase transitions (inhale → hold → exhale)
/// - State broadcasting via Stream
/// - Pause/resume functionality
///
/// Follows singleton pattern for consistent state across the app.
class BreathingExerciseService {
  static final BreathingExerciseService instance =
      BreathingExerciseService._internal();

  BreathingExerciseService._internal();

  /// Current breathing state
  BreathingState _currentState = BreathingState.initial();

  /// Stream controller for state broadcasts
  final StreamController<BreathingState> _stateController =
      StreamController<BreathingState>.broadcast();

  /// Timer for countdown
  Timer? _timer;

  /// Seconds elapsed in current phase
  int _phaseElapsedSeconds = 0;

  /// Get current state
  BreathingState get currentState => _currentState;

  /// Stream of state changes
  Stream<BreathingState> get stateStream => _stateController.stream;

  /// Starts the breathing exercise
  Future<void> start() async {
    // Don't restart if already running
    if (_currentState.isRunning) {
      return;
    }

    // Reset to initial state
    _currentState = BreathingState.initial().copyWith(isRunning: true);
    _phaseElapsedSeconds = 0;
    _stateController.add(_currentState);

    // Start timer (ticks every second)
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  /// Pauses the breathing exercise
  Future<void> pause() async {
    if (!_currentState.isRunning) {
      return;
    }

    _timer?.cancel();
    _currentState = _currentState.copyWith(isRunning: false);
    _stateController.add(_currentState);
  }

  /// Resumes the breathing exercise
  Future<void> resume() async {
    if (_currentState.isRunning || _currentState.isCompleted) {
      return;
    }

    _currentState = _currentState.copyWith(isRunning: true);
    _stateController.add(_currentState);

    // Restart timer
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  /// Stops the breathing exercise and resets to initial state
  Future<void> stop() async {
    _timer?.cancel();
    _currentState = BreathingState.initial();
    _phaseElapsedSeconds = 0;
    _stateController.add(_currentState);
  }

  /// Resets to initial state without emitting
  Future<void> reset() async {
    _timer?.cancel();
    _currentState = BreathingState.initial();
    _phaseElapsedSeconds = 0;
  }

  /// Called on each timer tick (every second)
  void _onTick(Timer timer) {
    // Decrement remaining time
    final newRemainingSeconds = _currentState.remainingSeconds - 1;

    // Check if completed
    if (newRemainingSeconds <= 0) {
      _timer?.cancel();
      _currentState = BreathingState.completed();
      _stateController.add(_currentState);
      return;
    }

    // Increment phase elapsed time
    _phaseElapsedSeconds++;

    // Check if need to transition to next phase
    BreathingPhase newPhase = _currentState.phase;
    int newCycle = _currentState.currentCycle;

    if (_phaseElapsedSeconds >= _currentState.phase.durationSeconds) {
      // Move to next phase
      newPhase = _currentState.phase.next;
      _phaseElapsedSeconds = 0;

      // If we just completed exhale, increment cycle
      if (_currentState.phase == BreathingPhase.exhale) {
        newCycle++;
      }
    }

    // Update state
    _currentState = _currentState.copyWith(
      phase: newPhase,
      remainingSeconds: newRemainingSeconds,
      currentCycle: newCycle,
    );

    // Broadcast state
    _stateController.add(_currentState);
  }

  /// Disposes resources
  void dispose() {
    _timer?.cancel();
    _stateController.close();
  }
}
