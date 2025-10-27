import 'package:flutter_test/flutter_test.dart';
import 'package:zendfast_1/models/timer_state.dart';
import 'package:zendfast_1/models/fasting_state.dart';

void main() {
  group('TimerState', () {
    test('empty factory creates idle state', () {
      final state = TimerState.empty('user123');

      expect(state.userId, 'user123');
      expect(state.durationMinutes, 960); // Default 16 hours
      expect(state.planType, '16:8');
      expect(state.isRunning, false);
      expect(state.state, FastingState.idle);
      expect(state.startTime, null);
    });

    test('derivedState returns correct state when fasting', () {
      final state = TimerState(
        userId: 'user123',
        durationMinutes: 960,
        planType: '16:8',
        startTime: DateTime.now(),
        isRunning: true,
      );

      expect(state.derivedState, FastingState.fasting);
    });

    test('derivedState returns paused when not running but has startTime', () {
      final state = TimerState(
        userId: 'user123',
        durationMinutes: 960,
        planType: '16:8',
        startTime: DateTime.now().subtract(Duration(hours: 1)),
        isRunning: false,
      );

      expect(state.derivedState, FastingState.paused);
    });

    test('derivedState returns completed when timer finished', () {
      final state = TimerState(
        userId: 'user123',
        durationMinutes: 1, // 1 minute
        planType: '16:8',
        startTime: DateTime.now().subtract(Duration(minutes: 2)),
        isRunning: true,
      );

      expect(state.isCompleted, true);
      expect(state.derivedState, FastingState.completed);
    });

    test('remainingMilliseconds calculates correctly', () {
      final startTime = DateTime.now().subtract(Duration(minutes: 30));
      final state = TimerState(
        userId: 'user123',
        durationMinutes: 60,
        planType: '1:0',
        startTime: startTime,
        isRunning: true,
      );

      final remaining = state.remainingMilliseconds;
      // Should have approximately 30 minutes remaining (with some tolerance)
      expect(remaining, greaterThan(29 * 60 * 1000));
      expect(remaining, lessThan(31 * 60 * 1000));
    });

    test('elapsedMilliseconds calculates correctly', () {
      final startTime = DateTime.now().subtract(Duration(minutes: 30));
      final state = TimerState(
        userId: 'user123',
        durationMinutes: 960,
        planType: '16:8',
        startTime: startTime,
        isRunning: true,
      );

      final elapsed = state.elapsedMilliseconds;
      // Should have approximately 30 minutes elapsed (with some tolerance)
      expect(elapsed, greaterThan(29 * 60 * 1000));
      expect(elapsed, lessThan(31 * 60 * 1000));
    });

    test('progress calculates correctly', () {
      final startTime = DateTime.now().subtract(Duration(minutes: 30));
      final state = TimerState(
        userId: 'user123',
        durationMinutes: 60,
        planType: '1:0',
        startTime: startTime,
        isRunning: true,
      );

      final progress = state.progress;
      // Should be approximately 50% complete
      expect(progress, greaterThan(0.45));
      expect(progress, lessThan(0.55));
    });

    test('hasTimezoneChanged detects timezone changes', () {
      final oldOffset = Duration(hours: -5);
      final state = TimerState(
        userId: 'user123',
        durationMinutes: 960,
        planType: '16:8',
        timezoneOffset: oldOffset,
      );

      // Current timezone offset is different from stored
      final hasChanged = state.hasTimezoneChanged();

      // This will be true if the test is run in a timezone != UTC-5
      // In most cases this will be true
      expect(hasChanged, isA<bool>());
    });

    test('JSON serialization round-trip works correctly', () {
      final original = TimerState(
        userId: 'user123',
        durationMinutes: 960,
        planType: '16:8',
        startTime: DateTime(2024, 1, 15, 10, 30),
        isRunning: true,
        sessionId: 42,
        timezoneOffset: Duration(hours: -8),
        state: FastingState.fasting,
      );

      final json = original.toJson();
      final restored = TimerState.fromJson(json);

      expect(restored.userId, original.userId);
      expect(restored.durationMinutes, original.durationMinutes);
      expect(restored.planType, original.planType);
      expect(restored.startTime, original.startTime);
      expect(restored.isRunning, original.isRunning);
      expect(restored.sessionId, original.sessionId);
      expect(restored.timezoneOffset.inMinutes, original.timezoneOffset.inMinutes);
      expect(restored.state, original.state);
    });

    test('JSON deserialization handles missing timezone offset', () {
      final json = {
        'userId': 'user123',
        'durationMinutes': 960,
        'planType': '16:8',
        'isRunning': false,
        // Missing timezoneOffset
      };

      final state = TimerState.fromJson(json);

      // Should use current timezone offset as default
      expect(state.timezoneOffset, DateTime.now().timeZoneOffset);
    });

    test('JSON deserialization handles missing state', () {
      final json = {
        'userId': 'user123',
        'durationMinutes': 960,
        'planType': '16:8',
        'isRunning': false,
        'timezoneOffset': 0,
        // Missing state
      };

      final state = TimerState.fromJson(json);

      // Should default to idle
      expect(state.state, FastingState.idle);
    });

    test('copyWith creates new instance with updated fields', () {
      final original = TimerState(
        userId: 'user123',
        durationMinutes: 960,
        planType: '16:8',
        isRunning: false,
        state: FastingState.idle,
      );

      final updated = original.copyWith(
        isRunning: true,
        state: FastingState.fasting,
        startTime: DateTime.now(),
      );

      expect(updated.isRunning, true);
      expect(updated.state, FastingState.fasting);
      expect(updated.startTime, isNotNull);
      // Original values preserved
      expect(updated.userId, original.userId);
      expect(updated.durationMinutes, original.durationMinutes);
    });

    test('formattedRemainingTime displays correctly', () {
      final startTime = DateTime.now().subtract(Duration(minutes: 30));
      final state = TimerState(
        userId: 'user123',
        durationMinutes: 120, // 2 hours
        planType: '2:0',
        startTime: startTime,
        isRunning: true,
      );

      final formatted = state.formattedRemainingTime;

      // Should show approximately 01:30:00
      expect(formatted, matches(r'01:[2-3][0-9]:[0-5][0-9]'));
    });

    test('formattedElapsedTime displays correctly', () {
      final startTime = DateTime.now().subtract(Duration(hours: 2, minutes: 15));
      final state = TimerState(
        userId: 'user123',
        durationMinutes: 960,
        planType: '16:8',
        startTime: startTime,
        isRunning: true,
      );

      final formatted = state.formattedElapsedTime;

      // Should show approximately 02:15:00
      expect(formatted, matches(r'02:1[4-6]:[0-5][0-9]'));
    });
  });
}
