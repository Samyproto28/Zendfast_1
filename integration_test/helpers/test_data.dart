/// Test fixture data for E2E integration tests
/// Provides realistic test data for users, sessions, metrics, etc.
library;

import 'package:isar/isar.dart';
import 'package:zendfast_1/models/fasting_session.dart';
import 'package:zendfast_1/models/user_metrics.dart';

/// Test user data
class TestUsers {
  static const String testEmail = 'test@zendfast.com';
  static const String testPassword = 'TestPassword123!';
  static const String testUserId = 'test-user-id-12345';
  static const String testUsername = 'TestUser';

  static const String testEmail2 = 'test2@zendfast.com';
  static const String testPassword2 = 'TestPassword456!';
  static const String testUserId2 = 'test-user-id-67890';
}

/// Test fasting plan configurations
class TestFastingPlans {
  static const String plan16_8 = '16:8';
  static const String plan18_6 = '18:6';
  static const String plan20_4 = '20:4';
  static const String planOMAD = 'OMAD (23:1)';

  static const int duration16_8Hours = 16;
  static const int duration18_6Hours = 18;
  static const int duration20_4Hours = 20;
  static const int durationOMADHours = 23;
}

/// Test fasting session data
class TestSessions {
  /// Create a test fasting session with configurable parameters
  static FastingSession createSession({
    Id id = Isar.autoIncrement,
    String? userId,
    DateTime? startTime,
    DateTime? endTime,
    int durationHours = 16,
    String planType = '16:8',
    bool isCompleted = false,
    bool isInterrupted = false,
  }) {
    final session = FastingSession(
      id: id,
      userId: userId ?? TestUsers.testUserId,
      startTime: startTime ?? DateTime.now(),
      endTime: endTime,
      planType: planType,
      durationMinutes: endTime?.difference(startTime ?? DateTime.now()).inMinutes,
      completed: isCompleted,
      interrupted: isInterrupted,
    );
    return session;
  }

  /// Create a completed test session
  static FastingSession createCompletedSession({
    String planType = '16:8',
    int durationHours = 16,
  }) {
    final startTime = DateTime.now().subtract(Duration(hours: durationHours));
    final endTime = DateTime.now();

    return createSession(
      startTime: startTime,
      endTime: endTime,
      durationHours: durationHours,
      planType: planType,
      isCompleted: true,
    );
  }

  /// Create an interrupted test session
  static FastingSession createInterruptedSession({
    String planType = '16:8',
    int elapsedHours = 8,
  }) {
    final startTime = DateTime.now().subtract(Duration(hours: elapsedHours));
    final endTime = DateTime.now();

    return createSession(
      startTime: startTime,
      endTime: endTime,
      planType: planType,
      isInterrupted: true,
    );
  }

  /// Create an active (in-progress) test session
  static FastingSession createActiveSession({
    String planType = '16:8',
    int elapsedHours = 4,
  }) {
    final startTime = DateTime.now().subtract(Duration(hours: elapsedHours));

    return createSession(
      startTime: startTime,
      planType: planType,
    );
  }
}

/// Test user metrics data
class TestMetrics {
  /// Create test user metrics
  static UserMetrics createMetrics({
    Id id = Isar.autoIncrement,
    String? userId,
    int totalFasts = 0,
    int streakDays = 0,
    int longestStreak = 0,
    double totalDurationHours = 0.0,
  }) {
    return UserMetrics(
      id: id,
      userId: userId ?? TestUsers.testUserId,
      totalFasts: totalFasts,
      streakDays: streakDays,
      longestStreak: longestStreak,
      totalDurationHours: totalDurationHours,
      lastFastDate: totalFasts > 0 ? DateTime.now() : null,
    );
  }

  /// Create metrics for a user with some history
  static UserMetrics createMetricsWithHistory() {
    return createMetrics(
      totalFasts: 10,
      streakDays: 5,
      longestStreak: 7,
      totalDurationHours: 160.0,
    );
  }
}

/// Test water intake data
class TestHydration {
  static const int smallCup = 250; // 250ml
  static const int mediumCup = 500; // 500ml
  static const int largeCup = 750; // 750ml
  static const int bottle = 1000; // 1L

  static const List<int> commonIntakeAmounts = [
    smallCup,
    mediumCup,
    largeCup,
    bottle,
  ];
}

/// Test notification data
class TestNotifications {
  static const String fastingStartTitle = 'Fast Started';
  static const String fastingStartBody = 'Your fast has begun. Stay strong!';

  static const String fastingCompleteTitle = 'Fast Complete!';
  static const String fastingCompleteBody = 'Congratulations! You completed your fast.';

  static const String fastingMilestoneTitle = 'Milestone Reached';
  static const String fastingMilestoneBody = 'You\'re halfway through your fast!';

  static const String hydrationReminderTitle = 'Drink Water';
  static const String hydrationReminderBody = 'Remember to stay hydrated!';
}

/// Test environment configuration
class TestEnvironment {
  static const String testSupabaseUrl = 'https://test.supabase.co';
  static const String testSupabaseAnonKey = 'test-anon-key-12345';
  static const String testOneSignalAppId = 'test-onesignal-app-id';
}

/// Test delay constants for UI interactions
class TestDelays {
  static const Duration short = Duration(milliseconds: 100);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration long = Duration(milliseconds: 500);
  static const Duration veryLong = Duration(seconds: 1);

  /// Delay for animations to complete
  static const Duration animationComplete = Duration(milliseconds: 600);

  /// Delay for network requests (mocked)
  static const Duration networkRequest = Duration(milliseconds: 200);
}
