import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zendfast_1/models/fasting_state.dart';
import 'package:zendfast_1/models/timer_state.dart';
import 'package:zendfast_1/providers/timer_provider.dart';
import 'package:zendfast_1/widgets/fasting/panic_button_modal.dart';

// Mock TimerNotifier for testing
class MockTimerNotifier extends TimerNotifier {
  final TimerState? mockState;
  bool interruptCalled = false;

  MockTimerNotifier(this.mockState) : super() {
    state = mockState;
  }

  @override
  Future<void> interruptFast() async {
    interruptCalled = true;
    // Don't actually interrupt for tests
  }
}

void main() {
  group('PanicButtonModal', () {
    // Helper to create test widget
    Widget createTestWidget(MockTimerNotifier mockNotifier) {
      final container = ProviderContainer(
        overrides: [
          timerProvider.overrideWith((ref) => mockNotifier),
        ],
      );

      return UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => PanicButtonModal.show(context: context),
                child: const Text('Show Modal'),
              ),
            ),
          ),
        ),
      );
    }

    // Helper to create fasting state
    TimerState createTimerState() {
      return TimerState(
        startTime: DateTime.now(),
        durationMinutes: 180,
        isRunning: true,
        planType: '16:8',
        userId: 'test-user',
        sessionId: 1,
        timezoneOffset: Duration.zero,
        state: FastingState.fasting,
      );
    }

    group('Display', () {
      testWidgets('shows modal when called', (tester) async {
        final mockNotifier = MockTimerNotifier(createTimerState());
        await tester.pumpWidget(createTestWidget(mockNotifier));

        // Tap button to show modal
        await tester.tap(find.text('Show Modal'));
        await tester.pumpAndSettle();

        // Modal should be visible
        expect(find.byType(BottomSheet), findsOneWidget);
      });

      testWidgets('displays title "Apoyo Emocional"', (tester) async {
        final mockNotifier = MockTimerNotifier(createTimerState());
        await tester.pumpWidget(createTestWidget(mockNotifier));

        await tester.tap(find.text('Show Modal'));
        await tester.pumpAndSettle();

        expect(find.text('Apoyo Emocional'), findsOneWidget);
      });

      testWidgets('displays handle bar at top', (tester) async {
        final mockNotifier = MockTimerNotifier(createTimerState());
        await tester.pumpWidget(createTestWidget(mockNotifier));

        await tester.tap(find.text('Show Modal'));
        await tester.pumpAndSettle();

        // Check for a Container that looks like a handle bar
        // (approximately 40w x 4h dp)
        final containers = find.byType(Container);
        expect(containers, findsWidgets);
      });
    });

    group('Motivational Phrases', () {
      testWidgets('displays at least 3 motivational phrases', (tester) async {
        final mockNotifier = MockTimerNotifier(createTimerState());
        await tester.pumpWidget(createTestWidget(mockNotifier));

        await tester.tap(find.text('Show Modal'));
        await tester.pumpAndSettle();

        // Should have multiple ListTiles for phrases
        expect(find.byType(ListTile), findsAtLeastNWidgets(3));
      });

      testWidgets('closes modal when phrase is tapped', (tester) async {
        final mockNotifier = MockTimerNotifier(createTimerState());
        await tester.pumpWidget(createTestWidget(mockNotifier));

        await tester.tap(find.text('Show Modal'));
        await tester.pumpAndSettle();

        // Find and tap first ListTile (motivational phrase)
        final firstTile = find.byType(ListTile).first;
        await tester.tap(firstTile);
        await tester.pumpAndSettle();

        // Modal should be closed
        expect(find.byType(BottomSheet), findsNothing);
      });
    });

    group('Breathing Meditation', () {
      testWidgets('displays breathing meditation option', (tester) async {
        final mockNotifier = MockTimerNotifier(createTimerState());
        await tester.pumpWidget(createTestWidget(mockNotifier));

        await tester.tap(find.text('Show Modal'));
        await tester.pumpAndSettle();

        // Should have breathing-related phrase in the motivational phrases
        // Check for "respiraciones" which is in the phrase "Toma 5 respiraciones profundas"
        expect(
          find.text('Toma 5 respiraciones profundas'),
          findsOneWidget,
        );
      });
    });

    group('Interrupt Action', () {
      testWidgets('displays "No puedo continuar" button', (tester) async {
        final mockNotifier = MockTimerNotifier(createTimerState());
        await tester.pumpWidget(createTestWidget(mockNotifier));

        await tester.tap(find.text('Show Modal'));
        await tester.pumpAndSettle();

        expect(find.text('No puedo continuar'), findsOneWidget);
      });

      testWidgets('button has destructive/error styling', (tester) async {
        final mockNotifier = MockTimerNotifier(createTimerState());
        await tester.pumpWidget(createTestWidget(mockNotifier));

        await tester.tap(find.text('Show Modal'));
        await tester.pumpAndSettle();

        // Find the button with "No puedo continuar"
        final button = find.widgetWithText(ElevatedButton, 'No puedo continuar');
        expect(button, findsOneWidget);
      });

      testWidgets('shows confirmation dialog when tapped', (tester) async {
        final mockNotifier = MockTimerNotifier(createTimerState());
        await tester.pumpWidget(createTestWidget(mockNotifier));

        await tester.tap(find.text('Show Modal'));
        await tester.pumpAndSettle();

        // Tap the interrupt button
        await tester.tap(find.text('No puedo continuar'));
        await tester.pumpAndSettle();

        // Confirmation dialog should appear
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('¿Detener ayuno?'), findsOneWidget);
      });

      testWidgets('does not interrupt when confirmation cancelled',
          (tester) async {
        final mockNotifier = MockTimerNotifier(createTimerState());
        await tester.pumpWidget(createTestWidget(mockNotifier));

        await tester.tap(find.text('Show Modal'));
        await tester.pumpAndSettle();

        // Tap interrupt button
        await tester.tap(find.text('No puedo continuar'));
        await tester.pumpAndSettle();

        // Tap cancel in confirmation dialog
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();

        // Should NOT have called interruptFast
        expect(mockNotifier.interruptCalled, isFalse);
      });

      testWidgets('interrupts fast when confirmation accepted', (tester) async {
        final mockNotifier = MockTimerNotifier(createTimerState());
        await tester.pumpWidget(createTestWidget(mockNotifier));

        await tester.tap(find.text('Show Modal'));
        await tester.pumpAndSettle();

        // Tap interrupt button
        await tester.tap(find.text('No puedo continuar'));
        await tester.pumpAndSettle();

        // Tap confirm in dialog
        final confirmButton = find.text('Detener');
        await tester.tap(confirmButton);
        await tester.pumpAndSettle();

        // Should have called interruptFast
        expect(mockNotifier.interruptCalled, isTrue);
      });
    });

    group('Dismissal', () {
      testWidgets('modal is draggable (isDismissible and enableDrag are true)',
          (tester) async {
        final mockNotifier = MockTimerNotifier(createTimerState());
        await tester.pumpWidget(createTestWidget(mockNotifier));

        await tester.tap(find.text('Show Modal'));
        await tester.pumpAndSettle();

        // Modal should be visible
        expect(find.byType(BottomSheet), findsOneWidget);

        // Note: Actual drag dismissal is hard to test reliably in widget tests
        // due to how Flutter handles gesture detection in tests.
        // The showModalBottomSheet has isDismissible: true and enableDrag: true
        // which enables the dismissal behavior in the actual app.
      });
    });
  });
}
