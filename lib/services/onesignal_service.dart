import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:zendfast_1/models/push_notification.dart';
import 'package:zendfast_1/services/database_service.dart';

/// Service for managing OneSignal push notifications
///
/// This service handles:
/// - OneSignal SDK initialization
/// - Push notification permissions
/// - Notification event handling
/// - User segmentation with tags
/// - Deep link processing
/// - Notification templates for fasting and hydration
///
/// Usage:
/// ```dart
/// await OneSignalService.instance.initialize();
/// await OneSignalService.instance.requestPermission();
/// ```
class OneSignalService {
  static final OneSignalService instance = OneSignalService._();

  OneSignalService._();

  bool _isInitialized = false;
  final _notificationController = StreamController<PushNotification>.broadcast();

  /// Stream of incoming notifications
  Stream<PushNotification> get notificationStream =>
      _notificationController.stream;

  /// Initialize OneSignal SDK
  ///
  /// Must be called before any other OneSignal operations.
  /// Reads configuration from .env file.
  ///
  /// Note: Will silently fail if Firebase (Android) or APNs (iOS)
  /// are not configured. Check logs for configuration status.
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('OneSignalService already initialized');
      return;
    }

    try {
      final appId = dotenv.env['ONESIGNAL_APP_ID'];

      if (appId == null || appId.isEmpty) {
        debugPrint('⚠️ ONESIGNAL_APP_ID not found in .env');
        debugPrint('   Push notifications will not work until configured');
        return;
      }

      debugPrint('🔔 Initializing OneSignal with App ID: $appId');

      // Remove this method to stop OneSignal Debugging
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

      // Initialize OneSignal
      OneSignal.initialize(appId);

      // iOS: Request permission (Android grants automatically on API 33+)
      await _requestNotificationPermission();

      // Set up notification handlers
      _setupNotificationHandlers();

      _isInitialized = true;
      debugPrint('✅ OneSignal initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing OneSignal: $e');
      debugPrint('Stack trace: $stackTrace');
      // Don't throw - app should continue working without push notifications
    }
  }

  /// Request notification permission (primarily for iOS)
  ///
  /// Android 13+ (API 33+) also requires runtime permission.
  /// For older Android versions, permission is granted at install time.
  Future<void> _requestNotificationPermission() async {
    try {
      final accepted = await OneSignal.Notifications.requestPermission(true);
      debugPrint('📱 Notification permission: ${accepted ? "granted" : "denied"}');
    } catch (e) {
      debugPrint('⚠️ Error requesting notification permission: $e');
    }
  }

  /// Public method to request permission (can be called from UI)
  Future<bool> requestPermission() async {
    try {
      return await OneSignal.Notifications.requestPermission(true);
    } catch (e) {
      debugPrint('⚠️ Error requesting notification permission: $e');
      return false;
    }
  }

  /// Check if user has granted notification permission
  Future<bool> hasPermission() async {
    try {
      return OneSignal.Notifications.permission;
    } catch (e) {
      debugPrint('⚠️ Error checking notification permission: $e');
      return false;
    }
  }

  /// Set up notification event handlers
  void _setupNotificationHandlers() {
    // Handler for notification opened (user tapped notification)
    OneSignal.Notifications.addClickListener((event) {
      debugPrint('📬 Notification clicked: ${event.notification.notificationId}');
      _handleNotificationOpened(event);
    });

    // Handler for notification received while app is in foreground
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      debugPrint('📨 Notification received in foreground');
      _handleNotificationReceived(event);
    });

    // Handler for permission changes
    OneSignal.Notifications.addPermissionObserver((state) {
      debugPrint('🔔 Notification permission changed: $state');
    });
  }

  /// Handle notification opened by user
  void _handleNotificationOpened(OSNotificationClickEvent event) {
    final notification = event.notification;

    // Extract notification data
    final title = notification.title ?? 'Notification';
    final body = notification.body ?? '';
    final additionalData = notification.additionalData ?? {};
    final launchUrl = additionalData['launchURL'] as String?;

    debugPrint('Title: $title');
    debugPrint('Body: $body');
    debugPrint('Additional Data: $additionalData');
    debugPrint('Launch URL: $launchUrl');

    // Create push notification model and save to database
    final pushNotification = PushNotification()
      ..notificationId = notification.notificationId ?? DateTime.now().toString() // ignore: dead_code, dead_null_aware_expression
      ..title = title
      ..body = body
      ..additionalDataJson = jsonEncode(additionalData)
      ..actionUrl = launchUrl
      ..receivedAt = DateTime.now()
      ..isRead = true // User opened it
      ..type = additionalData['type'] as String? ?? 'general'
      ..fastingSessionId = additionalData['fasting_session_id'] as String?;

    // Save to database
    _saveNotification(pushNotification);

    // Broadcast to stream
    _notificationController.add(pushNotification);
  }

  /// Handle notification received in foreground
  void _handleNotificationReceived(OSNotificationWillDisplayEvent event) {
    final notification = event.notification;

    // Extract notification data
    final title = notification.title ?? 'Notification';
    final body = notification.body ?? '';
    final additionalData = notification.additionalData ?? {};

    // Create push notification model and save to database
    final pushNotification = PushNotification()
      ..notificationId = notification.notificationId ?? DateTime.now().toString() // ignore: dead_code, dead_null_aware_expression
      ..title = title
      ..body = body
      ..additionalDataJson = jsonEncode(additionalData)
      ..actionUrl = additionalData['launchURL'] as String?
      ..receivedAt = DateTime.now()
      ..isRead = false // Not opened yet
      ..type = additionalData['type'] as String? ?? 'general'
      ..fastingSessionId = additionalData['fasting_session_id'] as String?;

    // Save to database
    _saveNotification(pushNotification);

    // Broadcast to stream
    _notificationController.add(pushNotification);

    // Display the notification (can customize here)
    event.notification.display();
  }

  /// Save notification to local database
  Future<void> _saveNotification(PushNotification notification) async {
    try {
      final isar = DatabaseService.instance.isar;
      await isar.writeTxn(() async {
        await isar.pushNotifications.put(notification);
      });
      debugPrint('💾 Notification saved to database: ${notification.notificationId}');
    } catch (e) {
      debugPrint('⚠️ Error saving notification: $e');
    }
  }

  /// Set external user ID for OneSignal (maps to your app's user ID)
  Future<void> setExternalUserId(String userId) async {
    if (!_isInitialized) return;

    try {
      OneSignal.login(userId);
      debugPrint('👤 OneSignal external user ID set: $userId');
    } catch (e) {
      debugPrint('⚠️ Error setting external user ID: $e');
    }
  }

  /// Remove external user ID (on logout)
  Future<void> removeExternalUserId() async {
    if (!_isInitialized) return;

    try {
      OneSignal.logout();
      debugPrint('👤 OneSignal external user ID removed');
    } catch (e) {
      debugPrint('⚠️ Error removing external user ID: $e');
    }
  }

  /// Set user tags for segmentation
  ///
  /// Example tags:
  /// ```dart
  /// {
  ///   'fasting_plan': '16:8',
  ///   'experience_level': 'beginner',
  ///   'timezone': 'America/New_York',
  ///   'preferred_language': 'en',
  /// }
  /// ```
  Future<void> setUserTags(Map<String, String> tags) async {
    if (!_isInitialized) return;

    try {
      OneSignal.User.addTags(tags);
      debugPrint('🏷️ User tags set: $tags');
    } catch (e) {
      debugPrint('⚠️ Error setting user tags: $e');
    }
  }

  /// Remove specific user tag
  Future<void> removeUserTag(String key) async {
    if (!_isInitialized) return;

    try {
      OneSignal.User.removeTag(key);
      debugPrint('🏷️ User tag removed: $key');
    } catch (e) {
      debugPrint('⚠️ Error removing user tag: $e');
    }
  }

  // ============================================================================
  // NOTIFICATION TEMPLATES
  // ============================================================================

  /// Template: Fasting started
  Map<String, dynamic> fastingStartTemplate({
    required String fastingPlan,
    required int targetHours,
  }) {
    return {
      'headings': {'en': '🏁 Fasting Started!'},
      'contents': {
        'en': 'Your $fastingPlan fast has begun. Target: ${targetHours}h. Stay strong! 💪',
      },
      'data': {
        'type': 'fasting_start',
        'fasting_plan': fastingPlan,
        'target_hours': targetHours.toString(),
        'action_url': 'zendfast://fasting/view',
      },
      'url': 'zendfast://fasting/view',
    };
  }

  /// Template: Fasting milestone reached
  Map<String, dynamic> fastingMilestoneTemplate({
    required int hours,
    required int targetHours,
  }) {
    final percentage = ((hours / targetHours) * 100).round();
    final emoji = hours >= 12 ? '🔥' : '⭐';

    return {
      'headings': {'en': '$emoji Milestone Reached!'},
      'contents': {
        'en': 'Amazing! You\'ve completed ${hours}h of fasting ($percentage% to goal). Keep going!',
      },
      'data': {
        'type': 'milestone_${hours}h',
        'hours': hours.toString(),
        'target_hours': targetHours.toString(),
        'percentage': percentage.toString(),
        'action_url': 'zendfast://fasting/view',
      },
      'url': 'zendfast://fasting/view',
    };
  }

  /// Template: Fasting completed
  Map<String, dynamic> fastingCompleteTemplate({
    required int hours,
    required String fastingPlan,
  }) {
    return {
      'headings': {'en': '🎉 Fasting Complete!'},
      'contents': {
        'en': 'Congratulations! You completed your ${hours}h $fastingPlan fast. Well done! 🎊',
      },
      'data': {
        'type': 'fasting_complete',
        'hours': hours.toString(),
        'fasting_plan': fastingPlan,
        'action_url': 'zendfast://fasting/complete',
      },
      'url': 'zendfast://fasting/complete',
    };
  }

  /// Template: Hydration reminder
  Map<String, dynamic> hydrationReminderTemplate({
    int glassesConsumed = 0,
    int targetGlasses = 8,
  }) {
    return {
      'headings': {'en': '💧 Stay Hydrated!'},
      'contents': {
        'en': 'Time to drink water! You\'ve had $glassesConsumed/$targetGlasses glasses today.',
      },
      'data': {
        'type': 'hydration_reminder',
        'glasses_consumed': glassesConsumed.toString(),
        'target_glasses': targetGlasses.toString(),
        'action_url': 'zendfast://hydration',
      },
      'url': 'zendfast://hydration',
    };
  }

  /// Template: Re-engagement (user hasn't opened app recently)
  Map<String, dynamic> reEngagementTemplate({
    int daysSinceLastFast = 0,
  }) {
    return {
      'headings': {'en': '👋 We Miss You!'},
      'contents': {
        'en': daysSinceLastFast > 0
            ? 'It\'s been $daysSinceLastFast days since your last fast. Ready to get back on track?'
            : 'Ready to start a new fast? Your health journey continues! 🌟',
      },
      'data': {
        'type': 're_engagement',
        'days_since_last_fast': daysSinceLastFast.toString(),
        'action_url': 'zendfast://home',
      },
      'url': 'zendfast://home',
    };
  }

  /// Dispose resources
  void dispose() {
    _notificationController.close();
  }
}
