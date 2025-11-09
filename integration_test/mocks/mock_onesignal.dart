/// Mock OneSignal implementation for E2E testing
/// Provides deterministic responses for push notification operations
library;

import 'dart:async';

/// Mock OneSignal service for testing
/// Simulates OneSignal initialization, permissions, and notifications
class MockOneSignalService {
  static final MockOneSignalService _instance = MockOneSignalService._internal();

  factory MockOneSignalService() => _instance;

  MockOneSignalService._internal();

  bool _initialized = false;
  bool _permissionGranted = false;
  String? _appId;
  final List<MockNotification> _sentNotifications = [];
  final StreamController<MockNotification> _notificationController =
      StreamController<MockNotification>.broadcast();

  /// Check if OneSignal is initialized
  bool get isInitialized => _initialized;

  /// Check if notification permission is granted
  bool get hasPermission => _permissionGranted;

  /// Get app ID
  String? get appId => _appId;

  /// Get stream of notifications
  Stream<MockNotification> get notificationStream =>
      _notificationController.stream;

  /// Get list of sent notifications
  List<MockNotification> get sentNotifications =>
      List.unmodifiable(_sentNotifications);

  /// Initialize OneSignal
  Future<void> initialize(String appId) async {
    _appId = appId;
    _initialized = true;
  }

  /// Request notification permission
  Future<bool> requestPermission() async {
    if (!_initialized) {
      throw Exception('OneSignal not initialized');
    }

    // In tests, automatically grant permission
    _permissionGranted = true;
    return true;
  }

  /// Send a mock notification
  /// Simulates receiving a push notification
  void sendMockNotification({
    required String title,
    required String body,
    Map<String, dynamic>? additionalData,
  }) {
    if (!_initialized) {
      throw Exception('OneSignal not initialized');
    }

    final notification = MockNotification(
      id: 'mock-notif-${_sentNotifications.length + 1}',
      title: title,
      body: body,
      additionalData: additionalData ?? {},
      receivedAt: DateTime.now(),
    );

    _sentNotifications.add(notification);
    _notificationController.add(notification);
  }

  /// Set external user ID
  Future<void> setExternalUserId(String userId) async {
    if (!_initialized) {
      throw Exception('OneSignal not initialized');
    }
    // Mock implementation - just store it
  }

  /// Send tag
  Future<void> sendTag(String key, String value) async {
    if (!_initialized) {
      throw Exception('OneSignal not initialized');
    }
    // Mock implementation
  }

  /// Send tags
  Future<void> sendTags(Map<String, String> tags) async {
    if (!_initialized) {
      throw Exception('OneSignal not initialized');
    }
    // Mock implementation
  }

  /// Clear all sent notifications
  void clearNotifications() {
    _sentNotifications.clear();
  }

  /// Reset mock service
  void reset() {
    _initialized = false;
    _permissionGranted = false;
    _appId = null;
    _sentNotifications.clear();
  }

  /// Dispose
  void dispose() {
    _notificationController.close();
  }
}

/// Mock notification model
class MockNotification {
  final String id;
  final String title;
  final String body;
  final Map<String, dynamic> additionalData;
  final DateTime receivedAt;
  bool opened = false;

  MockNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.additionalData,
    required this.receivedAt,
  });

  /// Mark notification as opened
  void markAsOpened() {
    opened = true;
  }

  @override
  String toString() {
    return 'MockNotification(id: $id, title: $title, body: $body, '
        'opened: $opened, receivedAt: $receivedAt)';
  }
}

/// Helper class for common notification scenarios
class MockNotificationScenarios {
  /// Send fasting start notification
  static void sendFastingStart(MockOneSignalService service) {
    service.sendMockNotification(
      title: 'Fast Started',
      body: 'Your fast has begun. Stay strong!',
      additionalData: {
        'type': 'fasting_start',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Send fasting complete notification
  static void sendFastingComplete(MockOneSignalService service) {
    service.sendMockNotification(
      title: 'Fast Complete!',
      body: 'Congratulations! You completed your fast.',
      additionalData: {
        'type': 'fasting_complete',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Send fasting milestone notification
  static void sendFastingMilestone(
    MockOneSignalService service,
    String milestone,
  ) {
    service.sendMockNotification(
      title: 'Milestone Reached',
      body: 'You\'re $milestone through your fast!',
      additionalData: {
        'type': 'fasting_milestone',
        'milestone': milestone,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Send hydration reminder notification
  static void sendHydrationReminder(MockOneSignalService service) {
    service.sendMockNotification(
      title: 'Drink Water',
      body: 'Remember to stay hydrated!',
      additionalData: {
        'type': 'hydration_reminder',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Send streak milestone notification
  static void sendStreakMilestone(MockOneSignalService service, int days) {
    service.sendMockNotification(
      title: 'Streak Milestone!',
      body: 'You\'ve reached a $days-day streak!',
      additionalData: {
        'type': 'streak_milestone',
        'days': days,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}
