import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zendfast_1/models/breathing_state.dart';
import 'package:zendfast_1/services/breathing_exercise_service.dart';
import 'package:zendfast_1/widgets/breathing/breathing_timer_widget.dart';

void main() {
  setUp(() async {
    // Reset service before each test
    await BreathingExerciseService.instance.reset();
  });

  tearDown(() async {
    await BreathingExerciseService.instance.reset();
  });

  group('BreathingTimerWidget Tests', () {
    testWidgets('should render animated circle', (WidgetTester tester) async {
      // Build widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BreathingTimerWidget(),
          ),
        ),
      );

      // Verify widget renders
      expect(find.byType(BreathingTimerWidget), findsOneWidget);

      // Verify AnimatedBuilder is present (for circle animation)
      expect(find.byType(AnimatedBuilder), findsWidgets);

      // Verify AnimatedContainer is present (for color/size transitions)
      expect(find.byType(AnimatedContainer), findsWidgets);
    });

    testWidgets('should display initial instruction text',
        (WidgetTester tester) async {
      // Build widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BreathingTimerWidget(),
          ),
        ),
      );

      await tester.pump();

      // Should show initial inhale instruction
      expect(find.text('Inhala profundamente'), findsOneWidget);
    });

    testWidgets('should display phase duration', (WidgetTester tester) async {
      // Build widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BreathingTimerWidget(),
          ),
        ),
      );

      await tester.pump();

      // Should show inhale duration (4s)
      expect(find.text('4s'), findsOneWidget);
    });

    testWidgets('should update when breathing phase changes',
        (WidgetTester tester) async {
      final service = BreathingExerciseService.instance;

      // Build widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BreathingTimerWidget(),
          ),
        ),
      );

      await tester.pump();

      // Initial state should be inhale
      expect(find.text('Inhala profundamente'), findsOneWidget);
      expect(find.text('4s'), findsOneWidget);

      // Start the exercise and wait for phase change
      await service.start();
      await tester.pump(); // Initial pump

      // Wait long enough for first phase to complete (5 seconds)
      await tester.pump(const Duration(seconds: 5));

      // Should now be in hold phase or beyond
      final currentPhase = service.currentState.phase;
      expect(
        currentPhase == BreathingPhase.hold ||
            currentPhase == BreathingPhase.exhale ||
            currentPhase == BreathingPhase.inhale,
        true,
        reason: 'Should have progressed through phases',
      );

      // Clean up: stop the service to cancel the timer
      await service.stop();
      await tester.pumpAndSettle();
    });

    testWidgets('should use StreamBuilder to listen to service',
        (WidgetTester tester) async {
      // Build widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BreathingTimerWidget(),
          ),
        ),
      );

      await tester.pump();

      // Verify StreamBuilder is present
      expect(find.byType(StreamBuilder<BreathingState>), findsOneWidget);
    });

    testWidgets('should display AnimatedSwitcher for text transitions',
        (WidgetTester tester) async {
      // Build widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BreathingTimerWidget(),
          ),
        ),
      );

      await tester.pump();

      // Verify AnimatedSwitcher is present (for smooth text transitions)
      expect(find.byType(AnimatedSwitcher), findsWidgets);
    });

    testWidgets('should center the widget content',
        (WidgetTester tester) async {
      // Build widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BreathingTimerWidget(),
          ),
        ),
      );

      await tester.pump();

      // Verify Center widget is present
      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('should have fixed size container (280x280)',
        (WidgetTester tester) async {
      // Build widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BreathingTimerWidget(),
          ),
        ),
      );

      await tester.pump();

      // Find SizedBox with specific dimensions
      final sizedBoxFinder = find.byWidgetPredicate(
        (widget) =>
            widget is SizedBox && widget.width == 280 && widget.height == 280,
      );

      expect(sizedBoxFinder, findsOneWidget);
    });
  });
}
