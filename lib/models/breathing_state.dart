/// Represents the current state of a breathing exercise session.
///
/// Used by BreathingExerciseService to track the current breathing phase,
/// remaining time, and cycle count during a 5-minute breathing exercise.
class BreathingState {
  /// Current breathing phase
  final BreathingPhase phase;

  /// Total remaining seconds in the exercise (max 300)
  final int remainingSeconds;

  /// Current breathing cycle number
  final int currentCycle;

  /// Whether the exercise is currently running
  final bool isRunning;

  /// Whether the exercise has been completed
  final bool isCompleted;

  const BreathingState({
    required this.phase,
    required this.remainingSeconds,
    required this.currentCycle,
    required this.isRunning,
    this.isCompleted = false,
  });

  /// Creates an initial state for a new breathing exercise
  factory BreathingState.initial() {
    return const BreathingState(
      phase: BreathingPhase.inhale,
      remainingSeconds: 300, // 5 minutes
      currentCycle: 0,
      isRunning: false,
      isCompleted: false,
    );
  }

  /// Creates a completed state
  factory BreathingState.completed() {
    return const BreathingState(
      phase: BreathingPhase.exhale,
      remainingSeconds: 0,
      currentCycle: 0,
      isRunning: false,
      isCompleted: true,
    );
  }

  /// Returns formatted remaining time (MM:SS)
  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Returns seconds remaining in current phase
  int get phaseRemainingSeconds {
    switch (phase) {
      case BreathingPhase.inhale:
        return 4 - (currentCycle * 19 % 4);
      case BreathingPhase.hold:
        return 7 - (currentCycle * 19 % 7);
      case BreathingPhase.exhale:
        return 8 - (currentCycle * 19 % 8);
    }
  }

  /// Returns instruction text for current phase
  String get instructionText {
    switch (phase) {
      case BreathingPhase.inhale:
        return 'Inhala profundamente';
      case BreathingPhase.hold:
        return 'Mantén la respiración';
      case BreathingPhase.exhale:
        return 'Exhala lentamente';
    }
  }

  /// Creates a copy with modified fields
  BreathingState copyWith({
    BreathingPhase? phase,
    int? remainingSeconds,
    int? currentCycle,
    bool? isRunning,
    bool? isCompleted,
  }) {
    return BreathingState(
      phase: phase ?? this.phase,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      currentCycle: currentCycle ?? this.currentCycle,
      isRunning: isRunning ?? this.isRunning,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  String toString() {
    return 'BreathingState(phase: $phase, remaining: $remainingSeconds, cycle: $currentCycle, running: $isRunning, completed: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BreathingState &&
        other.phase == phase &&
        other.remainingSeconds == remainingSeconds &&
        other.currentCycle == currentCycle &&
        other.isRunning == isRunning &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode {
    return Object.hash(
      phase,
      remainingSeconds,
      currentCycle,
      isRunning,
      isCompleted,
    );
  }
}

/// Breathing phases in the 4-7-8 technique
enum BreathingPhase {
  /// Inhale phase (4 seconds)
  inhale,

  /// Hold phase (7 seconds)
  hold,

  /// Exhale phase (8 seconds)
  exhale;

  /// Duration of this phase in seconds
  int get durationSeconds {
    switch (this) {
      case BreathingPhase.inhale:
        return 4;
      case BreathingPhase.hold:
        return 7;
      case BreathingPhase.exhale:
        return 8;
    }
  }

  /// Total cycle duration (4 + 7 + 8 = 19 seconds)
  static const int cycleDurationSeconds = 19;

  /// Gets the next phase in the cycle
  BreathingPhase get next {
    switch (this) {
      case BreathingPhase.inhale:
        return BreathingPhase.hold;
      case BreathingPhase.hold:
        return BreathingPhase.exhale;
      case BreathingPhase.exhale:
        return BreathingPhase.inhale;
    }
  }
}
