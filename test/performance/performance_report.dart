/// Performance report generation utilities
library;

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'metrics_collector.dart';
import 'performance_config.dart';

/// Generates performance test reports
class PerformanceReportGenerator {
  final MetricsCollector collector;
  final String testName;
  final DateTime startTime;

  PerformanceReportGenerator({
    required this.collector,
    required this.testName,
    DateTime? startTime,
  }) : startTime = startTime ?? DateTime.now();

  /// Generate a comprehensive report
  Map<String, dynamic> generateReport({
    Map<String, dynamic>? customMetrics,
    List<String>? notes,
  }) {
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);

    final report = {
      'test_name': testName,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'duration_seconds': duration.inSeconds,
      'metrics_summary': collector.generateSummary(),
      'metrics': collector.toJson(),
      'custom_metrics': customMetrics ?? {},
      'notes': notes ?? [],
      'thresholds': _getThresholds(),
    };

    return report;
  }

  /// Get performance thresholds for comparison
  Map<String, dynamic> _getThresholds() {
    return {
      'cold_start_ms': PerformanceThresholds.maxColdStartTime.inMilliseconds,
      'warm_start_ms': PerformanceThresholds.maxWarmStartTime.inMilliseconds,
      'timer_accuracy_1h_ms': PerformanceThresholds.timerAccuracyOneHour.inMilliseconds,
      'timer_accuracy_16h_ms': PerformanceThresholds.timerAccuracy16Hours.inMilliseconds,
      'max_frame_time_ms': PerformanceThresholds.maxFrameTimeMs,
      'max_dropped_frames': PerformanceThresholds.maxDroppedFrames,
      'max_memory_mb': PerformanceThresholds.maxMemoryUsageMB,
      'max_battery_drain_per_hour': PerformanceThresholds.maxBatteryDrainPerHour,
    };
  }

  /// Save report to JSON file
  Future<void> saveToFile(String filename) async {
    final report = generateReport();
    final json = JsonEncoder.withIndent('  ').convert(report);

    final file = File(filename);
    await file.create(recursive: true);
    await file.writeAsString(json);

    debugPrint('Performance report saved to: $filename');
  }

  /// Generate markdown summary
  String generateMarkdownSummary({
    Map<String, dynamic>? results,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('# Performance Test Report: $testName');
    buffer.writeln('');
    buffer.writeln('**Test Date:** ${DateTime.now().toIso8601String()}');
    buffer.writeln('**Duration:** ${DateTime.now().difference(startTime).inSeconds}s');
    buffer.writeln('');

    if (results != null) {
      buffer.writeln('## Results');
      buffer.writeln('');
      for (final entry in results.entries) {
        final key = entry.key;
        final value = entry.value;
        final passed = value is Map && value['passed'] == true;
        final status = passed ? '✅ PASS' : '❌ FAIL';

        buffer.writeln('### $key: $status');

        if (value is Map) {
          for (final metric in value.entries) {
            if (metric.key != 'passed') {
              buffer.writeln('- ${metric.key}: ${metric.value}');
            }
          }
        }
        buffer.writeln('');
      }
    }

    buffer.writeln('## Metrics Summary');
    buffer.writeln('');
    final summary = collector.generateSummary();
    for (final entry in summary.entries) {
      buffer.writeln('- **${entry.key}**: ${entry.value}');
    }

    return buffer.toString();
  }
}

/// Compare performance metrics against baseline
class PerformanceComparator {
  final Map<String, dynamic> baseline;
  final Map<String, dynamic> current;

  PerformanceComparator({
    required this.baseline,
    required this.current,
  });

  /// Load baseline from file
  static Future<PerformanceComparator> loadFromFile({
    required String baselineFile,
    required Map<String, dynamic> current,
  }) async {
    final file = File(baselineFile);
    if (!await file.exists()) {
      throw Exception('Baseline file not found: $baselineFile');
    }

    final contents = await file.readAsString();
    final baseline = jsonDecode(contents) as Map<String, dynamic>;

    return PerformanceComparator(
      baseline: baseline,
      current: current,
    );
  }

  /// Compare metrics and detect regressions
  Map<String, dynamic> compareMetrics() {
    final regressions = <String, dynamic>{};
    final improvements = <String, dynamic>{};
    final unchanged = <String, dynamic>{};

    // Compare each metric
    for (final key in baseline.keys) {
      if (!current.containsKey(key)) continue;

      final baselineValue = baseline[key];
      final currentValue = current[key];

      if (baselineValue is num && currentValue is num) {
        final delta = currentValue - baselineValue;
        final percentChange = (delta / baselineValue) * 100;

        final comparison = {
          'baseline': baselineValue,
          'current': currentValue,
          'delta': delta,
          'percent_change': percentChange,
        };

        if (percentChange.abs() < 5) {
          // Less than 5% change
          unchanged[key] = comparison;
        } else if (delta > 0) {
          // Performance regression (higher is worse for most metrics)
          regressions[key] = comparison;
        } else {
          // Performance improvement
          improvements[key] = comparison;
        }
      }
    }

    return {
      'regressions': regressions,
      'improvements': improvements,
      'unchanged': unchanged,
      'has_regressions': regressions.isNotEmpty,
    };
  }

  /// Generate comparison report
  String generateComparisonReport() {
    final comparison = compareMetrics();
    final buffer = StringBuffer();

    buffer.writeln('# Performance Comparison Report');
    buffer.writeln('');

    if (comparison['has_regressions'] == true) {
      buffer.writeln('⚠️ **REGRESSIONS DETECTED**');
      buffer.writeln('');
    }

    final regressions = comparison['regressions'] as Map;
    if (regressions.isNotEmpty) {
      buffer.writeln('## ❌ Regressions');
      buffer.writeln('');
      for (final entry in regressions.entries) {
        final metric = entry.value as Map;
        buffer.writeln('### ${entry.key}');
        buffer.writeln('- Baseline: ${metric['baseline']}');
        buffer.writeln('- Current: ${metric['current']}');
        buffer.writeln('- Change: ${metric['percent_change'].toStringAsFixed(1)}%');
        buffer.writeln('');
      }
    }

    final improvements = comparison['improvements'] as Map;
    if (improvements.isNotEmpty) {
      buffer.writeln('## ✅ Improvements');
      buffer.writeln('');
      for (final entry in improvements.entries) {
        final metric = entry.value as Map;
        buffer.writeln('### ${entry.key}');
        buffer.writeln('- Baseline: ${metric['baseline']}');
        buffer.writeln('- Current: ${metric['current']}');
        buffer.writeln('- Change: ${metric['percent_change'].toStringAsFixed(1)}%');
        buffer.writeln('');
      }
    }

    return buffer.toString();
  }
}

/// Save baseline metrics for future comparison
class BaselineManager {
  static const String defaultBaselinePath = 'test/performance/baseline_metrics.json';

  /// Save current metrics as baseline
  static Future<void> saveBaseline({
    required Map<String, dynamic> metrics,
    String? filepath,
  }) async {
    final path = filepath ?? defaultBaselinePath;
    final file = File(path);

    final baseline = {
      'created_at': DateTime.now().toIso8601String(),
      'metrics': metrics,
    };

    final json = JsonEncoder.withIndent('  ').convert(baseline);
    await file.create(recursive: true);
    await file.writeAsString(json);

    debugPrint('Baseline saved to: $path');
  }

  /// Load baseline metrics
  static Future<Map<String, dynamic>> loadBaseline({
    String? filepath,
  }) async {
    final path = filepath ?? defaultBaselinePath;
    final file = File(path);

    if (!await file.exists()) {
      throw Exception('Baseline file not found: $path');
    }

    final contents = await file.readAsString();
    return jsonDecode(contents) as Map<String, dynamic>;
  }
}
