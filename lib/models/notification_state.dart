import 'package:zendfast_1/models/push_notification.dart';

/// State model for notification management in Riverpod
///
/// Tracks unread notifications, permission status, and initialization state.
class NotificationState {
  final List<PushNotification> unreadNotifications;
  final int unreadCount;
  final bool isInitialized;
  final bool hasPermission;
  final String? errorMessage;

  const NotificationState({
    this.unreadNotifications = const [],
    this.unreadCount = 0,
    this.isInitialized = false,
    this.hasPermission = false,
    this.errorMessage,
  });

  /// Create initial state
  factory NotificationState.initial() => const NotificationState();

  /// Copy with modifications
  NotificationState copyWith({
    List<PushNotification>? unreadNotifications,
    int? unreadCount,
    bool? isInitialized,
    bool? hasPermission,
    String? errorMessage,
  }) {
    return NotificationState(
      unreadNotifications: unreadNotifications ?? this.unreadNotifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isInitialized: isInitialized ?? this.isInitialized,
      hasPermission: hasPermission ?? this.hasPermission,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() {
    return 'NotificationState(unreadCount: $unreadCount, '
        'isInitialized: $isInitialized, hasPermission: $hasPermission, '
        'error: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationState &&
        other.unreadCount == unreadCount &&
        other.isInitialized == isInitialized &&
        other.hasPermission == hasPermission &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return unreadCount.hashCode ^
        isInitialized.hashCode ^
        hasPermission.hashCode ^
        errorMessage.hashCode;
  }
}
