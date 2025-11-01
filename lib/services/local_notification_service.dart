import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Service for local push notifications (fallback when OneSignal not configured)
///
/// Uses flutter_local_notifications to schedule notifications locally.
/// Works without internet, Firebase, or Apple Developer account.
///
/// Limitations:
/// - Only works when app is installed
/// - Cannot send notifications from external server
/// - No segmentation or analytics
/// - No deep linking capabilities (basic only)
///
/// Perfect for:
/// - Development and testing
/// - MVP without server infrastructure
/// - Offline functionality
/// - Scheduled reminders
class LocalNotificationService {
  static final LocalNotificationService instance = LocalNotificationService._();

  LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize local notifications
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('LocalNotificationService already initialized');
      return;
    }

    try {
      // Initialize timezones for scheduled notifications
      tz.initializeTimeZones();

      // Android initialization settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      final iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
      );

      // Combined initialization settings
      final initializationSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize
      await _notifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Request permissions (iOS 10+, Android 13+)
      await _requestPermissions();

      _isInitialized = true;
      debugPrint('✅ LocalNotificationService initialized');
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing LocalNotificationService: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Request notification permissions
  Future<bool> _requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImplementation = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final result = await androidImplementation?.requestNotificationsPermission();
      return result ?? false;
    }
    return true;
  }

  /// Handler for iOS < 10 (deprecated but still needed for compatibility)
  void _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) {
    debugPrint('iOS < 10 notification: $title');
  }

  /// Handler for notification tapped
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // TODO: Handle navigation based on payload
    // Example: router.go(response.payload);
  }

  // ============================================================================
  // NOTIFICATION SCHEDULING
  // ============================================================================

  /// Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) {
      debugPrint('⚠️ LocalNotificationService not initialized');
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Notifications',
      channelDescription: 'General notifications for ZendFast',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );

    debugPrint('📱 Notification shown: $title');
  }

  /// Schedule notification for specific time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    if (!_isInitialized) {
      debugPrint('⚠️ LocalNotificationService not initialized');
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      'Scheduled Notifications',
      channelDescription: 'Scheduled reminders and alerts',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );

    debugPrint('⏰ Notification scheduled for $scheduledTime: $title');
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    debugPrint('🚫 Notification cancelled: $id');
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('🚫 All notifications cancelled');
  }

  // ============================================================================
  // FASTING NOTIFICATION TEMPLATES
  // ============================================================================

  /// Schedule fasting milestone notification
  Future<void> scheduleFastingMilestone({
    required DateTime time,
    required int hours,
    required int targetHours,
  }) async {
    final percentage = ((hours / targetHours) * 100).round();
    final emoji = hours >= 12 ? '🔥' : '⭐';

    await scheduleNotification(
      id: 1000 + hours, // Unique ID per milestone
      title: '$emoji Milestone Reached!',
      body: 'Amazing! You\'ve completed ${hours}h of fasting ($percentage% to goal). Keep going!',
      scheduledTime: time,
      payload: 'fasting/view',
    );
  }

  /// Schedule fasting completion notification
  Future<void> scheduleFastingCompletion({
    required DateTime time,
    required int hours,
    required String fastingPlan,
  }) async {
    await scheduleNotification(
      id: 2000, // Fixed ID for completion
      title: '🎉 Fasting Complete!',
      body: 'Congratulations! You completed your ${hours}h $fastingPlan fast. Well done! 🎊',
      scheduledTime: time,
      payload: 'fasting/complete',
    );
  }

  /// Schedule hydration reminder
  Future<void> scheduleHydrationReminder({
    required DateTime time,
    int glassesConsumed = 0,
    int targetGlasses = 8,
  }) async {
    await scheduleNotification(
      id: 3000, // Fixed ID for hydration
      title: '💧 Stay Hydrated!',
      body: 'Time to drink water! You\'ve had $glassesConsumed/$targetGlasses glasses today.',
      scheduledTime: time,
      payload: 'hydration',
    );
  }

  /// Schedule multiple hydration reminders throughout the day
  Future<void> scheduleHydrationReminders({
    required List<DateTime> times,
  }) async {
    for (var i = 0; i < times.length; i++) {
      await scheduleHydrationReminder(
        time: times[i],
      );
    }
  }

  /// Cancel all fasting-related notifications
  Future<void> cancelFastingNotifications() async {
    // Cancel milestone notifications (1000-1023 for 24h max)
    for (var i = 1000; i < 1024; i++) {
      await cancelNotification(i);
    }
    // Cancel completion notification
    await cancelNotification(2000);
    debugPrint('🚫 All fasting notifications cancelled');
  }

  /// Cancel all hydration notifications
  Future<void> cancelHydrationNotifications() async {
    // Cancel hydration notifications (3000-3100)
    for (var i = 3000; i < 3100; i++) {
      await cancelNotification(i);
    }
    debugPrint('🚫 All hydration notifications cancelled');
  }
}
