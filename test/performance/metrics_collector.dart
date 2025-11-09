/// Utilities for collecting performance metrics during tests
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:battery_plus/battery_plus.dart';

/// Collects and stores performance metrics during test execution
class MetricsCollector {
  final List<PerformanceMetric> _metrics = [];
  final Battery _battery = Battery();

  /// All collected metrics
  List<PerformanceMetric> get metrics => List.unmodifiable(_metrics);

  /// Record a single metric
  void record(PerformanceMetric metric) {
    _metrics.add(metric);
  }

  /// Record a timing metric
  void recordTiming(String name, Duration duration) {
    record(TimingMetric(
      name: name,
      timestamp: DateTime.now(),
      duration: duration,
    ));
  }

  /// Record a memory metric
  void recordMemory(String name, double memoryMB) {
    record(MemoryMetric(
      name: name,
      timestamp: DateTime.now(),
      memoryMB: memoryMB,
    ));
  }

  /// Record a frame timing metric
  void recordFrame(String name, double frameTimeMs) {
    record(FrameMetric(
      name: name,
      timestamp: DateTime.now(),
      frameTimeMs: frameTimeMs,
    ));
  }

  /// Record a battery level metric
  Future<void> recordBatteryLevel(String name) async {
    try {
      final level = await _battery.batteryLevel;
      record(BatteryMetric(
        name: name,
        timestamp: DateTime.now(),
        batteryLevel: level,
      ));
    } catch (e) {
      debugPrint('Failed to record battery level: $e');
    }
  }

  /// Get metrics by type
  List<T> getMetricsByType<T extends PerformanceMetric>() {
    return _metrics.whereType<T>().toList();
  }

  /// Get metrics by name
  List<PerformanceMetric> getMetricsByName(String name) {
    return _metrics.where((m) => m.name == name).toList();
  }

  /// Clear all metrics
  void clear() {
    _metrics.clear();
  }

  /// Generate a summary report
  Map<String, dynamic> generateSummary() {
    return {
      'totalMetrics': _metrics.length,
      'timingMetrics': getMetricsByType<TimingMetric>().length,
      'memoryMetrics': getMetricsByType<MemoryMetric>().length,
      'frameMetrics': getMetricsByType<FrameMetric>().length,
      'batteryMetrics': getMetricsByType<BatteryMetric>().length,
      'collectionPeriod': {
        'start': _metrics.isNotEmpty ? _metrics.first.timestamp.toIso8601String() : null,
        'end': _metrics.isNotEmpty ? _metrics.last.timestamp.toIso8601String() : null,
      },
    };
  }

  /// Export metrics to JSON-serializable format
  Map<String, dynamic> toJson() {
    return {
      'metrics': _metrics.map((m) => m.toJson()).toList(),
      'summary': generateSummary(),
    };
  }
}

/// Base class for performance metrics
abstract class PerformanceMetric {
  final String name;
  final DateTime timestamp;

  const PerformanceMetric({
    required this.name,
    required this.timestamp,
  });

  Map<String, dynamic> toJson();
}

/// Timing metric (e.g., launch time, operation duration)
class TimingMetric extends PerformanceMetric {
  final Duration duration;

  const TimingMetric({
    required super.name,
    required super.timestamp,
    required this.duration,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'timing',
      'name': name,
      'timestamp': timestamp.toIso8601String(),
      'durationMs': duration.inMilliseconds,
    };
  }
}

/// Memory usage metric
class MemoryMetric extends PerformanceMetric {
  final double memoryMB;

  const MemoryMetric({
    required super.name,
    required super.timestamp,
    required this.memoryMB,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'memory',
      'name': name,
      'timestamp': timestamp.toIso8601String(),
      'memoryMB': memoryMB,
    };
  }
}

/// Frame timing metric
class FrameMetric extends PerformanceMetric {
  final double frameTimeMs;

  const FrameMetric({
    required super.name,
    required super.timestamp,
    required this.frameTimeMs,
  });

  bool get isDroppedFrame => frameTimeMs > 16.67;

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'frame',
      'name': name,
      'timestamp': timestamp.toIso8601String(),
      'frameTimeMs': frameTimeMs,
      'isDropped': isDroppedFrame,
    };
  }
}

/// Battery level metric
class BatteryMetric extends PerformanceMetric {
  final int batteryLevel; // 0-100

  const BatteryMetric({
    required super.name,
    required super.timestamp,
    required this.batteryLevel,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'battery',
      'name': name,
      'timestamp': timestamp.toIso8601String(),
      'batteryLevel': batteryLevel,
    };
  }
}

/// Helper for continuous metrics collection
class ContinuousMetricsCollector {
  final MetricsCollector collector;
  final Duration interval;
  Timer? _timer;
  final List<Future<void> Function()> _collectors = [];

  ContinuousMetricsCollector({
    required this.collector,
    this.interval = const Duration(seconds: 10),
  });

  /// Add a memory collector
  void addMemoryCollector(Future<double> Function() getMemoryMB) {
    _collectors.add(() async {
      final memory = await getMemoryMB();
      collector.recordMemory('continuous_memory', memory);
    });
  }

  /// Add a battery collector
  void addBatteryCollector() {
    _collectors.add(() async {
      await collector.recordBatteryLevel('continuous_battery');
    });
  }

  /// Start continuous collection
  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) async {
      for (final collect in _collectors) {
        try {
          await collect();
        } catch (e) {
          debugPrint('Error in continuous collection: $e');
        }
      }
    });
  }

  /// Stop continuous collection
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Dispose resources
  void dispose() {
    stop();
  }
}

/// Helper to measure elapsed time with high precision
class StopwatchMetric {
  final Stopwatch _stopwatch = Stopwatch();
  final String name;

  StopwatchMetric(this.name);

  /// Start timing
  void start() {
    _stopwatch.start();
  }

  /// Stop timing and return duration
  Duration stop() {
    _stopwatch.stop();
    return _stopwatch.elapsed;
  }

  /// Reset the stopwatch
  void reset() {
    _stopwatch.reset();
  }

  /// Get current elapsed time without stopping
  Duration get elapsed => _stopwatch.elapsed;

  /// Record to a metrics collector
  void recordTo(MetricsCollector collector) {
    collector.recordTiming(name, elapsed);
  }
}

/// Helper for calculating statistics from metrics
class MetricsStatistics {
  /// Calculate average frame time from frame metrics
  static double averageFrameTime(List<FrameMetric> frames) {
    if (frames.isEmpty) return 0.0;
    final sum = frames.fold<double>(0.0, (sum, frame) => sum + frame.frameTimeMs);
    return sum / frames.length;
  }

  /// Count dropped frames (>16.67ms)
  static int countDroppedFrames(List<FrameMetric> frames) {
    return frames.where((f) => f.isDroppedFrame).length;
  }

  /// Calculate memory growth rate (MB per minute)
  static double memoryGrowthRate(List<MemoryMetric> metrics) {
    if (metrics.length < 2) return 0.0;

    final first = metrics.first;
    final last = metrics.last;
    final memoryDelta = last.memoryMB - first.memoryMB;
    final timeDelta = last.timestamp.difference(first.timestamp);

    if (timeDelta.inMinutes == 0) return 0.0;

    return memoryDelta / timeDelta.inMinutes;
  }

  /// Calculate battery drain rate (% per hour)
  static double batteryDrainRate(List<BatteryMetric> metrics) {
    if (metrics.length < 2) return 0.0;

    final first = metrics.first;
    final last = metrics.last;
    final batteryDelta = first.batteryLevel - last.batteryLevel;
    final timeDelta = last.timestamp.difference(first.timestamp);

    if (timeDelta.inHours == 0) return 0.0;

    return batteryDelta / timeDelta.inHours;
  }

  /// Get percentile value from a list of numbers
  static double percentile(List<double> values, int percentile) {
    if (values.isEmpty) return 0.0;
    final sorted = List<double>.from(values)..sort();
    final index = ((percentile / 100) * (sorted.length - 1)).round();
    return sorted[index];
  }
}
