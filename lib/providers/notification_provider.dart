import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:zendfast_1/models/notification_state.dart';
import 'package:zendfast_1/models/push_notification.dart';
import 'package:zendfast_1/services/database_service.dart';
import 'package:zendfast_1/services/onesignal_service.dart';

/// Provider for notification state management
final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});

/// Notifier for managing notification state
class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier() : super(NotificationState.initial()) {
    _initialize();
  }

  StreamSubscription? _notificationSubscription;

  /// Initialize notification system
  Future<void> _initialize() async {
    try {
      // Load unread notifications from database
      await loadUnreadNotifications();

      // Listen to OneSignal notification stream
      _notificationSubscription = OneSignalService.instance.notificationStream
          .listen((notification) {
        handleIncomingNotification(notification);
      });

      // Check permission status
      final hasPermission = await OneSignalService.instance.hasPermission();

      state = state.copyWith(
        isInitialized: true,
        hasPermission: hasPermission,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to initialize notifications: $e',
      );
    }
  }

  /// Load unread notifications from database
  Future<void> loadUnreadNotifications() async {
    try {
      final isar = DatabaseService.instance.isar;

      // Get all unread notifications using index
      final query = isar.pushNotifications.where().isReadEqualTo(false);
      final unreadNotifications = await query.sortByReceivedAtDesc().findAll();

      state = state.copyWith(
        unreadNotifications: unreadNotifications,
        unreadCount: unreadNotifications.length,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to load notifications: $e',
      );
    }
  }

  /// Handle incoming notification
  void handleIncomingNotification(PushNotification notification) {
    final updatedList = [notification, ...state.unreadNotifications];

    state = state.copyWith(
      unreadNotifications: updatedList,
      unreadCount: updatedList.length,
    );
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final isar = DatabaseService.instance.isar;

      // Find notification by ID using index
      final query =
          isar.pushNotifications.where().notificationIdEqualTo(notificationId);
      final notification = await query.findFirst();

      if (notification != null) {
        notification.isRead = true;

        await isar.writeTxn(() async {
          await isar.pushNotifications.put(notification);
        });

        // Reload unread notifications
        await loadUnreadNotifications();
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to mark notification as read: $e',
      );
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final isar = DatabaseService.instance.isar;

      // Get all unread notifications
      final query = isar.pushNotifications.where().isReadEqualTo(false);
      final unreadNotifications = await query.findAll();

      await isar.writeTxn(() async {
        for (final notification in unreadNotifications) {
          notification.isRead = true;
          await isar.pushNotifications.put(notification);
        }
      });

      state = state.copyWith(
        unreadNotifications: [],
        unreadCount: 0,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to mark all as read: $e',
      );
    }
  }

  /// Request notification permission
  Future<bool> requestPermission() async {
    try {
      final granted = await OneSignalService.instance.requestPermission();

      state = state.copyWith(hasPermission: granted);

      return granted;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to request permission: $e',
      );
      return false;
    }
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }
}

/// Provider for unread notification count
final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationProvider).unreadCount;
});

/// Provider for notification permission status
final notificationPermissionProvider = Provider<bool>((ref) {
  return ref.watch(notificationProvider).hasPermission;
});
