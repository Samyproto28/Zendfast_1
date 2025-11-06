import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart';
import 'package:uni_links/uni_links.dart';
import 'theme/theme.dart';
import 'services/database_service.dart';
import 'services/timer_service.dart';
import 'services/onesignal_service.dart';
import 'services/local_notification_service.dart';
import 'config/supabase_config.dart';
import 'router/app_router.dart';

void main() async {
  // Ensure Flutter binding is initialized before async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: '.env');

  // Initialize Supabase with credentials from environment
  await SupabaseConfig.initialize();

  // Initialize Isar database for local storage
  await DatabaseService.instance.initialize();

  // Initialize background timer service for persistent fasting timer
  await TimerService.instance.initialize();

  // Initialize push notification services
  // OneSignal for remote push notifications (requires Firebase/APNs configuration)
  await OneSignalService.instance.initialize();

  // Local notifications as fallback (works without external services)
  await LocalNotificationService.instance.initialize();

  // Initialize Superwall SDK with API Key
  Superwall.configure('pk_We8ksAmppDXeDDD5AWOvg');

  // Set up deep link listener for Superwall and notifications
  _handleIncomingLinks();

  runApp(const ProviderScope(child: ZendfastApp()));
}

// Handle incoming deep links for Superwall and notifications
void _handleIncomingLinks() {
  // Handle deep links when app is already running
  uriLinkStream.listen((Uri? uri) {
    if (uri != null) {
      final uriString = uri.toString();
      debugPrint('Deep link received: $uriString');

      // Check if it's a Superwall deep link
      if (uriString.contains('superwall')) {
        Superwall.shared.handleDeepLink(uri);
      } else {
        // Handle other deep links (notifications, etc.)
        // Note: Deep linking navigation will be handled by DeepLinkHandler
        // when router is available (in ZendfastApp context)
        debugPrint('Non-Superwall deep link: $uriString');
      }
    }
  }, onError: (Object err) {
    debugPrint('Error receiving incoming link: $err');
  });
}

class ZendfastApp extends ConsumerWidget {
  const ZendfastApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Zendfast',
      debugShowCheckedModeBanner: false,
      theme: ZendfastTheme.light(),
      darkTheme: ZendfastTheme.dark(),
      themeMode: ThemeMode.system, // Follows system theme preference
      routerConfig: router,
    );
  }
}
