import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zendfast_1/models/fasting_state.dart';
import 'package:zendfast_1/models/timer_state.dart';
import 'package:zendfast_1/providers/timer_provider.dart';
import 'package:zendfast_1/theme/colors.dart';
import 'package:zendfast_1/widgets/fasting/panic_button.dart';

// Mock TimerNotifier for testing
class MockTimerNotifier extends TimerNotifier {
  final TimerState? mockState;

  MockTimerNotifier(this.mockState) : super() {
    state = mockState;
  }
}

void main() {
  group('PanicButton', () {
    // Helper to create a test widget with provider overrides
    Widget createTestWidget(TimerState? timerState) {
      final container = ProviderContainer(
        overrides: [
          timerProvider.overrideWith((ref) => MockTimerNotifier(timerState)),
        ],
      );

      return UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            floatingActionButton: const PanicButton(),
          ),
        ),
      );
    }

    // Helper to create a fasting state
    TimerState createTimerState(FastingState state) {
      return TimerState(
        startTime: state == FastingState.idle ? null : DateTime.now(),
        durationMinutes: 180,
        isRunning: state == FastingState.fasting,
        planType: '16:8',
        userId: 'test-user',
        sessionId: 1,
        timezoneOffset: Duration.zero,
        state: state,
      );
    }

    group('Visibility', () {
      testWidgets('shows FAB when fasting state is fasting', (tester) async {
        final timerState = createTimerState(FastingState.fasting);
        await tester.pumpWidget(createTestWidget(timerState));

        expect(find.byType(FloatingActionButton), findsOneWidget);
      });

      testWidgets('shows FAB when fasting state is paused', (tester) async {
        final timerState = createTimerState(FastingState.paused);
        await tester.pumpWidget(createTestWidget(timerState));

        expect(find.byType(FloatingActionButton), findsOneWidget);
      });

      testWidgets('hides FAB when fasting state is idle', (tester) async {
        final timerState = createTimerState(FastingState.idle);
        await tester.pumpWidget(createTestWidget(timerState));

        expect(find.byType(FloatingActionButton), findsNothing);
      });

      testWidgets('hides FAB when fasting state is completed', (tester) async {
        final timerState = createTimerState(FastingState.completed);
        await tester.pumpWidget(createTestWidget(timerState));

        expect(find.byType(FloatingActionButton), findsNothing);
      });

      testWidgets('hides FAB when timer state is null', (tester) async {
        await tester.pumpWidget(createTestWidget(null));

        expect(find.byType(FloatingActionButton), findsNothing);
      });
    });

    group('Styling', () {
      testWidgets('FAB has correct orange color', (tester) async {
        final timerState = createTimerState(FastingState.fasting);
        await tester.pumpWidget(createTestWidget(timerState));

        final fab = tester.widget<FloatingActionButton>(
          find.byType(FloatingActionButton),
        );

        expect(fab.backgroundColor, equals(ZendfastColors.panicOrange));
      });

      testWidgets('FAB has heart icon', (tester) async {
        final timerState = createTimerState(FastingState.fasting);
        await tester.pumpWidget(createTestWidget(timerState));

        expect(find.byIcon(Icons.favorite), findsOneWidget);
      });

      testWidgets('FAB has white icon color', (tester) async {
        final timerState = createTimerState(FastingState.fasting);
        await tester.pumpWidget(createTestWidget(timerState));

        final icon = tester.widget<Icon>(find.byIcon(Icons.favorite));

        expect(icon.color, equals(Colors.white));
      });

      testWidgets('FAB has correct elevation', (tester) async {
        final timerState = createTimerState(FastingState.fasting);
        await tester.pumpWidget(createTestWidget(timerState));

        final fab = tester.widget<FloatingActionButton>(
          find.byType(FloatingActionButton),
        );

        // Default elevation should be set (6.0)
        expect(fab.elevation, equals(6.0));
      });
    });

    group('Interaction', () {
      testWidgets('FAB is tappable', (tester) async {
        final timerState = createTimerState(FastingState.fasting);
        await tester.pumpWidget(createTestWidget(timerState));

        final fab = tester.widget<FloatingActionButton>(
          find.byType(FloatingActionButton),
        );

        expect(fab.onPressed, isNotNull);
      });

      testWidgets('tapping FAB triggers action', (tester) async {
        final timerState = createTimerState(FastingState.fasting);
        await tester.pumpWidget(createTestWidget(timerState));

        // Find and tap the FAB
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();

        // If the implementation shows a modal, it should be in the widget tree
        // This is a basic test - we'll test modal content in panic_button_modal_test.dart
      });
    });

    group('Accessibility', () {
      testWidgets('FAB has semantic label', (tester) async {
        final timerState = createTimerState(FastingState.fasting);
        await tester.pumpWidget(createTestWidget(timerState));

        // Check that there's a semantics label or tooltip
        final fab = tester.widget<FloatingActionButton>(
          find.byType(FloatingActionButton),
        );

        expect(fab.tooltip, isNotNull);
      });
    });
  });
}
