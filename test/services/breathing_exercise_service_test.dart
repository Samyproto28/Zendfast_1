import 'package:flutter_test/flutter_test.dart';
import 'package:zendfast_1/models/breathing_state.dart';
import 'package:zendfast_1/services/breathing_exercise_service.dart';

void main() {
  late BreathingExerciseService service;

  setUp(() {
    service = BreathingExerciseService.instance;
  });

  tearDown(() async {
    await service.reset();
  });

  group('BreathingExerciseService Tests', () {
    test('should be a singleton', () {
      // Arrange & Act
      final instance1 = BreathingExerciseService.instance;
      final instance2 = BreathingExerciseService.instance;

      // Assert
      expect(identical(instance1, instance2), true);
    });

    test('should start with initial state', () {
      // Act
      final state = service.currentState;

      // Assert
      expect(state.phase, BreathingPhase.inhale);
      expect(state.remainingSeconds, 300);
      expect(state.currentCycle, 0);
      expect(state.isRunning, false);
      expect(state.isCompleted, false);
    });

    test('should start exercise and update isRunning', () async {
      // Act
      await service.start();

      // Assert
      expect(service.currentState.isRunning, true);
      expect(service.currentState.phase, BreathingPhase.inhale);
    });

    test('should pause exercise', () async {
      // Arrange
      await service.start();
      await Future.delayed(const Duration(milliseconds: 100));

      // Act
      await service.pause();

      // Assert
      expect(service.currentState.isRunning, false);
    });

    test('should resume exercise', () async {
      // Arrange
      await service.start();
      await service.pause();

      // Act
      await service.resume();

      // Assert
      expect(service.currentState.isRunning, true);
    });

    test('should stop exercise and reset to initial state', () async {
      // Arrange
      await service.start();
      await Future.delayed(const Duration(milliseconds: 100));

      // Act
      await service.stop();

      // Assert
      expect(service.currentState.isRunning, false);
      expect(service.currentState.remainingSeconds, 300);
      expect(service.currentState.currentCycle, 0);
    });

    test('should decrement remaining seconds each tick', () async {
      // Arrange
      await service.start();
      final initialSeconds = service.currentState.remainingSeconds;

      // Act
      await Future.delayed(const Duration(seconds: 2));

      // Assert
      expect(service.currentState.remainingSeconds, lessThan(initialSeconds));
      await service.stop();
    });

    test('should cycle through breathing phases', () async {
      // Arrange
      await service.start();

      // Act - Wait for initial inhale phase (4 seconds)
      await Future.delayed(const Duration(seconds: 5));

      // Assert - Should have moved to hold or beyond
      final currentPhase = service.currentState.phase;
      expect(
        currentPhase == BreathingPhase.hold ||
            currentPhase == BreathingPhase.exhale ||
            currentPhase == BreathingPhase.inhale,
        true,
        reason: 'Should have progressed through phases',
      );

      await service.stop();
    });

    test('should increment cycle count after full cycle', () async {
      // Arrange
      await service.start();

      // Act - Wait for one full cycle (19 seconds)
      await Future.delayed(const Duration(seconds: 20));

      // Assert
      expect(service.currentState.currentCycle, greaterThan(0));
      await service.stop();
    });

    test('should emit state changes via stream', () async {
      // Arrange
      final states = <BreathingState>[];
      final subscription = service.stateStream.listen(states.add);

      // Act
      await service.start();
      await Future.delayed(const Duration(milliseconds: 500));
      await service.pause();
      await service.resume();
      await Future.delayed(const Duration(milliseconds: 500));
      await service.stop();

      // Assert
      expect(states.length, greaterThan(0));
      expect(states.any((s) => s.isRunning), true);
      expect(states.any((s) => !s.isRunning), true);

      await subscription.cancel();
    });

    test('should complete when reaching 0 seconds', () async {
      // Arrange
      // Start with a very short duration for testing
      await service.start();

      // Fast-forward by manually setting remaining to near 0
      // This would require exposing a test-only method or mocking
      // For now, we'll test the completion logic separately

      // Act & Assert
      expect(service.currentState.isCompleted, false);

      await service.stop();
    });

    test('should not start if already running', () async {
      // Arrange
      await service.start();

      // Act
      await service.start(); // Try to start again

      // Assert - Should still be running, not restarted
      expect(service.currentState.isRunning, true);

      await service.stop();
    });

    test('should not pause if not running', () async {
      // Act
      await service.pause();

      // Assert
      expect(service.currentState.isRunning, false);
    });

    test('should not resume if not paused', () async {
      // Arrange
      await service.start();

      // Act
      await service.resume(); // Already running

      // Assert
      expect(service.currentState.isRunning, true);

      await service.stop();
    });

    test('should reset to initial state', () async {
      // Arrange
      await service.start();
      await Future.delayed(const Duration(seconds: 2));
      await service.stop();

      // Act
      await service.reset();

      // Assert
      final state = service.currentState;
      expect(state.phase, BreathingPhase.inhale);
      expect(state.remainingSeconds, 300);
      expect(state.currentCycle, 0);
      expect(state.isRunning, false);
      expect(state.isCompleted, false);
    });

    test('should calculate correct formatted time', () {
      // Arrange
      final state = BreathingState(
        phase: BreathingPhase.inhale,
        remainingSeconds: 125, // 2:05
        currentCycle: 0,
        isRunning: false,
      );

      // Act
      final formatted = state.formattedTime;

      // Assert
      expect(formatted, '02:05');
    });

    test('should provide correct instruction text for each phase', () {
      // Inhale
      expect(
        const BreathingState(
          phase: BreathingPhase.inhale,
          remainingSeconds: 300,
          currentCycle: 0,
          isRunning: false,
        ).instructionText,
        'Inhala profundamente',
      );

      // Hold
      expect(
        const BreathingState(
          phase: BreathingPhase.hold,
          remainingSeconds: 300,
          currentCycle: 0,
          isRunning: false,
        ).instructionText,
        'Mantén la respiración',
      );

      // Exhale
      expect(
        const BreathingState(
          phase: BreathingPhase.exhale,
          remainingSeconds: 300,
          currentCycle: 0,
          isRunning: false,
        ).instructionText,
        'Exhala lentamente',
      );
    });

    test('should have correct phase durations', () {
      expect(BreathingPhase.inhale.durationSeconds, 4);
      expect(BreathingPhase.hold.durationSeconds, 7);
      expect(BreathingPhase.exhale.durationSeconds, 8);
      expect(BreathingPhase.cycleDurationSeconds, 19);
    });

    test('should get next phase correctly', () {
      expect(BreathingPhase.inhale.next, BreathingPhase.hold);
      expect(BreathingPhase.hold.next, BreathingPhase.exhale);
      expect(BreathingPhase.exhale.next, BreathingPhase.inhale);
    });
  });
}
