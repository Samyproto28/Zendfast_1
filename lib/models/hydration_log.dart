import 'package:isar/isar.dart';

part 'hydration_log.g.dart';

/// Represents a hydration log entry for tracking water intake
/// Each entry records the amount of water consumed at a specific time
@collection
class HydrationLog {
  /// Auto-increment primary key
  Id id = Isar.autoIncrement;

  /// User identifier - indexed for user-specific queries
  @Index()
  late String userId;

  /// Amount of water consumed in milliliters
  late double amountMl;

  /// When the hydration was logged - indexed with userId for time-based queries
  @Index(composite: [CompositeIndex('userId')])
  late DateTime timestamp;

  /// When this record was created (for audit purposes)
  late DateTime createdAt;

  /// Constructor
  HydrationLog({
    this.id = Isar.autoIncrement,
    required this.userId,
    required this.amountMl,
  }) {
    timestamp = DateTime.now();
    createdAt = DateTime.now();
  }

  /// Get amount in liters
  @ignore
  double get amountLiters => amountMl / 1000;

  /// Get amount in fluid ounces (for US users)
  @ignore
  double get amountOz => amountMl / 29.5735;

  /// Check if this log entry is from today
  @ignore
  bool get isToday {
    final now = DateTime.now();
    return timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day;
  }

  /// Helper method to create a log for a specific volume in liters
  factory HydrationLog.fromLiters({
    required String userId,
    required double liters,
  }) {
    return HydrationLog(
      userId: userId,
      amountMl: liters * 1000,
    );
  }

  /// Helper method to create a log for a specific volume in ounces
  factory HydrationLog.fromOunces({
    required String userId,
    required double ounces,
  }) {
    return HydrationLog(
      userId: userId,
      amountMl: ounces * 29.5735,
    );
  }
}
