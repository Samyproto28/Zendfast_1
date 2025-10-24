import 'package:isar/isar.dart';

part 'fasting_session.g.dart';

/// Represents a fasting session for a user
/// Tracks start time, end time, duration, and completion status
@collection
class FastingSession {
  /// Auto-increment primary key
  Id id = Isar.autoIncrement;

  /// User identifier - indexed for user-specific queries
  @Index()
  late String userId;

  /// When the fasting session started
  late DateTime startTime;

  /// When the fasting session ended (null if ongoing)
  DateTime? endTime;

  /// Duration in minutes (calculated when session ends)
  int? durationMinutes;

  /// Whether the fasting session was completed successfully
  @Index()
  late bool completed;

  /// Whether the fasting session was interrupted
  late bool interrupted;

  /// Type of fasting plan (e.g., "16:8", "18:6", "OMAD", "24-hour")
  @Index(caseSensitive: false)
  late String planType;

  /// When this record was created - indexed with userId for chronological queries
  @Index(composite: [CompositeIndex('userId')])
  late DateTime createdAt;

  /// Constructor
  FastingSession({
    this.id = Isar.autoIncrement,
    required this.userId,
    required this.startTime,
    this.endTime,
    this.durationMinutes,
    this.completed = false,
    this.interrupted = false,
    required this.planType,
  }) {
    createdAt = DateTime.now();
  }

  /// Helper method to end the fasting session
  void endSession({required bool wasInterrupted}) {
    endTime = DateTime.now();
    interrupted = wasInterrupted;
    completed = !wasInterrupted;

    if (endTime != null) {
      durationMinutes = endTime!.difference(startTime).inMinutes;
    }
  }

  /// Check if the session is currently active
  @ignore
  bool get isActive => endTime == null;

  /// Get the current duration (for active sessions)
  @ignore
  Duration get currentDuration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }
}
