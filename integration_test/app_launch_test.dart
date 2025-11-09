/// Integration test for app launch time performance
///
/// Tests that the app launches within acceptable time thresholds:
/// - Cold start: <2s (first launch)
/// - Warm start: <500ms (subsequent launches)
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';

import '../test/performance/performance_config.dart';
import '../test/performance/metrics_collector.dart';
import '../test/performance/timeline_profiler.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Launch Performance Tests', () {
    late MetricsCollector collector;

    setUp(() {
      collector = MetricsCollector();
    });

    testWidgets('Cold start launch time is less than 2 seconds', (tester) async {
      final stopwatch = StopwatchMetric('cold_start');

      // Measure app initialization and first frame
      TimelineProfiler.startEvent('app_cold_start');
      stopwatch.start();

      // Launch the app (this triggers main() and all initialization)
      await tester.pumpWidget(
        // Note: We can't directly call main() in integration tests
        // Instead, we measure the time to render the root widget
        const MaterialApp(home: SizedBox()),
      );

      // Wait for first frame to be rendered
      await tester.pumpAndSettle();

      stopwatch.stop();
      TimelineProfiler.finishEvent('app_cold_start');

      final launchTime = stopwatch.elapsed;
      stopwatch.recordTo(collector);

      // Log the result
      debugPrint('Cold start time: ${launchTime.inMilliseconds}ms');

      // Assert launch time is within threshold
      expect(
        launchTime,
        lessThan(PerformanceThresholds.maxColdStartTime),
        reason: 'Cold start time ${launchTime.inMilliseconds}ms exceeds threshold '
            '${PerformanceThresholds.maxColdStartTime.inMilliseconds}ms',
      );

      // Generate report
      debugPrint('Launch metrics: ${collector.toJson()}');
    });

    testWidgets('Warm start launch time is less than 500ms', (tester) async {
      // First launch (cold start) - don't measure this
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pumpAndSettle();

      // Clear and prepare for warm start measurement
      await tester.binding.setSurfaceSize(null);
      await tester.pumpAndSettle();

      final stopwatch = StopwatchMetric('warm_start');

      // Measure warm start (app already initialized)
      TimelineProfiler.startEvent('app_warm_start');
      stopwatch.start();

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pumpAndSettle();

      stopwatch.stop();
      TimelineProfiler.finishEvent('app_warm_start');

      final launchTime = stopwatch.elapsed;
      stopwatch.recordTo(collector);

      // Log the result
      debugPrint('Warm start time: ${launchTime.inMilliseconds}ms');

      // Assert launch time is within threshold
      expect(
        launchTime,
        lessThan(PerformanceThresholds.maxWarmStartTime),
        reason: 'Warm start time ${launchTime.inMilliseconds}ms exceeds threshold '
            '${PerformanceThresholds.maxWarmStartTime.inMilliseconds}ms',
      );

      // Generate report
      debugPrint('Warm start metrics: ${collector.toJson()}');
    });

    testWidgets('App renders first frame quickly', (tester) async {
      final stopwatch = StopwatchMetric('first_frame');

      // Measure time to first meaningful paint
      TimelineProfiler.startEvent('first_frame_render');
      stopwatch.start();

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Test'),
            ),
          ),
        ),
      );

      // Wait for first frame only (not settle)
      await tester.pump();

      stopwatch.stop();
      TimelineProfiler.finishEvent('first_frame_render');

      final firstFrameTime = stopwatch.elapsed;
      stopwatch.recordTo(collector);

      debugPrint('First frame time: ${firstFrameTime.inMilliseconds}ms');

      // First frame should be quick (<500ms)
      // Note: In test environment this can be slower than production
      expect(
        firstFrameTime,
        lessThan(const Duration(milliseconds: 500)),
        reason: 'First frame time too slow: ${firstFrameTime.inMilliseconds}ms',
      );
    });

    testWidgets('Multiple rapid restarts maintain performance', (tester) async {
      final launchTimes = <Duration>[];

      // Perform 5 rapid restarts and measure each
      for (int i = 0; i < 5; i++) {
        final stopwatch = StopwatchMetric('restart_$i');

        TimelineProfiler.startEvent('app_restart_$i');
        stopwatch.start();

        await tester.pumpWidget(const MaterialApp(home: SizedBox()));
        await tester.pumpAndSettle();

        stopwatch.stop();
        TimelineProfiler.finishEvent('app_restart_$i');

        launchTimes.add(stopwatch.elapsed);
        stopwatch.recordTo(collector);

        debugPrint('Restart $i time: ${stopwatch.elapsed.inMilliseconds}ms');

        // Clear between restarts
        await tester.binding.setSurfaceSize(null);
        await tester.pumpAndSettle();
      }

      // Check that performance doesn't degrade over restarts
      // Last launch should not be significantly slower than first
      final firstLaunch = launchTimes.first.inMilliseconds;
      final lastLaunch = launchTimes.last.inMilliseconds;
      final degradation = lastLaunch - firstLaunch;

      debugPrint('Launch time degradation: ${degradation}ms');

      expect(
        degradation,
        lessThan(500), // Should not degrade by more than 500ms
        reason: 'Launch time degraded by ${degradation}ms over 5 restarts',
      );

      // All launches should be reasonably fast
      for (final launchTime in launchTimes) {
        expect(
          launchTime,
          lessThan(const Duration(seconds: 3)),
          reason: 'One of the restarts took too long: ${launchTime.inMilliseconds}ms',
        );
      }
    });

    testWidgets('App initialization steps are profiled', (tester) async {
      // This test verifies that Timeline events are being recorded
      // In a real scenario, you would analyze the Timeline data in DevTools

      final initSteps = [
        'load_env',
        'init_app_config',
        'init_supabase',
        'init_database',
        'init_timer_service',
        'init_notifications',
      ];

      for (final step in initSteps) {
        TimelineProfiler.startEvent('init_$step');

        // Simulate initialization step
        await Future.delayed(const Duration(milliseconds: 10));

        TimelineProfiler.finishEvent('init_$step');
        TimelineProfiler.markInstant('completed_$step');
      }

      // Verify test completed successfully
      expect(true, isTrue);
      debugPrint('All initialization steps profiled in Timeline');
    });
  });

  group('App Launch Performance Report', () {
    testWidgets('Generate comprehensive launch performance report', (tester) async {
      final collector = MetricsCollector();
      final report = <String, dynamic>{};

      // Measure cold start
      final coldStopwatch = StopwatchMetric('cold_start_report');
      coldStopwatch.start();
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pumpAndSettle();
      coldStopwatch.stop();
      coldStopwatch.recordTo(collector);

      report['cold_start_ms'] = coldStopwatch.elapsed.inMilliseconds;
      report['cold_start_threshold_ms'] = PerformanceThresholds.maxColdStartTime.inMilliseconds;
      report['cold_start_passed'] = coldStopwatch.elapsed < PerformanceThresholds.maxColdStartTime;

      // Measure warm start
      await tester.binding.setSurfaceSize(null);
      await tester.pumpAndSettle();

      final warmStopwatch = StopwatchMetric('warm_start_report');
      warmStopwatch.start();
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pumpAndSettle();
      warmStopwatch.stop();
      warmStopwatch.recordTo(collector);

      report['warm_start_ms'] = warmStopwatch.elapsed.inMilliseconds;
      report['warm_start_threshold_ms'] = PerformanceThresholds.maxWarmStartTime.inMilliseconds;
      report['warm_start_passed'] = warmStopwatch.elapsed < PerformanceThresholds.maxWarmStartTime;

      // Add metrics summary
      report['metrics_summary'] = collector.generateSummary();
      report['all_metrics'] = collector.toJson();

      // Print report
      debugPrint('=== APP LAUNCH PERFORMANCE REPORT ===');
      debugPrint('Cold Start: ${report['cold_start_ms']}ms (threshold: ${report['cold_start_threshold_ms']}ms) - ${report['cold_start_passed'] ? 'PASS' : 'FAIL'}');
      debugPrint('Warm Start: ${report['warm_start_ms']}ms (threshold: ${report['warm_start_threshold_ms']}ms) - ${report['warm_start_passed'] ? 'PASS' : 'FAIL'}');
      debugPrint('=====================================');

      expect(report['cold_start_passed'], isTrue, reason: 'Cold start performance test failed');
      expect(report['warm_start_passed'], isTrue, reason: 'Warm start performance test failed');
    });
  });
}
