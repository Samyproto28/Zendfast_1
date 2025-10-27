import 'package:flutter_test/flutter_test.dart';
import 'package:zendfast_1/models/user_metrics.dart';

void main() {
  group('UserMetrics Model Tests', () {
    test('default constructor creates empty metrics', () {
      final metrics = UserMetrics(userId: 'user123');

      expect(metrics.userId, 'user123');
      expect(metrics.totalFasts, 0);
      expect(metrics.totalDurationHours, 0.0);
      expect(metrics.streakDays, 0);
      expect(metrics.longestStreak, 0);
      expect(metrics.lastFastDate, isNull);
      expect(metrics.createdAt, isNotNull);
      expect(metrics.updatedAt, isNotNull);
      expect(metrics.syncVersion, 1);
    });

    group('addCompletedFast() Tests', () {
      test('first completed fast initializes metrics correctly', () {
        final metrics = UserMetrics(userId: 'user123');
        final completedAt = DateTime(2024, 1, 15, 18, 0);

        metrics.addCompletedFast(
          durationMinutes: 960, // 16 hours
          completedAt: completedAt,
        );

        expect(metrics.totalFasts, 1);
        expect(metrics.totalDurationHours, 16.0);
        expect(metrics.streakDays, 1);
        expect(metrics.longestStreak, 1);
        expect(metrics.lastFastDate, completedAt);
        expect(metrics.syncVersion, 2); // Incremented
      });

      test('consecutive fasts within 1 day continue streak', () {
        final metrics = UserMetrics(userId: 'user123');
        final day1 = DateTime(2024, 1, 15, 18, 0);
        final day2 = DateTime(2024, 1, 16, 18, 0); // Next day

        metrics.addCompletedFast(durationMinutes: 960, completedAt: day1);
        metrics.addCompletedFast(durationMinutes: 960, completedAt: day2);

        expect(metrics.totalFasts, 2);
        expect(metrics.totalDurationHours, 32.0);
        expect(metrics.streakDays, 2);
        expect(metrics.longestStreak, 2);
        expect(metrics.lastFastDate, day2);
      });

      test('fasts after 2+ days reset streak', () {
        final metrics = UserMetrics(userId: 'user123');
        final day1 = DateTime(2024, 1, 15, 18, 0);
        final day2 = DateTime(2024, 1, 18, 18, 0); // 3 days later

        metrics.addCompletedFast(durationMinutes: 960, completedAt: day1);
        metrics.addCompletedFast(durationMinutes: 960, completedAt: day2);

        expect(metrics.totalFasts, 2);
        expect(metrics.totalDurationHours, 32.0);
        expect(metrics.streakDays, 1); // Reset to 1
        expect(metrics.longestStreak, 1); // Previous streak was only 1 day
        expect(metrics.lastFastDate, day2);
      });

      test('longestStreak tracks maximum streak achieved', () {
        final metrics = UserMetrics(userId: 'user123');

        // Build up a 5-day streak
        for (var i = 0; i < 5; i++) {
          metrics.addCompletedFast(
            durationMinutes: 960,
            completedAt: DateTime(2024, 1, 15 + i, 18, 0),
          );
        }

        expect(metrics.streakDays, 5);
        expect(metrics.longestStreak, 5);

        // Break streak with 3-day gap
        metrics.addCompletedFast(
          durationMinutes: 960,
          completedAt: DateTime(2024, 1, 23, 18, 0),
        );

        expect(metrics.streakDays, 1); // Reset
        expect(metrics.longestStreak, 5); // Still remembers longest
      });

      test('duration accumulates correctly across multiple fasts', () {
        final metrics = UserMetrics(userId: 'user123');

        metrics.addCompletedFast(
          durationMinutes: 960,
          completedAt: DateTime(2024, 1, 15, 18, 0),
        ); // 16 hours
        metrics.addCompletedFast(
          durationMinutes: 720,
          completedAt: DateTime(2024, 1, 16, 18, 0),
        ); // 12 hours
        metrics.addCompletedFast(
          durationMinutes: 1440,
          completedAt: DateTime(2024, 1, 17, 18, 0),
        ); // 24 hours

        expect(metrics.totalFasts, 3);
        expect(metrics.totalDurationHours, 52.0); // 16 + 12 + 24
      });

      test('same-day fasts continue streak', () {
        final metrics = UserMetrics(userId: 'user123');
        final morning = DateTime(2024, 1, 15, 8, 0);
        final evening = DateTime(2024, 1, 15, 20, 0);

        metrics.addCompletedFast(durationMinutes: 480, completedAt: morning);
        metrics.addCompletedFast(durationMinutes: 480, completedAt: evening);

        expect(metrics.totalFasts, 2);
        expect(metrics.streakDays, 2); // Same day counts as continuing
      });
    });

    group('addInterruptedFast() Tests', () {
      test('interrupted fast adds partial duration but not to total fasts', () {
        final metrics = UserMetrics(userId: 'user123');
        final interruptedAt = DateTime(2024, 1, 15, 12, 0);

        metrics.addInterruptedFast(
          durationMinutes: 480, // 8 hours
          interruptedAt: interruptedAt,
        );

        expect(metrics.totalFasts, 0); // Not incremented for interruptions
        expect(metrics.totalDurationHours, 8.0); // Partial credit
        expect(metrics.streakDays, 0); // No streak for first fast if interrupted
        expect(metrics.lastFastDate, isNull); // Not updated for interruptions
        expect(metrics.syncVersion, 2); // Still incremented
      });

      test('interrupted fast does not break streak if within 2 days', () {
        final metrics = UserMetrics(userId: 'user123');
        final day1 = DateTime(2024, 1, 15, 18, 0);
        final day2 = DateTime(2024, 1, 16, 12, 0);

        metrics.addCompletedFast(durationMinutes: 960, completedAt: day1);
        metrics.addInterruptedFast(
          durationMinutes: 480,
          interruptedAt: day2,
        );

        expect(metrics.streakDays, 1); // Preserved
        expect(metrics.totalFasts, 1); // Only completed count
        expect(metrics.totalDurationHours, 24.0); // 16 + 8
      });

      test('interrupted fast breaks streak if after 2 days', () {
        final metrics = UserMetrics(userId: 'user123');
        final day1 = DateTime(2024, 1, 15, 18, 0);
        final day5 = DateTime(2024, 1, 20, 12, 0); // 5 days later

        metrics.addCompletedFast(durationMinutes: 960, completedAt: day1);
        metrics.addInterruptedFast(
          durationMinutes: 480,
          interruptedAt: day5,
        );

        expect(metrics.streakDays, 0); // Broken
        expect(metrics.totalFasts, 1);
        expect(metrics.totalDurationHours, 24.0);
      });

      test('interrupted fast on same day as last fast preserves streak', () {
        final metrics = UserMetrics(userId: 'user123');
        final morning = DateTime(2024, 1, 15, 8, 0);
        final afternoon = DateTime(2024, 1, 15, 14, 0);

        metrics.addCompletedFast(durationMinutes: 480, completedAt: morning);
        metrics.addInterruptedFast(
          durationMinutes: 300,
          interruptedAt: afternoon,
        );

        expect(metrics.streakDays, 1); // Preserved
        expect(metrics.totalFasts, 1);
      });
    });

    group('Helper Methods Tests', () {
      test('averageFastDuration calculates correctly', () {
        final metrics = UserMetrics(userId: 'user123');

        metrics.addCompletedFast(
          durationMinutes: 960,
          completedAt: DateTime(2024, 1, 15),
        ); // 16h
        metrics.addCompletedFast(
          durationMinutes: 720,
          completedAt: DateTime(2024, 1, 16),
        ); // 12h
        metrics.addCompletedFast(
          durationMinutes: 1440,
          completedAt: DateTime(2024, 1, 17),
        ); // 24h

        // Average = (16 + 12 + 24) / 3 = 17.33 hours
        expect(metrics.averageFastDuration, closeTo(17.33, 0.01));
      });

      test('averageFastDuration returns 0 for no fasts', () {
        final metrics = UserMetrics(userId: 'user123');

        expect(metrics.averageFastDuration, 0.0);
      });

      test('averageFastDuration includes partial durations from interruptions', () {
        final metrics = UserMetrics(userId: 'user123');

        metrics.addCompletedFast(
          durationMinutes: 960,
          completedAt: DateTime(2024, 1, 15),
        ); // 16h
        metrics.addInterruptedFast(
          durationMinutes: 480,
          interruptedAt: DateTime(2024, 1, 16),
        ); // 8h

        // Average = (16 + 8) / 1 completed fast = 24 hours
        // But actually it's total duration / total fasts
        // With current implementation: 24 / 1 = 24.0
        expect(metrics.averageFastDuration, 24.0);
      });
    });

    group('JSON Serialization Tests', () {
      test('toJson() serializes all fields correctly', () {
        final metrics = UserMetrics(userId: 'user123');
        final completedAt = DateTime(2024, 1, 15, 18, 0);

        metrics.addCompletedFast(durationMinutes: 960, completedAt: completedAt);

        final json = metrics.toJson();

        expect(json['user_id'], 'user123');
        expect(json['total_fasts'], 1);
        expect(json['total_duration_hours'], 16.0);
        expect(json['streak_days'], 1);
        expect(json['longest_streak'], 1);
        expect(json['last_fast_date'], isNotNull);
        expect(json['created_at'], isNotNull);
        expect(json['updated_at'], isNotNull);
        expect(json['sync_version'], 2);
      });

      test('fromJson() deserializes all fields correctly', () {
        final json = {
          'user_id': 'user123',
          'total_fasts': 10,
          'total_duration_hours': 160.5,
          'streak_days': 5,
          'longest_streak': 12,
          'last_fast_date': DateTime(2024, 1, 20).toIso8601String(),
          'created_at': DateTime(2024, 1, 1).toIso8601String(),
          'updated_at': DateTime(2024, 1, 20).toIso8601String(),
          'sync_version': 25,
        };

        final metrics = UserMetrics.fromJson(json);

        expect(metrics.userId, 'user123');
        expect(metrics.totalFasts, 10);
        expect(metrics.totalDurationHours, 160.5);
        expect(metrics.streakDays, 5);
        expect(metrics.longestStreak, 12);
        expect(metrics.lastFastDate, DateTime(2024, 1, 20));
        expect(metrics.createdAt, DateTime(2024, 1, 1));
        expect(metrics.updatedAt, DateTime(2024, 1, 20));
        expect(metrics.syncVersion, 25);
      });

      test('JSON roundtrip preserves all data', () {
        final original = UserMetrics(userId: 'user123');

        original.addCompletedFast(
          durationMinutes: 960,
          completedAt: DateTime(2024, 1, 15, 18, 0),
        );
        original.addCompletedFast(
          durationMinutes: 720,
          completedAt: DateTime(2024, 1, 16, 18, 0),
        );

        final json = original.toJson();
        final restored = UserMetrics.fromJson(json);

        expect(restored.userId, original.userId);
        expect(restored.totalFasts, original.totalFasts);
        expect(restored.totalDurationHours, original.totalDurationHours);
        expect(restored.streakDays, original.streakDays);
        expect(restored.longestStreak, original.longestStreak);
        expect(restored.syncVersion, original.syncVersion);
      });

      test('fromJson() handles missing optional fields', () {
        final json = {
          'user_id': 'user123',
          'total_fasts': 0,
          'total_duration_hours': 0.0,
          'streak_days': 0,
          'longest_streak': 0,
          // Missing last_fast_date
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          // Missing sync_version
        };

        final metrics = UserMetrics.fromJson(json);

        expect(metrics.lastFastDate, isNull);
        expect(metrics.syncVersion, 1); // Default value
      });
    });

    group('SyncVersion Tests', () {
      test('markUpdated() increments syncVersion', () {
        final metrics = UserMetrics(userId: 'user123');

        expect(metrics.syncVersion, 1);

        metrics.markUpdated();
        expect(metrics.syncVersion, 2);

        metrics.markUpdated();
        expect(metrics.syncVersion, 3);
      });

      test('addCompletedFast() increments syncVersion', () {
        final metrics = UserMetrics(userId: 'user123');
        final initialVersion = metrics.syncVersion;

        metrics.addCompletedFast(
          durationMinutes: 960,
          completedAt: DateTime.now(),
        );

        expect(metrics.syncVersion, initialVersion + 1);
      });

      test('addInterruptedFast() increments syncVersion', () {
        final metrics = UserMetrics(userId: 'user123');
        final initialVersion = metrics.syncVersion;

        metrics.addInterruptedFast(
          durationMinutes: 480,
          interruptedAt: DateTime.now(),
        );

        expect(metrics.syncVersion, initialVersion + 1);
      });
    });

    group('Edge Cases Tests', () {
      test('handles zero duration fast', () {
        final metrics = UserMetrics(userId: 'user123');

        metrics.addCompletedFast(
          durationMinutes: 0,
          completedAt: DateTime.now(),
        );

        expect(metrics.totalFasts, 1);
        expect(metrics.totalDurationHours, 0.0);
        expect(metrics.streakDays, 1);
      });

      test('handles very long fast (48+ hours)', () {
        final metrics = UserMetrics(userId: 'user123');

        metrics.addCompletedFast(
          durationMinutes: 2880, // 48 hours
          completedAt: DateTime.now(),
        );

        expect(metrics.totalFasts, 1);
        expect(metrics.totalDurationHours, 48.0);
      });

      test('handles fractional hours correctly', () {
        final metrics = UserMetrics(userId: 'user123');

        metrics.addCompletedFast(
          durationMinutes: 545, // 9.083 hours
          completedAt: DateTime.now(),
        );

        expect(metrics.totalDurationHours, closeTo(9.083, 0.001));
      });

      test('handles large number of fasts', () {
        final metrics = UserMetrics(userId: 'user123');
        final startDate = DateTime(2024, 1, 1);

        // Add 100 consecutive daily fasts
        for (var i = 0; i < 100; i++) {
          metrics.addCompletedFast(
            durationMinutes: 960,
            completedAt: startDate.add(Duration(days: i)),
          );
        }

        expect(metrics.totalFasts, 100);
        expect(metrics.streakDays, 100);
        expect(metrics.longestStreak, 100);
        expect(metrics.totalDurationHours, 1600.0);
      });

      test('handles streak calculation across month boundaries', () {
        final metrics = UserMetrics(userId: 'user123');

        metrics.addCompletedFast(
          durationMinutes: 960,
          completedAt: DateTime(2024, 1, 31, 18, 0),
        );
        metrics.addCompletedFast(
          durationMinutes: 960,
          completedAt: DateTime(2024, 2, 1, 18, 0),
        );

        expect(metrics.streakDays, 2);
        expect(metrics.lastFastDate, DateTime(2024, 2, 1, 18, 0));
      });

      test('handles streak calculation across year boundaries', () {
        final metrics = UserMetrics(userId: 'user123');

        metrics.addCompletedFast(
          durationMinutes: 960,
          completedAt: DateTime(2023, 12, 31, 18, 0),
        );
        metrics.addCompletedFast(
          durationMinutes: 960,
          completedAt: DateTime(2024, 1, 1, 18, 0),
        );

        expect(metrics.streakDays, 2);
      });
    });
  });
}
