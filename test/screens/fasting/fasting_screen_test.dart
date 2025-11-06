import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zendfast_1/models/timer_state.dart';
import 'package:zendfast_1/providers/timer_provider.dart';
import 'package:zendfast_1/providers/auth_computed_providers.dart';
import 'package:zendfast_1/screens/fasting/fasting_screen.dart';

/// Mock TimerNotifier for testing
class MockTimerNotifier extends TimerNotifier {
  final TimerState? mockState;

  MockTimerNotifier(this.mockState) : super() {
    state = mockState;
  }
}

void main() {
  group('FastingScreen Widget Tests', () {
    testWidgets('renders correctly with no active fast', (WidgetTester tester) async {
      // Arrange: Create provider overrides with no active timer
      final container = ProviderContainer(
        overrides: [
          timerProvider.overrideWith((ref) => MockTimerNotifier(null)),
          currentUserIdProvider.overrideWith((ref) => 'test-user-id'),
        ],
      );

      // Act: Build the widget
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: FastingScreen(),
          ),
        ),
      );

      // Assert: Check for expected widgets when no fast is active
      expect(find.text('Fasting'), findsOneWidget);
      expect(find.text('No Active Fast'), findsOneWidget);
      expect(find.text('Ready to start your fasting journey'), findsOneWidget);
      expect(find.text('Start Fast'), findsOneWidget);
      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
    });

    testWidgets('renders correctly with active fast', (WidgetTester tester) async {
      // Arrange: Create provider overrides with active timer
      final activeTimerState = TimerState(
        isRunning: true,
        durationMinutes: 960, // 16 hours
        planType: '16:8',
        startTime: DateTime.now().subtract(const Duration(hours: 1)),
        userId: 'test-user-id',
      );

      final container = ProviderContainer(
        overrides: [
          timerProvider.overrideWith((ref) => MockTimerNotifier(activeTimerState)),
          currentUserIdProvider.overrideWith((ref) => 'test-user-id'),
        ],
      );

      // Act: Build the widget
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: FastingScreen(),
          ),
        ),
      );

      // Assert: Check for expected widgets when fast is active
      expect(find.text('Fasting'), findsOneWidget);
      expect(find.text('Fasting in Progress'), findsOneWidget);
      expect(find.text('View Progress'), findsOneWidget);
      expect(find.byIcon(Icons.timer), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('displays formatted elapsed time correctly', (WidgetTester tester) async {
      // Arrange: Timer with 2 hours 30 minutes elapsed
      final activeTimerState = TimerState(
        isRunning: true,
        durationMinutes: 960, // 16 hours
        planType: '16:8',
        startTime: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
        userId: 'test-user-id',
      );

      final container = ProviderContainer(
        overrides: [
          timerProvider.overrideWith((ref) => MockTimerNotifier(activeTimerState)),
          currentUserIdProvider.overrideWith((ref) => 'test-user-id'),
        ],
      );

      // Act: Build the widget
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: FastingScreen(),
          ),
        ),
      );

      // Assert: Check elapsed time is formatted as HH:MM
      expect(find.text('02:30'), findsOneWidget);
    });

    testWidgets('displays correct progress percentage', (WidgetTester tester) async {
      // Arrange: Timer at 25% progress (4 hours of 16 hour fast)
      final activeTimerState = TimerState(
        isRunning: true,
        durationMinutes: 960, // 16 hours
        planType: '16:8',
        startTime: DateTime.now().subtract(const Duration(hours: 4)),
        userId: 'test-user-id',
      );

      final container = ProviderContainer(
        overrides: [
          timerProvider.overrideWith((ref) => MockTimerNotifier(activeTimerState)),
          currentUserIdProvider.overrideWith((ref) => 'test-user-id'),
        ],
      );

      // Act: Build the widget
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: FastingScreen(),
          ),
        ),
      );

      // Assert: Check progress percentage
      expect(find.text('25% Complete'), findsOneWidget);
    });

    testWidgets('quick actions button shows "Start Fast" when no timer active', (WidgetTester tester) async {
      // Arrange: No active timer
      final container = ProviderContainer(
        overrides: [
          timerProvider.overrideWith((ref) => MockTimerNotifier(null)),
          currentUserIdProvider.overrideWith((ref) => 'test-user-id'),
        ],
      );

      // Act: Build the widget
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: FastingScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Button shows "Start Fast"
      expect(find.text('Start Fast'), findsOneWidget);
    });

    testWidgets('quick actions button shows "View Progress" when timer is active', (WidgetTester tester) async {
      // Arrange: Active timer
      final activeTimerState = TimerState(
        isRunning: true,
        durationMinutes: 960, // 16 hours
        planType: '16:8',
        startTime: DateTime.now().subtract(const Duration(hours: 1)),
        userId: 'test-user-id',
      );

      final container = ProviderContainer(
        overrides: [
          timerProvider.overrideWith((ref) => MockTimerNotifier(activeTimerState)),
          currentUserIdProvider.overrideWith((ref) => 'test-user-id'),
        ],
      );

      // Act: Build the widget
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: FastingScreen(),
          ),
        ),
      );

      // Assert: Button shows "View Progress"
      expect(find.text('View Progress'), findsOneWidget);
    });

    testWidgets('displays fasting plans section', (WidgetTester tester) async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          timerProvider.overrideWith((ref) => MockTimerNotifier(null)),
          currentUserIdProvider.overrideWith((ref) => 'test-user-id'),
        ],
      );

      // Act: Build the widget
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: FastingScreen(),
          ),
        ),
      );

      // Assert: Check for popular fasting plans
      expect(find.text('Popular Fasting Plans'), findsOneWidget);
      expect(find.text('16:8'), findsOneWidget);
      expect(find.text('18:6'), findsOneWidget);
      expect(find.text('OMAD'), findsOneWidget);
      expect(find.text('Fast for 16 hours, eat in 8-hour window'), findsOneWidget);
    });

    testWidgets('displays benefits section', (WidgetTester tester) async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          timerProvider.overrideWith((ref) => MockTimerNotifier(null)),
          currentUserIdProvider.overrideWith((ref) => 'test-user-id'),
        ],
      );

      // Act: Build the widget
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: FastingScreen(),
          ),
        ),
      );

      // Assert: Check for benefits
      expect(find.text('Benefits of Fasting'), findsOneWidget);
      expect(find.text('Improved Metabolism'), findsOneWidget);
      expect(find.text('Mental Clarity'), findsOneWidget);
      expect(find.text('Cellular Repair'), findsOneWidget);
    });
  });
}
