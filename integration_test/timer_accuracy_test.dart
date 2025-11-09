/// Integration test for timer accuracy performance
///
/// Tests that the fasting timer maintains accuracy within acceptable thresholds:
/// - ±5 seconds per hour of operation
/// - CI runs abbreviated 1-hour test
/// - Manual validation requires full 16-hour test
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';

import 'package:zendfast_1/models/timer_state.dart';
import 'package:zendfast_1/models/fasting_state.dart';
import '../test/performance/metrics_collector.dart';
import '../test/performance/timeline_profiler.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Timer Accuracy Performance Tests', () {
    late MetricsCollector collector;

    setUp(() {
      collector = MetricsCollector();
    });

    testWidgets('Timer accuracy over 1 minute (quick validation)', (tester) async {
      // Quick 1-minute test for fast validation
      const testDuration = Duration(minutes: 1);
      const expectedDriftTolerance = Duration(milliseconds: 100);

      final stopwatch = StopwatchMetric('timer_1min_accuracy');

      // Create a timer state
      final startTime = DateTime.now();
      final timerState = TimerState(
        startTime: startTime,
        durationMinutes: 60, // 1 hour timer
        isRunning: true,
        planType: '16:8',
        userId: 'test_user',
        timezoneOffset: startTime.timeZoneOffset,
        state: FastingState.fasting,
      );

      debugPrint('Timer started at: $startTime');
      stopwatch.start();

      // Wait for the test duration
      await Future.delayed(testDuration);

      stopwatch.stop();
      final actualElapsed = stopwatch.elapsed;

      // Check timer's reported elapsed time
      final timerElapsed = Duration(milliseconds: timerState.elapsedMilliseconds);

      debugPrint('Actual elapsed: ${actualElapsed.inMilliseconds}ms');
      debugPrint('Timer reported: ${timerElapsed.inMilliseconds}ms');

      final drift = (actualElapsed.inMilliseconds - timerElapsed.inMilliseconds).abs();
      debugPrint('Drift: ${drift}ms');

      collector.recordTiming('timer_drift_1min', Duration(milliseconds: drift));

      // Assert drift is within tolerance
      expect(
        drift,
        lessThan(expectedDriftTolerance.inMilliseconds),
        reason: 'Timer drift of ${drift}ms exceeds tolerance ${expectedDriftTolerance.inMilliseconds}ms',
      );
    });

    testWidgets('Timer accuracy over 5 minutes with periodic sampling', (tester) async {
      // 5-minute test with sampling every 30 seconds
      const testDuration = Duration(minutes: 5);
      const samplingInterval = Duration(seconds: 30);
      const maxDriftPerSample = Duration(milliseconds: 500);

      final startTime = DateTime.now();
      final timerState = TimerState(
        startTime: startTime,
        durationMinutes: 60,
        isRunning: true,
        planType: '16:8',
        userId: 'test_user',
        timezoneOffset: startTime.timeZoneOffset,
        state: FastingState.fasting,
      );

      debugPrint('Starting 5-minute accuracy test with 30s sampling');

      final wallClockStopwatch = Stopwatch()..start();
      final samples = <Map<String, dynamic>>[];

      // Sample periodically
      final endTime = DateTime.now().add(testDuration);
      while (DateTime.now().isBefore(endTime)) {
        await Future.delayed(samplingInterval);

        final actualElapsed = wallClockStopwatch.elapsed;
        final timerElapsed = Duration(milliseconds: timerState.elapsedMilliseconds);
        final drift = (actualElapsed.inMilliseconds - timerElapsed.inMilliseconds).abs();

        final sample = {
          'timestamp': DateTime.now().toIso8601String(),
          'actual_elapsed_ms': actualElapsed.inMilliseconds,
          'timer_elapsed_ms': timerElapsed.inMilliseconds,
          'drift_ms': drift,
        };

        samples.add(sample);
        debugPrint('Sample ${samples.length}: drift = ${drift}ms');

        collector.recordTiming('timer_drift_sample_${samples.length}', Duration(milliseconds: drift));

        // Check drift is within tolerance for this sample
        expect(
          drift,
          lessThan(maxDriftPerSample.inMilliseconds),
          reason: 'Timer drift ${drift}ms exceeds max ${maxDriftPerSample.inMilliseconds}ms at sample ${samples.length}',
        );
      }

      debugPrint('Collected ${samples.length} accuracy samples');
      debugPrint('Samples: $samples');
    });

    testWidgets('Timer maintains accuracy through app lifecycle', (tester) async {
      // Test that timer accuracy is maintained when widget rebuilds occur
      const testDuration = Duration(minutes: 2);
      const rebuildInterval = Duration(seconds: 15);

      final startTime = DateTime.now();
      final timerState = TimerState(
        startTime: startTime,
        durationMinutes: 60,
        isRunning: true,
        planType: '16:8',
        userId: 'test_user',
        timezoneOffset: startTime.timeZoneOffset,
        state: FastingState.fasting,
      );

      final wallClockStopwatch = Stopwatch()..start();
      int rebuildCount = 0;

      // Rebuild widgets periodically while timer runs
      final endTime = DateTime.now().add(testDuration);
      while (DateTime.now().isBefore(endTime)) {
        // Trigger widget rebuild
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Elapsed: ${timerState.elapsedMilliseconds}ms'),
              ),
            ),
          ),
        );
        await tester.pump();

        rebuildCount++;
        await Future.delayed(rebuildInterval);
      }

      wallClockStopwatch.stop();

      final actualElapsed = wallClockStopwatch.elapsed;
      final timerElapsed = Duration(milliseconds: timerState.elapsedMilliseconds);
      final drift = (actualElapsed.inMilliseconds - timerElapsed.inMilliseconds).abs();

      debugPrint('After $rebuildCount rebuilds:');
      debugPrint('  Actual: ${actualElapsed.inMilliseconds}ms');
      debugPrint('  Timer:  ${timerElapsed.inMilliseconds}ms');
      debugPrint('  Drift:  ${drift}ms');

      collector.recordTiming('timer_drift_with_rebuilds', Duration(milliseconds: drift));

      // Drift should still be minimal despite rebuilds
      expect(
        drift,
        lessThan(1000), // 1 second tolerance after 2 minutes with rebuilds
        reason: 'Timer drift ${drift}ms too high after $rebuildCount rebuilds',
      );
    });

    testWidgets('Timer calculation methods are consistent', (tester) async {
      final startTime = DateTime.now();
      final timerState = TimerState(
        startTime: startTime,
        durationMinutes: 60, // 1 hour = 3,600,000 ms
        isRunning: true,
        planType: '16:8',
        userId: 'test_user',
        timezoneOffset: startTime.timeZoneOffset,
        state: FastingState.fasting,
      );

      // Let some time pass
      await Future.delayed(const Duration(seconds: 5));

      final elapsed = timerState.elapsedMilliseconds;
      final remaining = timerState.remainingMilliseconds;
      final total = 60 * 60 * 1000; // 1 hour in ms

      debugPrint('Elapsed: ${elapsed}ms');
      debugPrint('Remaining: ${remaining}ms');
      debugPrint('Total: ${total}ms');
      debugPrint('Sum: ${elapsed + remaining}ms');

      // Elapsed + Remaining should approximately equal total duration
      final sum = elapsed + remaining;
      final difference = (sum - total).abs();

      debugPrint('Difference from total: ${difference}ms');

      // Allow small margin for calculation timing
      expect(
        difference,
        lessThan(100), // Should be very close
        reason: 'Timer calculation inconsistency: ${difference}ms',
      );
    });

    testWidgets('ABBREVIATED: 1-hour timer accuracy test for CI', (tester) async {
      // This is the main CI test - runs for a shorter duration
      // For full 16-hour test, see manual validation documentation

      const testDuration = Duration(minutes: 10); // Abbreviated to 10 minutes for CI
      const samplingInterval = Duration(minutes: 1);
      const maxDriftPer10Min = Duration(seconds: 1); // Scaled from ±5s/hour

      debugPrint('=== STARTING ABBREVIATED TIMER ACCURACY TEST ===');
      debugPrint('Duration: ${testDuration.inMinutes} minutes');
      debugPrint('Sampling: every ${samplingInterval.inMinutes} minute(s)');
      debugPrint('Max drift: ${maxDriftPer10Min.inSeconds}s');

      final startTime = DateTime.now();
      final timerState = TimerState(
        startTime: startTime,
        durationMinutes: testDuration.inMinutes,
        isRunning: true,
        planType: '16:8',
        userId: 'test_user',
        timezoneOffset: startTime.timeZoneOffset,
        state: FastingState.fasting,
      );

      final wallClockStopwatch = Stopwatch()..start();
      final samples = <Map<String, dynamic>>[];
      int maxDrift = 0;

      TimelineProfiler.startEvent('timer_accuracy_1hour_test');

      // Run test with periodic sampling
      final endTime = DateTime.now().add(testDuration);
      while (DateTime.now().isBefore(endTime)) {
        await Future.delayed(samplingInterval);

        final actualElapsed = wallClockStopwatch.elapsed;
        final timerElapsed = Duration(milliseconds: timerState.elapsedMilliseconds);
        final drift = (actualElapsed.inMilliseconds - timerElapsed.inMilliseconds).abs();

        if (drift > maxDrift) {
          maxDrift = drift;
        }

        final sample = {
          'sample_number': samples.length + 1,
          'timestamp': DateTime.now().toIso8601String(),
          'actual_elapsed_ms': actualElapsed.inMilliseconds,
          'timer_elapsed_ms': timerElapsed.inMilliseconds,
          'drift_ms': drift,
          'drift_seconds': (drift / 1000.0).toStringAsFixed(2),
        };

        samples.add(sample);

        debugPrint('--- Sample ${samples.length} ---');
        debugPrint('  Actual: ${(actualElapsed.inSeconds / 60.0).toStringAsFixed(2)} min');
        debugPrint('  Timer:  ${(timerElapsed.inSeconds / 60.0).toStringAsFixed(2)} min');
        debugPrint('  Drift:  ${(drift / 1000.0).toStringAsFixed(2)}s');

        collector.recordTiming('accuracy_sample_${samples.length}', Duration(milliseconds: drift));
      }

      wallClockStopwatch.stop();
      TimelineProfiler.finishEvent('timer_accuracy_1hour_test');

      // Final check
      final finalActualElapsed = wallClockStopwatch.elapsed;
      final finalTimerElapsed = Duration(milliseconds: timerState.elapsedMilliseconds);
      final finalDrift = (finalActualElapsed.inMilliseconds - finalTimerElapsed.inMilliseconds).abs();

      debugPrint('');
      debugPrint('=== TIMER ACCURACY TEST RESULTS ===');
      debugPrint('Test duration: ${finalActualElapsed.inMinutes} minutes');
      debugPrint('Final drift: ${(finalDrift / 1000.0).toStringAsFixed(2)}s');
      debugPrint('Max drift: ${(maxDrift / 1000.0).toStringAsFixed(2)}s');
      debugPrint('Samples collected: ${samples.length}');
      debugPrint('Threshold: ${maxDriftPer10Min.inSeconds}s');
      debugPrint('Status: ${finalDrift < maxDriftPer10Min.inMilliseconds ? 'PASS ✓' : 'FAIL ✗'}');
      debugPrint('===================================');

      // Export detailed report
      final report = {
        'test_type': 'abbreviated_1hour',
        'duration_minutes': testDuration.inMinutes,
        'final_drift_ms': finalDrift,
        'final_drift_seconds': (finalDrift / 1000.0),
        'max_drift_ms': maxDrift,
        'max_drift_seconds': (maxDrift / 1000.0),
        'threshold_ms': maxDriftPer10Min.inMilliseconds,
        'threshold_seconds': maxDriftPer10Min.inSeconds,
        'passed': finalDrift < maxDriftPer10Min.inMilliseconds,
        'samples': samples,
        'metrics': collector.toJson(),
      };

      debugPrint('Full report: $report');

      // Assert accuracy is within threshold
      expect(
        finalDrift,
        lessThan(maxDriftPer10Min.inMilliseconds),
        reason: 'Timer drift of ${(finalDrift / 1000.0).toStringAsFixed(2)}s exceeds '
            'threshold ${maxDriftPer10Min.inSeconds}s for ${testDuration.inMinutes}-minute test',
      );
    });
  });

  group('Timer Accuracy Edge Cases', () {
    testWidgets('Timer handles timezone offset correctly', (tester) async {
      final now = DateTime.now();
      final timerState = TimerState(
        startTime: now,
        durationMinutes: 60,
        isRunning: true,
        planType: '16:8',
        userId: 'test_user',
        timezoneOffset: now.timeZoneOffset,
        state: FastingState.fasting,
      );

      // Verify timezone is captured
      expect(timerState.timezoneOffset, equals(now.timeZoneOffset));
      expect(timerState.hasTimezoneChanged(), isFalse);

      debugPrint('Timezone offset: ${timerState.timezoneOffset}');
      debugPrint('Timezone changed: ${timerState.hasTimezoneChanged()}');
    });

    testWidgets('Timer handles completion correctly', (tester) async {
      // Create a timer that should complete almost immediately
      final startTime = DateTime.now().subtract(const Duration(minutes: 61));
      final timerState = TimerState(
        startTime: startTime,
        durationMinutes: 60,
        isRunning: true,
        planType: '16:8',
        userId: 'test_user',
        timezoneOffset: startTime.timeZoneOffset,
        state: FastingState.fasting,
      );

      // Timer should be completed
      expect(timerState.isCompleted, isTrue);
      expect(timerState.remainingMilliseconds, equals(0));

      debugPrint('Timer completed: ${timerState.isCompleted}');
      debugPrint('Remaining: ${timerState.remainingMilliseconds}ms');
    });
  });
}
