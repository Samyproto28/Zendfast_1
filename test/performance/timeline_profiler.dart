/// DevTools Timeline integration for performance profiling
library;

import 'dart:developer' as developer;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'metrics_collector.dart';

/// Helper for profiling with DevTools Timeline
class TimelineProfiler {
  static final TimelineProfiler _instance = TimelineProfiler._();
  factory TimelineProfiler() => _instance;
  TimelineProfiler._();

  /// Start a Timeline event
  ///
  /// Example:
  /// ```dart
  /// TimelineProfiler.startEvent('MyOperation');
  /// // ... do work ...
  /// TimelineProfiler.finishEvent('MyOperation');
  /// ```
  static void startEvent(String name, {Map<String, String>? arguments}) {
    developer.Timeline.startSync(
      name,
      arguments: arguments,
    );
  }

  /// Finish a Timeline event
  static void finishEvent(String name) {
    developer.Timeline.finishSync();
  }

  /// Execute a function within a Timeline event
  ///
  /// Example:
  /// ```dart
  /// await TimelineProfiler.profileAsync('LoadData', () async {
  ///   await loadData();
  /// });
  /// ```
  static Future<T> profileAsync<T>(
    String name,
    Future<T> Function() function, {
    Map<String, String>? arguments,
  }) async {
    startEvent(name, arguments: arguments);
    try {
      return await function();
    } finally {
      finishEvent(name);
    }
  }

  /// Execute a synchronous function within a Timeline event
  static T profileSync<T>(
    String name,
    T Function() function, {
    Map<String, String>? arguments,
  }) {
    startEvent(name, arguments: arguments);
    try {
      return function();
    } finally {
      finishEvent(name);
    }
  }

  /// Mark a specific instant in the Timeline
  static void markInstant(String name, {Map<String, String>? arguments}) {
    developer.Timeline.instantSync(name, arguments: arguments);
  }
}

/// Frame timing tracker using Flutter's frame callbacks
class FrameTimingTracker {
  final MetricsCollector collector;
  final List<ui.FrameTiming> _frameTimings = [];

  bool _isTracking = false;

  FrameTimingTracker(this.collector);

  /// Start tracking frame timings
  void start() {
    if (_isTracking) return;

    _isTracking = true;
    _frameTimings.clear();

    // Note: Frame timing callback registration would be done here
    // In integration tests, frame timing is measured manually in test code
  }

  /// Stop tracking frame timings
  void stop() {
    if (!_isTracking) return;
    _isTracking = false;
  }

  /// Get all collected frame timings
  List<ui.FrameTiming> get frameTimings => List.unmodifiable(_frameTimings);

  /// Calculate frame statistics
  Map<String, dynamic> getStatistics() {
    if (_frameTimings.isEmpty) {
      return {
        'totalFrames': 0,
        'averageFrameTime': 0.0,
        'droppedFrames': 0,
      };
    }

    final frameTimes = _frameTimings.map((timing) {
      final total = timing.buildDuration + timing.rasterDuration;
      return total.inMicroseconds / 1000.0; // Convert to ms
    }).toList();

    final avgFrameTime = frameTimes.reduce((a, b) => a + b) / frameTimes.length;
    final droppedFrames = frameTimes.where((t) => t > 16.67).length;

    return {
      'totalFrames': _frameTimings.length,
      'averageFrameTime': avgFrameTime,
      'droppedFrames': droppedFrames,
      'percentDropped': (droppedFrames / _frameTimings.length) * 100,
    };
  }

  /// Clear collected data
  void clear() {
    _frameTimings.clear();
  }
}

/// Helper for tracking rendering performance in tests
class RenderingPerformanceTracker {
  final WidgetTester tester;
  final MetricsCollector collector;
  final Stopwatch _stopwatch = Stopwatch();

  RenderingPerformanceTracker({
    required this.tester,
    required this.collector,
  });

  /// Measure time to render a widget
  Future<Duration> measureRenderTime(Future<void> Function() renderAction) async {
    _stopwatch.reset();
    _stopwatch.start();

    await renderAction();
    await tester.pumpAndSettle();

    _stopwatch.stop();
    final duration = _stopwatch.elapsed;

    collector.recordTiming('render_time', duration);

    return duration;
  }

  /// Measure frame times during an animation
  Future<List<double>> measureAnimationFrames(
    Future<void> Function() animationAction, {
    Duration? duration,
  }) async {
    final frameTimes = <double>[];
    final startTime = DateTime.now();

    // Pump frames and measure timing
    await animationAction();

    // Pump multiple frames to capture animation
    while (duration == null || DateTime.now().difference(startTime) < duration) {
      final frameStart = DateTime.now();
      await tester.pump();
      final frameEnd = DateTime.now();

      final frameTime = frameEnd.difference(frameStart).inMicroseconds / 1000.0;
      frameTimes.add(frameTime);

      collector.recordFrame('animation_frame', frameTime);

      // Break if animation is settled
      if (tester.binding.hasScheduledFrame == false) {
        break;
      }
    }

    return frameTimes;
  }

  /// Measure widget build performance
  Future<Duration> measureBuildTime(Future<void> Function() buildAction) async {
    _stopwatch.reset();
    TimelineProfiler.startEvent('widget_build');

    _stopwatch.start();
    await buildAction();
    _stopwatch.stop();

    TimelineProfiler.finishEvent('widget_build');

    final duration = _stopwatch.elapsed;
    collector.recordTiming('build_time', duration);

    return duration;
  }
}

/// Helper for profiling memory during tests
class MemoryProfiler {
  final MetricsCollector collector;

  MemoryProfiler(this.collector);

  /// Get current memory usage (approximate)
  ///
  /// Note: This is an approximation based on Dart VM metrics
  /// For accurate memory profiling, use DevTools directly
  double getCurrentMemoryMB() {
    // In Flutter tests, we can't easily get exact memory usage
    // This would need to be implemented with platform-specific code
    // For now, we return 0 and rely on DevTools for accurate measurements
    debugPrint('Warning: Memory profiling requires platform-specific implementation');
    return 0.0;
  }

  /// Record current memory usage
  void recordCurrentMemory(String name) {
    final memoryMB = getCurrentMemoryMB();
    collector.recordMemory(name, memoryMB);
  }

  /// Profile memory during an operation
  Future<void> profileMemoryDuring(
    String name,
    Future<void> Function() operation,
  ) async {
    recordCurrentMemory('${name}_before');

    await operation();

    recordCurrentMemory('${name}_after');
  }
}

/// Utilities for performance assertions in tests
class PerformanceAssertions {
  /// Assert that a duration is within a threshold
  static void assertDurationLessThan(
    Duration actual,
    Duration threshold, {
    String? reason,
  }) {
    expect(
      actual,
      lessThan(threshold),
      reason: reason ?? 'Duration $actual exceeds threshold $threshold',
    );
  }

  /// Assert frame rate meets target (e.g., 60fps = 16.67ms per frame)
  static void assertFrameRate(
    List<double> frameTimes,
    double targetFps, {
    int maxDroppedFrames = 5,
  }) {
    final targetFrameTime = 1000.0 / targetFps; // ms per frame
    final droppedFrames = frameTimes.where((t) => t > targetFrameTime).length;

    expect(
      droppedFrames,
      lessThanOrEqualTo(maxDroppedFrames),
      reason: 'Too many dropped frames: $droppedFrames (max: $maxDroppedFrames)',
    );
  }

  /// Assert average frame time meets target
  static void assertAverageFrameTime(
    List<double> frameTimes,
    double maxFrameTimeMs,
  ) {
    if (frameTimes.isEmpty) return;

    final avgFrameTime = frameTimes.reduce((a, b) => a + b) / frameTimes.length;

    expect(
      avgFrameTime,
      lessThanOrEqualTo(maxFrameTimeMs),
      reason: 'Average frame time $avgFrameTime ms exceeds max $maxFrameTimeMs ms',
    );
  }
}
