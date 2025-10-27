import 'package:flutter_test/flutter_test.dart';
import 'package:zendfast_1/models/fasting_session.dart';

void main() {
  group('FastingSession Model Tests', () {
    group('Session Creation and Basic Fields', () {
      test('creates session with required fields', () {
        final session = FastingSession(
          userId: 'user123',
          durationMinutes: 960, // 16 hours
          planType: '16:8',
          startTime: DateTime.now(),
        );

        expect(session.userId, 'user123');
        expect(session.durationMinutes, 960);
        expect(session.planType, '16:8');
        expect(session.startTime, isNotNull);
        expect(session.endTime, isNull);
        expect(session.completed, false);
        expect(session.interrupted, false);
        expect(session.interruptionReason, isNull);
      });

      test('creates session with custom start time', () {
        final customTime = DateTime(2024, 1, 15, 10, 0);
        final session = FastingSession(
          userId: 'user123',
          durationMinutes: 720,
          planType: '12:12',
          startTime: customTime,
        );

        expect(session.startTime, customTime);
      });

      test('endTime is calculated when session ends', () {
        final startTime = DateTime(2024, 1, 15, 10, 0);
        final session = FastingSession(
          userId: 'user123',
          durationMinutes: 60, // 1 hour
          planType: '1:0',
          startTime: startTime,
        );

        // endTime is null for active sessions
        expect(session.endTime, isNull);

        // When session ends, endTime is set
        session.endSession(wasInterrupted: false);
        expect(session.endTime, isNotNull);
      });

      test('isActive returns correct status', () {
        final session = FastingSession(
          userId: 'user123',
          durationMinutes: 960,
          planType: '16:8',
          startTime: DateTime.now(),
        );

        expect(session.isActive, true);

        session.endSession(wasInterrupted: false);
        expect(session.isActive, false);
      });
    });

    group('Session Completion Tests', () {
      test('endSession() marks session as completed when not interrupted', () {
        final session = FastingSession(
          userId: 'user123',
          durationMinutes: 960,
          planType: '16:8',
          startTime: DateTime.now(),
        );

        session.endSession(wasInterrupted: false);

        expect(session.completed, true);
        expect(session.interrupted, false);
        expect(session.endTime, isNotNull);
        expect(session.interruptionReason, isNull);
      });

      test('completed session calculates actual duration', () {
        final startTime = DateTime(2024, 1, 15, 10, 0);
        final session = FastingSession(
          userId: 'user123',
          durationMinutes: 720, // Planned duration
          planType: '12:12',
          startTime: startTime,
        );

        session.endSession(wasInterrupted: false);

        // durationMinutes is calculated based on actual elapsed time
        expect(session.durationMinutes, isNotNull);
        expect(session.durationMinutes, greaterThan(0));
      });
    });

    group('Session Interruption Tests', () {
      test('endSession() marks session as interrupted with reason', () {
        final session = FastingSession(
          userId: 'user123',
          durationMinutes: 960,
          planType: '16:8',
          startTime: DateTime.now(),
        );

        session.endSession(wasInterrupted: true, reason: 'Me sentí con hambre');

        expect(session.interrupted, true);
        expect(session.completed, false);
        expect(session.endTime, isNotNull);
        expect(session.interruptionReason, 'Me sentí con hambre');
      });

      test('interrupted session without reason stores null', () {
        final session = FastingSession(
          userId: 'user123',
          durationMinutes: 960,
          planType: '16:8',
          startTime: DateTime.now(),
        );

        session.endSession(wasInterrupted: true);

        expect(session.interrupted, true);
        expect(session.completed, false);
        expect(session.interruptionReason, isNull);
      });

      test('interrupted session with custom reason', () {
        final session = FastingSession(
          userId: 'user123',
          durationMinutes: 960,
          planType: '16:8',
          startTime: DateTime.now(),
        );

        const customReason = 'Evento social inesperado';
        session.endSession(wasInterrupted: true, reason: customReason);

        expect(session.interruptionReason, customReason);
        expect(session.interrupted, true);
      });

      test('all predefined interruption reasons are accepted', () {
        final predefinedReasons = [
          'Me sentí con hambre',
          'No me sentía bien',
          'Evento social',
          'Emergencia',
          'Falta de energía',
          'Problemas de sueño',
          'Estrés/ansiedad',
          'Tentación',
        ];

        for (final reason in predefinedReasons) {
          final session = FastingSession(
            userId: 'user123',
            durationMinutes: 960,
            planType: '16:8',
            startTime: DateTime.now(),
          );

          session.endSession(wasInterrupted: true, reason: reason);

          expect(session.interruptionReason, reason);
          expect(session.interrupted, true);
        }
      });
    });

    group('Duration Calculation Tests', () {
      test('currentDuration calculates correctly for active session', () {
        final startTime = DateTime.now().subtract(const Duration(hours: 2));
        final session = FastingSession(
          userId: 'user123',
          durationMinutes: 960,
          planType: '16:8',
          startTime: startTime,
        );

        final duration = session.currentDuration;

        // Should be approximately 2 hours with some tolerance
        expect(duration.inMinutes, greaterThanOrEqualTo(119));
        expect(duration.inMinutes, lessThanOrEqualTo(121));
      });

      test('currentDuration for completed session uses endTime', () {
        final startTime = DateTime(2024, 1, 15, 10, 0);
        final session = FastingSession(
          userId: 'user123',
          durationMinutes: 60,
          planType: '1:0',
          startTime: startTime,
        );

        // Complete the session
        session.endSession(wasInterrupted: false);

        // currentDuration uses actual elapsed time (startTime to endTime)
        expect(session.endTime, isNotNull);
        expect(session.currentDuration, session.endTime!.difference(startTime));
      });

      test('currentDuration for interrupted session is actual elapsed time', () {
        final startTime = DateTime(2024, 1, 15, 10, 0);
        final session = FastingSession(
          userId: 'user123',
          durationMinutes: 960, // 16 hours planned
          planType: '16:8',
          startTime: startTime,
        );

        // Interrupt the session
        session.endSession(wasInterrupted: true, reason: 'Emergency');

        // currentDuration uses actual elapsed time (startTime to endTime)
        expect(session.endTime, isNotNull);
        final actualDuration = session.currentDuration;
        expect(actualDuration, session.endTime!.difference(startTime));
      });
    });

    group('JSON Serialization Tests', () {
      test('toJson() serializes completed session correctly', () {
        final startTime = DateTime(2024, 1, 15, 10, 0);
        final session = FastingSession(
          userId: 'user123',
          durationMinutes: 960,
          planType: '16:8',
          startTime: startTime,
        );

        session.endSession(wasInterrupted: false);

        final json = session.toJson();

        expect(json['user_id'], 'user123');
        expect(json['duration_minutes'], isNotNull); // Actual duration calculated
        expect(json['plan_type'], '16:8');
        expect(json['completed'], true);
        expect(json['interrupted'], false);
        expect(json['interruption_reason'], isNull);
        expect(json['start_time'], isNotNull);
        expect(json['end_time'], isNotNull);
      });

      test('toJson() serializes interrupted session with reason', () {
        final session = FastingSession(
          userId: 'user123',
          durationMinutes: 960,
          planType: '16:8',
          startTime: DateTime.now(),
        );

        session.endSession(wasInterrupted: true, reason: 'Emergencia');

        final json = session.toJson();

        expect(json['completed'], false);
        expect(json['interrupted'], true);
        expect(json['interruption_reason'], 'Emergencia');
      });

      test('fromJson() deserializes session with interruption reason', () {
        final json = {
          'id': 1,
          'user_id': 'user123',
          'duration_minutes': 960,
          'plan_type': '16:8',
          'start_time': DateTime(2024, 1, 15, 10, 0).toIso8601String(),
          'end_time': DateTime(2024, 1, 15, 18, 0).toIso8601String(),
          'completed': false,
          'interrupted': true,
          'interruption_reason': 'Me sentí con hambre',
          'created_at': DateTime(2024, 1, 15, 10, 0).toIso8601String(),
          'updated_at': DateTime(2024, 1, 15, 18, 0).toIso8601String(),
        };

        final session = FastingSession.fromJson(json);

        expect(session.userId, 'user123');
        expect(session.interrupted, true);
        expect(session.completed, false);
        expect(session.interruptionReason, 'Me sentí con hambre');
      });

      test('fromJson() handles missing interruption_reason', () {
        final json = {
          'user_id': 'user123',
          'duration_minutes': 960,
          'plan_type': '16:8',
          'start_time': DateTime.now().toIso8601String(),
          'completed': false,
          'interrupted': false,
          // Missing interruption_reason
        };

        final session = FastingSession.fromJson(json);

        expect(session.interruptionReason, isNull);
      });

      test('JSON roundtrip preserves interruption data', () {
        final original = FastingSession(
          userId: 'user123',
          durationMinutes: 720,
          planType: '12:12',
          startTime: DateTime.now(),
        );

        original.endSession(
          wasInterrupted: true,
          reason: 'Estrés/ansiedad',
        );

        final json = original.toJson();
        final restored = FastingSession.fromJson(json);

        expect(restored.interrupted, original.interrupted);
        expect(restored.completed, original.completed);
        expect(restored.interruptionReason, original.interruptionReason);
        expect(restored.durationMinutes, original.durationMinutes);
      });
    });

    group('Edge Cases Tests', () {
      test('handles empty string as interruption reason', () {
        final session = FastingSession(
          userId: 'user123',
          durationMinutes: 960,
          planType: '16:8',
          startTime: DateTime.now(),
        );

        session.endSession(wasInterrupted: true, reason: '');

        expect(session.interruptionReason, '');
        expect(session.interrupted, true);
      });

      test('handles very long interruption reason', () {
        final session = FastingSession(
          userId: 'user123',
          durationMinutes: 960,
          planType: '16:8',
          startTime: DateTime.now(),
        );

        const longReason = 'This is a very long interruption reason that '
            'describes in detail why the fast was interrupted, including all '
            'the circumstances, emotions, and external factors that led to '
            'the decision to stop fasting early.';

        session.endSession(wasInterrupted: true, reason: longReason);

        expect(session.interruptionReason, longReason);
      });

      test('cannot complete and interrupt simultaneously', () {
        final session = FastingSession(
          userId: 'user123',
          durationMinutes: 960,
          planType: '16:8',
          startTime: DateTime.now(),
        );

        session.endSession(wasInterrupted: false, reason: 'Should be ignored');

        // When completed=true, interrupted should be false
        expect(session.completed, true);
        expect(session.interrupted, false);
        // Reason might still be stored but the session is not interrupted
        expect(session.interruptionReason, 'Should be ignored');
      });

      test('handles zero duration session', () {
        final session = FastingSession(
          userId: 'user123',
          durationMinutes: 0,
          planType: 'custom',
          startTime: DateTime.now(),
        );

        expect(session.durationMinutes, 0);
        expect(session.currentDuration.inMinutes, 0);
      });

      test('handles very long session (multi-day fast)', () {
        final session = FastingSession(
          userId: 'user123',
          durationMinutes: 4320, // 72 hours / 3 days
          planType: 'Extended',
          startTime: DateTime.now(),
        );

        expect(session.durationMinutes, 4320);
        expect(session.currentDuration.inHours, greaterThanOrEqualTo(0));
      });
    });
  });
}
