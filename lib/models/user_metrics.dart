import 'package:isar/isar.dart';

part 'user_metrics.g.dart';

/// Represents aggregated metrics and statistics for a user
/// Tracks total fasts, duration, streak, and last fast date
@collection
class UserMetrics {
  /// Auto-increment primary key
  Id id = Isar.autoIncrement;

  /// User identifier - unique index (one metrics record per user)
  @Index(unique: true)
  late String userId;

  /// Total number of completed fasts
  late int totalFasts;

  /// Total fasting duration in hours (can be decimal)
  late double totalDurationHours;

  /// Current fasting streak in days
  late int streakDays;

  /// Longest fasting streak ever achieved (in days)
  late int longestStreak;

  /// Date of the most recent completed fast
  DateTime? lastFastDate;

  /// When this record was created
  late DateTime createdAt;

  /// When this record was last updated
  late DateTime updatedAt;

  /// Sync version for Supabase conflict resolution
  late int syncVersion;

  /// Constructor
  UserMetrics({
    this.id = Isar.autoIncrement,
    required this.userId,
    this.totalFasts = 0,
    this.totalDurationHours = 0.0,
    this.streakDays = 0,
    this.longestStreak = 0,
    this.lastFastDate,
    this.syncVersion = 1,
  }) {
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }

  /// Calculate average fasting duration in hours
  double get averageFastDuration {
    if (totalFasts == 0) return 0.0;
    return totalDurationHours / totalFasts;
  }

  /// Helper method to update the timestamp and increment sync version
  void markUpdated() {
    updatedAt = DateTime.now();
    syncVersion++;
  }

  /// Add a completed fast to metrics
  /// Updates total fasts, duration, and calculates streak
  void addCompletedFast({
    required int durationMinutes,
    required DateTime completedAt,
  }) {
    totalFasts++;
    totalDurationHours += durationMinutes / 60.0;

    // Update streak
    if (lastFastDate != null) {
      final daysSinceLastFast = completedAt.difference(lastFastDate!).inDays;

      if (daysSinceLastFast <= 1) {
        // Continue streak (same day or next day)
        streakDays++;
      } else {
        // Streak broken, restart
        streakDays = 1;
      }
    } else {
      // First fast
      streakDays = 1;
    }

    // Update longest streak if current is higher
    if (streakDays > longestStreak) {
      longestStreak = streakDays;
    }

    lastFastDate = completedAt;
    markUpdated();
  }

  /// Add a partial/interrupted fast to metrics
  /// Adds partial duration but doesn't break streak if within 2 days
  void addInterruptedFast({
    required int durationMinutes,
    required DateTime interruptedAt,
  }) {
    // Add partial duration (partial credit)
    totalDurationHours += durationMinutes / 60.0;

    // Don't break streak if interrupted within reasonable time
    if (lastFastDate != null) {
      final daysSinceLastFast = interruptedAt.difference(lastFastDate!).inDays;

      if (daysSinceLastFast > 2) {
        // Streak broken only if > 2 days since last fast
        streakDays = 0;
      }
      // Otherwise maintain current streak
    }

    // Note: We don't update lastFastDate or increment totalFasts for interruptions
    markUpdated();
  }

  /// Convert to JSON for Supabase synchronization (snake_case keys)
  Map<String, dynamic> toJson() {
    return {
      'id': id == Isar.autoIncrement ? null : id,
      'user_id': userId,
      'total_fasts': totalFasts,
      'total_duration_hours': totalDurationHours,
      'streak_days': streakDays,
      'longest_streak': longestStreak,
      'last_fast_date': lastFastDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sync_version': syncVersion,
    };
  }

  /// Create from JSON (Supabase synchronization with snake_case keys)
  factory UserMetrics.fromJson(Map<String, dynamic> json) {
    final metrics = UserMetrics(
      userId: json['user_id'] as String,
      totalFasts: json['total_fasts'] as int? ?? 0,
      totalDurationHours: (json['total_duration_hours'] as num?)?.toDouble() ?? 0.0,
      streakDays: json['streak_days'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      lastFastDate: json['last_fast_date'] != null
          ? DateTime.parse(json['last_fast_date'] as String)
          : null,
      syncVersion: json['sync_version'] as int? ?? 1,
    );

    // Set id if provided (from Supabase)
    if (json['id'] != null) {
      metrics.id = json['id'] as int;
    }

    // Set timestamps if provided (otherwise constructor sets them)
    if (json['created_at'] != null) {
      metrics.createdAt = DateTime.parse(json['created_at'] as String);
    }
    if (json['updated_at'] != null) {
      metrics.updatedAt = DateTime.parse(json['updated_at'] as String);
    }

    return metrics;
  }
}
