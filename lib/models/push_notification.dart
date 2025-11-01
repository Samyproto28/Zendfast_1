import 'package:isar/isar.dart';

part 'push_notification.g.dart';

/// Model for storing push notification history in local database
///
/// This stores all notifications received via OneSignal for later reference,
/// notification center display, and analytics.
@collection
class PushNotification {
  /// Default constructor required by Isar
  PushNotification();

  /// Auto-incrementing ID
  Id id = Isar.autoIncrement;

  /// Unique notification ID from OneSignal
  @Index(unique: true)
  late String notificationId;

  /// Notification title
  late String title;

  /// Notification body/message
  late String body;

  /// Additional data payload from OneSignal
  /// Stored as JSON string
  String? additionalDataJson;

  /// Deep link URL to navigate when notification is tapped
  String? actionUrl;

  /// When the notification was received
  @Index()
  late DateTime receivedAt;

  /// Whether the user has read/opened this notification
  @Index()
  bool isRead = false;

  /// Type of notification for filtering and analytics
  /// Examples: 'fasting_start', 'milestone_4h', 'hydration_reminder', etc.
  @Index()
  late String type;

  /// Optional: Related fasting session ID if applicable
  String? fastingSessionId;

  /// Helper to parse additional data
  @ignore
  Map<String, dynamic> get additionalData {
    if (additionalDataJson == null || additionalDataJson!.isEmpty) {
      return {};
    }
    try {
      return Map<String, dynamic>.from(
        // Use a JSON decoder in production
        {} // Placeholder
      );
    } catch (e) {
      return {};
    }
  }

  /// Convert to JSON for Supabase sync if needed
  Map<String, dynamic> toJson() => {
        'notification_id': notificationId,
        'title': title,
        'body': body,
        'additional_data': additionalDataJson,
        'action_url': actionUrl,
        'received_at': receivedAt.toIso8601String(),
        'is_read': isRead,
        'type': type,
        'fasting_session_id': fastingSessionId,
      };

  /// Create from JSON
  factory PushNotification.fromJson(Map<String, dynamic> json) {
    return PushNotification()
      ..notificationId = json['notification_id'] as String
      ..title = json['title'] as String
      ..body = json['body'] as String
      ..additionalDataJson = json['additional_data'] as String?
      ..actionUrl = json['action_url'] as String?
      ..receivedAt = DateTime.parse(json['received_at'] as String)
      ..isRead = json['is_read'] as bool? ?? false
      ..type = json['type'] as String
      ..fastingSessionId = json['fasting_session_id'] as String?;
  }

  @override
  String toString() {
    return 'PushNotification(id: $id, notificationId: $notificationId, '
        'title: $title, type: $type, isRead: $isRead, receivedAt: $receivedAt)';
  }
}
