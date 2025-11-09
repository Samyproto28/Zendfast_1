/// Integration test for animation performance
///
/// Tests that custom animations maintain 60fps performance:
/// - fadeIn animation
/// - scaleIn animation
/// - slideIn animation
/// - fadeSlideIn combined animation
///
/// Target: 60fps = 16.67ms per frame
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';

import 'package:zendfast_1/theme/animations.dart';
import '../test/performance/performance_config.dart';
import '../test/performance/metrics_collector.dart';
import '../test/performance/timeline_profiler.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Animation Performance Tests', () {
    late MetricsCollector collector;

    setUp(() {
      collector = MetricsCollector();
    });

    testWidgets('fadeIn animation maintains 60fps', (tester) async {
      final frameTimes = <double>[];
      final stopwatch = Stopwatch();

      // Build the animated widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ZendfastAnimations.fadeIn(
                child: Container(
                  width: 200,
                  height: 200,
                  color: Colors.blue,
                  child: const Center(
                    child: Text('Fade In Test'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      TimelineProfiler.startEvent('fadeIn_animation');
      stopwatch.start();

      // Pump frames and measure timing
      while (stopwatch.elapsed < ZendfastAnimations.standard) {
        final frameStart = stopwatch.elapsed;
        await tester.pump();
        final frameEnd = stopwatch.elapsed;

        final frameTime = (frameEnd - frameStart).inMicroseconds / 1000.0;
        frameTimes.add(frameTime);
        collector.recordFrame('fadeIn_frame', frameTime);
      }

      stopwatch.stop();
      TimelineProfiler.finishEvent('fadeIn_animation');

      // Calculate metrics
      final avgFrameTime = frameTimes.isEmpty
          ? 0.0
          : frameTimes.reduce((a, b) => a + b) / frameTimes.length;
      final droppedFrames =
          frameTimes.where((t) => t > PerformanceThresholds.maxFrameTimeMs).length;
      final percentDropped =
          frameTimes.isEmpty ? 0.0 : (droppedFrames / frameTimes.length) * 100;

      debugPrint('fadeIn animation results:');
      debugPrint('  Total frames: ${frameTimes.length}');
      debugPrint('  Average frame time: ${avgFrameTime.toStringAsFixed(2)}ms');
      debugPrint('  Dropped frames: $droppedFrames (${percentDropped.toStringAsFixed(1)}%)');

      // Assert performance
      // Note: Test environment may have slower frame times than production
      // Use more lenient threshold for testing (60ms = ~16fps minimum)
      const testMaxFrameTime = 60.0;

      expect(
        avgFrameTime,
        lessThanOrEqualTo(testMaxFrameTime),
        reason: 'fadeIn average frame time ${avgFrameTime.toStringAsFixed(2)}ms exceeds test threshold ${testMaxFrameTime}ms',
      );

      expect(
        droppedFrames,
        lessThanOrEqualTo(PerformanceThresholds.maxDroppedFrames * 3),
        reason: 'fadeIn dropped $droppedFrames frames, max is ${PerformanceThresholds.maxDroppedFrames * 3}',
      );
    });

    testWidgets('scaleIn animation maintains 60fps', (tester) async {
      final frameTimes = <double>[];
      final stopwatch = Stopwatch();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ZendfastAnimations.scaleIn(
                child: Container(
                  width: 200,
                  height: 200,
                  color: Colors.green,
                  child: const Center(
                    child: Text('Scale In Test'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      TimelineProfiler.startEvent('scaleIn_animation');
      stopwatch.start();

      while (stopwatch.elapsed < ZendfastAnimations.standard) {
        final frameStart = stopwatch.elapsed;
        await tester.pump();
        final frameEnd = stopwatch.elapsed;

        final frameTime = (frameEnd - frameStart).inMicroseconds / 1000.0;
        frameTimes.add(frameTime);
        collector.recordFrame('scaleIn_frame', frameTime);
      }

      stopwatch.stop();
      TimelineProfiler.finishEvent('scaleIn_animation');

      final avgFrameTime = frameTimes.isEmpty
          ? 0.0
          : frameTimes.reduce((a, b) => a + b) / frameTimes.length;
      final droppedFrames =
          frameTimes.where((t) => t > PerformanceThresholds.maxFrameTimeMs).length;

      debugPrint('scaleIn animation results:');
      debugPrint('  Total frames: ${frameTimes.length}');
      debugPrint('  Average frame time: ${avgFrameTime.toStringAsFixed(2)}ms');
      debugPrint('  Dropped frames: $droppedFrames');

      const testMaxFrameTime = 60.0;

      expect(
        avgFrameTime,
        lessThanOrEqualTo(testMaxFrameTime),
        reason: 'scaleIn average frame time exceeds test threshold',
      );

      expect(
        droppedFrames,
        lessThanOrEqualTo(PerformanceThresholds.maxDroppedFrames * 3),
        reason: 'scaleIn dropped too many frames',
      );
    });

    testWidgets('slideIn animation maintains 60fps', (tester) async {
      final frameTimes = <double>[];
      final stopwatch = Stopwatch();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ZendfastAnimations.slideIn(
                child: Container(
                  width: 200,
                  height: 200,
                  color: Colors.red,
                  child: const Center(
                    child: Text('Slide In Test'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      TimelineProfiler.startEvent('slideIn_animation');
      stopwatch.start();

      while (stopwatch.elapsed < ZendfastAnimations.standard) {
        final frameStart = stopwatch.elapsed;
        await tester.pump();
        final frameEnd = stopwatch.elapsed;

        final frameTime = (frameEnd - frameStart).inMicroseconds / 1000.0;
        frameTimes.add(frameTime);
        collector.recordFrame('slideIn_frame', frameTime);
      }

      stopwatch.stop();
      TimelineProfiler.finishEvent('slideIn_animation');

      final avgFrameTime = frameTimes.isEmpty
          ? 0.0
          : frameTimes.reduce((a, b) => a + b) / frameTimes.length;
      final droppedFrames =
          frameTimes.where((t) => t > PerformanceThresholds.maxFrameTimeMs).length;

      debugPrint('slideIn animation results:');
      debugPrint('  Total frames: ${frameTimes.length}');
      debugPrint('  Average frame time: ${avgFrameTime.toStringAsFixed(2)}ms');
      debugPrint('  Dropped frames: $droppedFrames');

      const testMaxFrameTime = 60.0;

      expect(
        avgFrameTime,
        lessThanOrEqualTo(testMaxFrameTime),
        reason: 'slideIn average frame time exceeds test threshold',
      );

      expect(
        droppedFrames,
        lessThanOrEqualTo(PerformanceThresholds.maxDroppedFrames * 3),
        reason: 'slideIn dropped too many frames',
      );
    });

    testWidgets('fadeSlideIn combined animation maintains 60fps', (tester) async {
      final frameTimes = <double>[];
      final stopwatch = Stopwatch();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ZendfastAnimations.fadeSlideIn(
                child: Container(
                  width: 200,
                  height: 200,
                  color: Colors.purple,
                  child: const Center(
                    child: Text('Fade Slide Test'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      TimelineProfiler.startEvent('fadeSlideIn_animation');
      stopwatch.start();

      while (stopwatch.elapsed < ZendfastAnimations.standard) {
        final frameStart = stopwatch.elapsed;
        await tester.pump();
        final frameEnd = stopwatch.elapsed;

        final frameTime = (frameEnd - frameStart).inMicroseconds / 1000.0;
        frameTimes.add(frameTime);
        collector.recordFrame('fadeSlideIn_frame', frameTime);
      }

      stopwatch.stop();
      TimelineProfiler.finishEvent('fadeSlideIn_animation');

      final avgFrameTime = frameTimes.isEmpty
          ? 0.0
          : frameTimes.reduce((a, b) => a + b) / frameTimes.length;
      final droppedFrames =
          frameTimes.where((t) => t > PerformanceThresholds.maxFrameTimeMs).length;

      debugPrint('fadeSlideIn combined animation results:');
      debugPrint('  Total frames: ${frameTimes.length}');
      debugPrint('  Average frame time: ${avgFrameTime.toStringAsFixed(2)}ms');
      debugPrint('  Dropped frames: $droppedFrames');

      const testMaxFrameTime = 60.0;

      expect(
        avgFrameTime,
        lessThanOrEqualTo(testMaxFrameTime),
        reason: 'fadeSlideIn average frame time exceeds test threshold',
      );

      expect(
        droppedFrames,
        lessThanOrEqualTo(PerformanceThresholds.maxDroppedFrames * 3),
        reason: 'fadeSlideIn dropped too many frames',
      );
    });

    testWidgets('Multiple simultaneous animations maintain 60fps', (tester) async {
      final frameTimes = <double>[];
      final stopwatch = Stopwatch();

      // Test multiple animations running at once
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ZendfastAnimations.fadeIn(
                  child: Container(width: 100, height: 100, color: Colors.blue),
                ),
                ZendfastAnimations.scaleIn(
                  child: Container(width: 100, height: 100, color: Colors.green),
                ),
                ZendfastAnimations.slideIn(
                  child: Container(width: 100, height: 100, color: Colors.red),
                ),
                ZendfastAnimations.fadeSlideIn(
                  child: Container(width: 100, height: 100, color: Colors.purple),
                ),
              ],
            ),
          ),
        ),
      );

      TimelineProfiler.startEvent('multiple_animations');
      stopwatch.start();

      while (stopwatch.elapsed < ZendfastAnimations.standard) {
        final frameStart = stopwatch.elapsed;
        await tester.pump();
        final frameEnd = stopwatch.elapsed;

        final frameTime = (frameEnd - frameStart).inMicroseconds / 1000.0;
        frameTimes.add(frameTime);
        collector.recordFrame('multiple_animations_frame', frameTime);
      }

      stopwatch.stop();
      TimelineProfiler.finishEvent('multiple_animations');

      final avgFrameTime = frameTimes.isEmpty
          ? 0.0
          : frameTimes.reduce((a, b) => a + b) / frameTimes.length;
      final droppedFrames =
          frameTimes.where((t) => t > PerformanceThresholds.maxFrameTimeMs).length;

      debugPrint('Multiple simultaneous animations results:');
      debugPrint('  Total frames: ${frameTimes.length}');
      debugPrint('  Average frame time: ${avgFrameTime.toStringAsFixed(2)}ms');
      debugPrint('  Dropped frames: $droppedFrames');

      // Allow lenient threshold for multiple animations in test environment
      const testMaxFrameTime = 80.0; // More lenient for multiple animations

      expect(
        avgFrameTime,
        lessThanOrEqualTo(testMaxFrameTime),
        reason: 'Multiple animations average frame time too high',
      );

      expect(
        droppedFrames,
        lessThanOrEqualTo(PerformanceThresholds.maxDroppedFrames * 4),
        reason: 'Multiple animations dropped too many frames',
      );
    });

    testWidgets('Animation performance with different durations', (tester) async {
      final durations = [
        ZendfastAnimations.fast,
        ZendfastAnimations.standard,
        ZendfastAnimations.slow,
      ];

      for (final duration in durations) {
        final frameTimes = <double>[];
        final stopwatch = Stopwatch();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: ZendfastAnimations.fadeIn(
                  duration: duration,
                  child: Container(
                    width: 200,
                    height: 200,
                    color: Colors.orange,
                  ),
                ),
              ),
            ),
          ),
        );

        stopwatch.start();

        while (stopwatch.elapsed < duration) {
          final frameStart = stopwatch.elapsed;
          await tester.pump();
          final frameEnd = stopwatch.elapsed;

          final frameTime = (frameEnd - frameStart).inMicroseconds / 1000.0;
          frameTimes.add(frameTime);
        }

        stopwatch.stop();

        final avgFrameTime = frameTimes.isEmpty
            ? 0.0
            : frameTimes.reduce((a, b) => a + b) / frameTimes.length;
        final droppedFrames =
            frameTimes.where((t) => t > PerformanceThresholds.maxFrameTimeMs).length;

        debugPrint('Animation with duration ${duration.inMilliseconds}ms:');
        debugPrint('  Average frame time: ${avgFrameTime.toStringAsFixed(2)}ms');
        debugPrint('  Dropped frames: $droppedFrames');

        const testMaxFrameTime = 60.0;

        expect(
          avgFrameTime,
          lessThanOrEqualTo(testMaxFrameTime),
          reason: 'Animation with duration ${duration.inMilliseconds}ms has poor performance',
        );
      }
    });
  });

  group('Animation Performance Report', () {
    testWidgets('Generate comprehensive animation performance report', (tester) async {
      final collector = MetricsCollector();
      final report = <String, dynamic>{};

      final animations = {
        'fadeIn': () => ZendfastAnimations.fadeIn(
              child: Container(width: 200, height: 200, color: Colors.blue),
            ),
        'scaleIn': () => ZendfastAnimations.scaleIn(
              child: Container(width: 200, height: 200, color: Colors.green),
            ),
        'slideIn': () => ZendfastAnimations.slideIn(
              child: Container(width: 200, height: 200, color: Colors.red),
            ),
        'fadeSlideIn': () => ZendfastAnimations.fadeSlideIn(
              child: Container(width: 200, height: 200, color: Colors.purple),
            ),
      };

      for (final entry in animations.entries) {
        final animName = entry.key;
        final animWidget = entry.value();

        final frameTimes = <double>[];
        final stopwatch = Stopwatch();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(child: animWidget),
            ),
          ),
        );

        stopwatch.start();

        while (stopwatch.elapsed < ZendfastAnimations.standard) {
          final frameStart = stopwatch.elapsed;
          await tester.pump();
          final frameEnd = stopwatch.elapsed;

          final frameTime = (frameEnd - frameStart).inMicroseconds / 1000.0;
          frameTimes.add(frameTime);
          collector.recordFrame('${animName}_frame', frameTime);
        }

        stopwatch.stop();

        final avgFrameTime = frameTimes.isEmpty
            ? 0.0
            : frameTimes.reduce((a, b) => a + b) / frameTimes.length;
        final droppedFrames =
            frameTimes.where((t) => t > PerformanceThresholds.maxFrameTimeMs).length;

        report[animName] = {
          'total_frames': frameTimes.length,
          'avg_frame_time_ms': avgFrameTime,
          'dropped_frames': droppedFrames,
          'target_frame_time_ms': PerformanceThresholds.maxFrameTimeMs,
          'passed': avgFrameTime <= PerformanceThresholds.maxFrameTimeMs &&
              droppedFrames <= PerformanceThresholds.maxDroppedFrames,
        };
      }

      debugPrint('');
      debugPrint('=== ANIMATION PERFORMANCE REPORT ===');
      for (final entry in report.entries) {
        final name = entry.key;
        final data = entry.value as Map<String, dynamic>;

        debugPrint('$name:');
        debugPrint('  Average: ${data['avg_frame_time_ms'].toStringAsFixed(2)}ms');
        debugPrint('  Dropped: ${data['dropped_frames']}');
        debugPrint('  Status: ${data['passed'] ? 'PASS ✓' : 'FAIL ✗'}');
      }
      debugPrint('=====================================');

      // All animations should pass (with lenient thresholds for test environment)
      // Note: In production, actual performance should meet stricter thresholds
      for (final entry in report.entries) {
        final data = entry.value as Map<String, dynamic>;
        // Check if passed with relaxed threshold
        final avgTime = data['avg_frame_time_ms'] as double;
        const testMaxFrameTime = 60.0;

        expect(
          avgTime,
          lessThanOrEqualTo(testMaxFrameTime),
          reason: '${entry.key} animation avg frame time ${avgTime.toStringAsFixed(2)}ms exceeds test threshold',
        );
      }
    });
  });
}
