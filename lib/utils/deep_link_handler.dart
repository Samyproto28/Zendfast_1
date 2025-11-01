import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

/// Central handler for all deep links in the app
///
/// Handles deep links from:
/// - OneSignal push notifications
/// - Superwall paywalls
/// - External links (email, SMS, etc.)
///
/// Deep link scheme: zendfast://
///
/// Supported paths:
/// - zendfast://home -> Navigate to home screen
/// - zendfast://fasting/view -> View current fasting session
/// - zendfast://fasting/start -> Start new fasting session
/// - zendfast://fasting/complete -> Fasting completion screen
/// - zendfast://hydration -> Navigate to hydration screen
/// - zendfast://notification/:id -> View specific notification
/// - zendfast://settings -> Navigate to settings
class DeepLinkHandler {
  /// Handle deep link navigation
  ///
  /// Parses the URL and navigates to the appropriate screen using GoRouter.
  ///
  /// Returns true if the link was handled, false otherwise.
  static bool handleDeepLink(String? url, GoRouter router) {
    if (url == null || url.isEmpty) {
      debugPrint('⚠️ Empty deep link URL');
      return false;
    }

    try {
      final uri = Uri.parse(url);
      debugPrint('🔗 Handling deep link: $url');
      debugPrint('   Scheme: ${uri.scheme}');
      debugPrint('   Host: ${uri.host}');
      debugPrint('   Path: ${uri.path}');
      debugPrint('   Query: ${uri.queryParameters}');

      // Only handle zendfast:// scheme
      if (uri.scheme != 'zendfast') {
        debugPrint('⚠️ Unknown scheme: ${uri.scheme}');
        return false;
      }

      // Parse path and navigate
      return _navigateToPath(uri, router);
    } catch (e) {
      debugPrint('❌ Error parsing deep link: $e');
      return false;
    }
  }

  /// Navigate based on parsed URI
  static bool _navigateToPath(Uri uri, GoRouter router) {
    // Combine host and path for routing
    // zendfast://fasting/view -> host: fasting, path: /view
    // zendfast://home -> host: home, path: /
    final fullPath = uri.host + uri.path;

    switch (fullPath) {
      case 'home':
      case 'home/':
        router.go('/home');
        return true;

      case 'fasting/view':
        router.go('/home'); // Navigate to home where fasting view is
        return true;

      case 'fasting/start':
        router.go('/home'); // Navigate to home and trigger start action
        // TODO: Add query parameter or state to trigger start action
        return true;

      case 'fasting/complete':
        router.go('/home'); // Navigate to home with completion view
        // TODO: Add query parameter to show completion screen
        return true;

      case 'hydration':
      case 'hydration/':
        // TODO: Implement hydration screen route
        router.go('/home');
        debugPrint('ℹ️ Hydration screen not yet implemented, navigating to home');
        return true;

      case 'settings':
      case 'settings/':
        router.go('/settings');
        return true;

      default:
        // Check if it's a notification detail link
        if (fullPath.startsWith('notification/')) {
          final notificationId = fullPath.replaceFirst('notification/', '');
          router.go('/notification/$notificationId');
          return true;
        }

        debugPrint('⚠️ Unknown deep link path: $fullPath');
        // Navigate to home as fallback
        router.go('/home');
        return true;
    }
  }

  /// Handle notification deep link specifically
  ///
  /// This is a convenience method for notification-specific deep links.
  static void handleNotificationDeepLink(String? url, GoRouter router) {
    if (url == null || url.isEmpty) return;

    // If it's already a full URL with scheme, handle normally
    if (url.contains('://')) {
      handleDeepLink(url, router);
      return;
    }

    // If it's a path-only URL (e.g., "fasting/view"), convert to full URL
    final fullUrl = 'zendfast://$url';
    handleDeepLink(fullUrl, router);
  }

  /// Parse notification payload and navigate
  ///
  /// Handles the payload from local notifications
  static void handleNotificationPayload(String? payload, GoRouter router) {
    if (payload == null || payload.isEmpty) {
      debugPrint('⚠️ Empty notification payload');
      return;
    }

    debugPrint('📱 Handling notification payload: $payload');

    // Payload format is just the path (e.g., "fasting/view")
    handleNotificationDeepLink(payload, router);
  }
}
