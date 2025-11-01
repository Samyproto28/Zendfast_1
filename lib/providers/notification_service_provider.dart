import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zendfast_1/services/local_notification_service.dart';
import 'package:zendfast_1/services/onesignal_service.dart';

/// Provider for OneSignalService singleton
final oneSignalServiceProvider = Provider<OneSignalService>((ref) {
  return OneSignalService.instance;
});

/// Provider for LocalNotificationService singleton
final localNotificationServiceProvider = Provider<LocalNotificationService>((ref) {
  return LocalNotificationService.instance;
});
