/// Represents the state of a fasting session
/// Used for type-safe state management throughout the app
enum FastingState {
  /// No active fasting session
  idle,

  /// Currently fasting (timer running)
  fasting,

  /// Fasting paused (can be resumed)
  paused,

  /// Fasting completed successfully
  completed,
}

/// Extension methods for FastingState
extension FastingStateExtension on FastingState {
  /// Check if this state allows starting a new fast
  bool get canStart => this == FastingState.idle || this == FastingState.completed;

  /// Check if this state allows pausing
  bool get canPause => this == FastingState.fasting;

  /// Check if this state allows resuming
  bool get canResume => this == FastingState.paused;

  /// Check if this state allows completion
  bool get canComplete => this == FastingState.fasting;

  /// Check if this state allows interruption
  bool get canInterrupt => this == FastingState.fasting || this == FastingState.paused;

  /// Check if fasting is currently active (running or paused)
  bool get isActive => this == FastingState.fasting || this == FastingState.paused;

  /// Get user-friendly display name
  String get displayName {
    switch (this) {
      case FastingState.idle:
        return 'Idle';
      case FastingState.fasting:
        return 'Fasting';
      case FastingState.paused:
        return 'Paused';
      case FastingState.completed:
        return 'Completed';
    }
  }

  /// Convert to JSON string
  String toJson() => name;

  /// Create from JSON string
  static FastingState fromJson(String json) {
    return FastingState.values.firstWhere(
      (state) => state.name == json,
      orElse: () => FastingState.idle,
    );
  }
}
