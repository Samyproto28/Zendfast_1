/// Performance testing configuration and thresholds
///
/// This file defines acceptable performance thresholds for automated testing.
/// Tests will fail if metrics exceed these values.
library;

/// Performance thresholds for automated testing
class PerformanceThresholds {
  // Prevent instantiation
  PerformanceThresholds._();

  /// Timer accuracy threshold: ±5 seconds per hour (in milliseconds)
  /// For 1 hour test: should be accurate within ±5000ms
  /// For full 16 hour test: should be accurate within ±80000ms (±80s)
  static const Duration timerAccuracyPerHour = Duration(seconds: 5);

  /// Maximum timer drift for 1 hour test (used in CI)
  static const Duration timerAccuracyOneHour = Duration(seconds: 5);

  /// Maximum timer drift for full 16 hour test (manual validation)
  static const Duration timerAccuracy16Hours = Duration(seconds: 80);

  /// Cold start app launch time: <2 seconds
  static const Duration maxColdStartTime = Duration(seconds: 2);

  /// Warm start app launch time: <500ms
  static const Duration maxWarmStartTime = Duration(milliseconds: 500);

  /// Target frame rate: 60fps = 16.67ms per frame
  static const double targetFrameRate = 60.0;

  /// Maximum acceptable frame time (in milliseconds)
  /// 60fps = 16.67ms, allowing 10% margin = 18.33ms
  static const double maxFrameTimeMs = 18.33;

  /// Maximum number of dropped frames per test run
  static const int maxDroppedFrames = 5;

  /// Battery consumption threshold: <5% per hour in background
  /// For 1 hour test: <5%
  /// For 16 hour test: <80% (but typically much lower)
  static const double maxBatteryDrainPerHour = 5.0; // percentage

  /// Maximum memory usage in megabytes
  /// Baseline memory for app + reasonable overhead
  static const double maxMemoryUsageMB = 150.0;

  /// Maximum memory increase during timer run (in MB)
  static const double maxMemoryIncreaseMB = 50.0;

  /// Memory leak threshold: memory growth per minute (in MB)
  /// If memory grows more than this per minute, it's likely a leak
  static const double memoryLeakThresholdMBPerMinute = 1.0;

  /// Performance test durations
  ///
  /// Note: Full 16-hour tests should be run manually.
  /// CI runs abbreviated 1-hour versions.
  static const Duration abbreviatedTestDuration = Duration(hours: 1);
  static const Duration fullTestDuration = Duration(hours: 16);

  /// How often to sample metrics during tests
  static const Duration metricsSamplingInterval = Duration(seconds: 10);
}

/// Test configuration for different environments
enum TestEnvironment {
  /// Local development testing
  local,

  /// Continuous integration environment
  ci,

  /// Manual validation on physical devices
  manual,
}

/// Configuration for a specific test run
class PerformanceTestConfig {
  /// The test environment
  final TestEnvironment environment;

  /// Test duration (abbreviated for CI, full for manual)
  final Duration duration;

  /// Whether to generate detailed reports
  final bool generateReport;

  /// Whether to fail on threshold violations
  final bool failOnViolation;

  /// Output directory for reports
  final String reportOutputDir;

  const PerformanceTestConfig({
    required this.environment,
    required this.duration,
    this.generateReport = true,
    this.failOnViolation = true,
    this.reportOutputDir = 'test/performance/reports',
  });

  /// Default configuration for CI environment
  static const ci = PerformanceTestConfig(
    environment: TestEnvironment.ci,
    duration: PerformanceThresholds.abbreviatedTestDuration,
    generateReport: true,
    failOnViolation: true,
  );

  /// Default configuration for local development
  static const local = PerformanceTestConfig(
    environment: TestEnvironment.local,
    duration: PerformanceThresholds.abbreviatedTestDuration,
    generateReport: true,
    failOnViolation: false, // Just warn locally
  );

  /// Configuration for manual 16-hour validation
  static const manual = PerformanceTestConfig(
    environment: TestEnvironment.manual,
    duration: PerformanceThresholds.fullTestDuration,
    generateReport: true,
    failOnViolation: true,
  );
}

/// Device profiles for testing
class DeviceProfile {
  final String name;
  final String platform; // 'android' or 'ios'
  final String deviceId;

  const DeviceProfile({
    required this.name,
    required this.platform,
    required this.deviceId,
  });

  /// Google Pixel 6 emulator profile
  static const pixel6 = DeviceProfile(
    name: 'Pixel 6',
    platform: 'android',
    deviceId: 'pixel_6_api_33',
  );

  /// iPhone 13 simulator profile
  static const iphone13 = DeviceProfile(
    name: 'iPhone 13',
    platform: 'ios',
    deviceId: 'iPhone-13',
  );
}
