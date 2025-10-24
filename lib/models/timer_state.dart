/// Represents the state of a fasting timer
/// Used for persistence across app restarts and background service
class TimerState {
  /// When the timer started (null if not running)
  final DateTime? startTime;

  /// Target duration in minutes
  final int durationMinutes;

  /// Whether the timer is currently running
  final bool isRunning;

  /// Type of fasting plan (e.g., "16:8", "18:6", "24h")
  final String planType;

  /// User ID associated with this timer
  final String userId;

  /// ID of the fasting session in Isar (if created)
  final int? sessionId;

  const TimerState({
    this.startTime,
    required this.durationMinutes,
    this.isRunning = false,
    required this.planType,
    required this.userId,
    this.sessionId,
  });

  /// Create an empty/default timer state
  factory TimerState.empty(String userId) {
    return TimerState(
      durationMinutes: 960, // Default 16 hours
      planType: '16:8',
      userId: userId,
    );
  }

  /// Calculate remaining time in milliseconds
  int get remainingMilliseconds {
    if (!isRunning || startTime == null) return 0;

    final elapsed = DateTime.now().difference(startTime!);
    final target = Duration(minutes: durationMinutes);
    final remaining = target - elapsed;

    return remaining.inMilliseconds.clamp(0, target.inMilliseconds);
  }

  /// Calculate elapsed time in milliseconds
  int get elapsedMilliseconds {
    if (!isRunning || startTime == null) return 0;

    return DateTime.now().difference(startTime!).inMilliseconds;
  }

  /// Check if timer has completed
  bool get isCompleted {
    return isRunning && remainingMilliseconds == 0;
  }

  /// Get progress as a percentage (0.0 to 1.0)
  double get progress {
    if (!isRunning || startTime == null) return 0.0;

    final elapsed = elapsedMilliseconds;
    final total = Duration(minutes: durationMinutes).inMilliseconds;

    return (elapsed / total).clamp(0.0, 1.0);
  }

  /// Format remaining time as HH:MM:SS
  String get formattedRemainingTime {
    final remaining = Duration(milliseconds: remainingMilliseconds);
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  /// Format elapsed time as HH:MM:SS
  String get formattedElapsedTime {
    final elapsed = Duration(milliseconds: elapsedMilliseconds);
    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes.remainder(60);
    final seconds = elapsed.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  /// Convert to JSON for SharedPreferences storage
  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime?.toIso8601String(),
      'durationMinutes': durationMinutes,
      'isRunning': isRunning,
      'planType': planType,
      'userId': userId,
      'sessionId': sessionId,
    };
  }

  /// Create from JSON (SharedPreferences)
  factory TimerState.fromJson(Map<String, dynamic> json) {
    return TimerState(
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : null,
      durationMinutes: json['durationMinutes'] as int,
      isRunning: json['isRunning'] as bool,
      planType: json['planType'] as String,
      userId: json['userId'] as String,
      sessionId: json['sessionId'] as int?,
    );
  }

  /// Create a copy with updated fields
  TimerState copyWith({
    DateTime? startTime,
    int? durationMinutes,
    bool? isRunning,
    String? planType,
    String? userId,
    int? sessionId,
  }) {
    return TimerState(
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isRunning: isRunning ?? this.isRunning,
      planType: planType ?? this.planType,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  @override
  String toString() {
    return 'TimerState(startTime: $startTime, duration: $durationMinutes min, '
        'isRunning: $isRunning, plan: $planType, remaining: $formattedRemainingTime)';
  }
}
