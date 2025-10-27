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

  /// Reason for interruption (null if not interrupted or completed)
  String? interruptionReason;

  /// When this record was created - indexed with userId for chronological queries
  @Index(composite: [CompositeIndex('userId')])
  late DateTime createdAt;

  /// When this record was last updated
  late DateTime updatedAt;

  /// Sync version for Supabase conflict resolution
  int? syncVersion;

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
    this.interruptionReason,
    this.syncVersion,
  }) {
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }

  /// Helper method to end the fasting session
  void endSession({required bool wasInterrupted, String? reason}) {
    endTime = DateTime.now();
    interrupted = wasInterrupted;
    completed = !wasInterrupted;
    interruptionReason = reason;

    if (endTime != null) {
      durationMinutes = endTime!.difference(startTime).inMinutes;
    }

    markUpdated();
  }

  /// Helper method to update the timestamp
  void markUpdated() {
    updatedAt = DateTime.now();
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

  /// Get elapsed time from start to now (or end time if completed)
  @ignore
  Duration get elapsedTime {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  /// Get progress percentage as 0.0-1.0 (matches TimerState pattern)
  /// Returns progress based on elapsed time vs target duration
  @ignore
  double get progressPercentage {
    if (durationMinutes == null || durationMinutes! <= 0) return 0.0;

    final elapsed = elapsedTime.inMinutes;
    final progress = elapsed / durationMinutes!;

    return progress.clamp(0.0, 1.0);
  }

  /// Convert to JSON for Supabase synchronization (snake_case keys)
  Map<String, dynamic> toJson() {
    return {
      'id': id == Isar.autoIncrement ? null : id,
      'user_id': userId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'duration_minutes': durationMinutes,
      'completed': completed,
      'interrupted': interrupted,
      'plan_type': planType,
      'interruption_reason': interruptionReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sync_version': syncVersion,
    };
  }

  /// Create from JSON (Supabase synchronization with snake_case keys)
  factory FastingSession.fromJson(Map<String, dynamic> json) {
    final session = FastingSession(
      userId: json['user_id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
      durationMinutes: json['duration_minutes'] as int?,
      completed: json['completed'] as bool? ?? false,
      interrupted: json['interrupted'] as bool? ?? false,
      planType: json['plan_type'] as String,
      interruptionReason: json['interruption_reason'] as String?,
      syncVersion: json['sync_version'] as int?,
    );

    // Set id if provided (from Supabase)
    if (json['id'] != null) {
      session.id = json['id'] as int;
    }

    // Set timestamps if provided (otherwise constructor sets them)
    if (json['created_at'] != null) {
      session.createdAt = DateTime.parse(json['created_at'] as String);
    }
    if (json['updated_at'] != null) {
      session.updatedAt = DateTime.parse(json['updated_at'] as String);
    }

    return session;
  }
}
