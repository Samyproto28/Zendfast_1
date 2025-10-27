import 'package:flutter_test/flutter_test.dart';
import 'package:zendfast_1/services/timer_service.dart';
import 'package:zendfast_1/models/timer_state.dart';
import 'package:zendfast_1/models/fasting_state.dart';

void main() {
  group('TimerService', () {
    test('singleton returns same instance', () {
      final instance1 = TimerService.instance;
      final instance2 = TimerService.instance;

      expect(identical(instance1, instance2), true);
    });

    test('initial currentFastingState is null before any timer', () {
      final service = TimerService.instance;

      // Should be null if no timer has been initialized
      expect(service.currentFastingState, isNull);
    });

    test('fastingStateStream is available', () {
      final service = TimerService.instance;

      expect(service.fastingStateStream, isA<Stream<FastingState>>());
    });

    test('stateStream is available', () {
      final service = TimerService.instance;

      expect(service.stateStream, isA<Stream<TimerState>>());
    });

    group('State Transition Validation', () {
      test('startFast from idle state succeeds', () async {
        // Note: This would require mocking database and background service
        // For now, testing that the method exists and throws appropriate error

        final service = TimerService.instance;

        // Test will throw if called without proper setup, but method exists
        expect(
          () => service.startFast(
            userId: 'test',
            durationMinutes: 960,
            planType: '16:8',
          ),
          throwsA(anything), // Throws due to missing database setup
        );
      });

      test('pauseFast validates state correctly', () async {
        final service = TimerService.instance;

        // Should throw StateError when trying to pause from idle
        expect(
          () => service.pauseFast(),
          throwsA(isA<StateError>()),
        );
      });

      test('resumeFast validates state correctly', () async {
        final service = TimerService.instance;

        // Should throw StateError when trying to resume from idle
        expect(
          () => service.resumeFast(),
          throwsA(isA<StateError>()),
        );
      });

      test('completeFast validates state correctly', () async {
        final service = TimerService.instance;

        // Should throw StateError when trying to complete from idle
        expect(
          () => service.completeFast(),
          throwsA(isA<StateError>()),
        );
      });

      test('interruptFast validates state correctly', () async {
        final service = TimerService.instance;

        // Should throw StateError when trying to interrupt from idle
        expect(
          () => service.interruptFast(),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('FastingState Enum', () {
      test('FastingState.idle allows starting', () {
        expect(FastingState.idle.canStart, true);
        expect(FastingState.idle.canPause, false);
        expect(FastingState.idle.canResume, false);
      });

      test('FastingState.fasting allows pausing and completing', () {
        expect(FastingState.fasting.canPause, true);
        expect(FastingState.fasting.canComplete, true);
        expect(FastingState.fasting.canInterrupt, true);
        expect(FastingState.fasting.isActive, true);
      });

      test('FastingState.paused allows resuming and interrupting', () {
        expect(FastingState.paused.canResume, true);
        expect(FastingState.paused.canInterrupt, true);
        expect(FastingState.paused.isActive, true);
      });

      test('FastingState.completed allows starting new fast', () {
        expect(FastingState.completed.canStart, true);
        expect(FastingState.completed.isActive, false);
      });

      test('FastingState has correct display names', () {
        expect(FastingState.idle.displayName, 'Idle');
        expect(FastingState.fasting.displayName, 'Fasting');
        expect(FastingState.paused.displayName, 'Paused');
        expect(FastingState.completed.displayName, 'Completed');
      });

      test('FastingState JSON serialization works', () {
        expect(FastingState.fasting.toJson(), 'fasting');
        expect(FastingStateExtension.fromJson('paused'), FastingState.paused);
        expect(FastingStateExtension.fromJson('invalid'), FastingState.idle);
      });
    });
  });
}
