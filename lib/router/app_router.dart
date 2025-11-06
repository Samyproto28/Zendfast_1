import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_computed_providers.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/onboarding/onboarding_coordinator.dart';
import '../screens/privacy/privacy_policy_screen.dart';
import '../screens/privacy/data_rights_screen.dart';
import '../screens/privacy/consent_management_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/fasting/fasting_screen.dart';
import '../screens/fasting/fasting_start_screen.dart';
import '../screens/fasting/fasting_progress_screen.dart';
import '../screens/hydration/hydration_screen.dart';
import '../screens/learning/learning_screen.dart';
import '../screens/learning/article_detail_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../services/database_service.dart';
import 'route_constants.dart';

/// GoRouter configuration provider
/// Provides routing with auth-based redirects and onboarding flow
final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              '404',
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Page not found',
              style: TextStyle(
                fontSize: 24,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go(Routes.home),
              icon: const Icon(Icons.home),
              label: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
    redirect: (BuildContext context, GoRouterState state) async {
      // Auth state determines redirect
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      final isOnboardingRoute = state.matchedLocation.startsWith('/onboarding');

      // If user is not authenticated and not on an auth route, redirect to login
      if (!isAuthenticated && !isAuthRoute) {
        return '/auth/login';
      }

      // If user is authenticated, check onboarding status
      if (isAuthenticated && !isAuthRoute && !isOnboardingRoute) {
        final userId = authState.user?.id;
        if (userId != null) {
          // Check if user has completed onboarding
          final profile = await DatabaseService.instance.getUserProfile(userId);
          final hasCompletedOnboarding = profile?.hasCompletedOnboarding ?? false;

          // If not completed onboarding, redirect to onboarding
          if (!hasCompletedOnboarding) {
            return '/onboarding';
          }
        }
      }

      // If user is authenticated and on an auth route, redirect to home or onboarding
      if (isAuthenticated && isAuthRoute) {
        final userId = authState.user?.id;
        if (userId != null) {
          final profile = await DatabaseService.instance.getUserProfile(userId);
          final hasCompletedOnboarding = profile?.hasCompletedOnboarding ?? false;

          // Redirect to onboarding if not completed, otherwise home
          return hasCompletedOnboarding ? '/home' : '/onboarding';
        }
        return '/home';
      }

      // No redirect needed
      return null;
    },
    routes: [
      // Root route - redirects based on auth state
      GoRoute(
        path: '/',
        redirect: (context, state) => null, // Handled by global redirect
      ),

      // Auth routes
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Onboarding route (protected - requires authentication)
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingCoordinator(),
      ),

      // Home route (protected)
      GoRoute(
        path: Routes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // Fasting routes (protected)
      GoRoute(
        path: Routes.fasting,
        name: 'fasting',
        builder: (context, state) => const FastingScreen(),
        routes: [
          GoRoute(
            path: 'start',
            name: 'fasting-start',
            builder: (context, state) => const FastingStartScreen(),
          ),
          GoRoute(
            path: 'progress',
            name: 'fasting-progress',
            builder: (context, state) => const FastingProgressScreen(),
          ),
        ],
      ),

      // Hydration route (protected)
      GoRoute(
        path: Routes.hydration,
        name: 'hydration',
        builder: (context, state) => const HydrationScreen(),
      ),

      // Learning routes (protected)
      GoRoute(
        path: Routes.learning,
        name: 'learning',
        builder: (context, state) => const LearningScreen(),
        routes: [
          GoRoute(
            path: 'articles/:id',
            name: 'learning-article',
            builder: (context, state) => ArticleDetailScreen.fromState(state),
          ),
        ],
      ),

      // Profile route (protected)
      GoRoute(
        path: Routes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // Settings route (protected)
      GoRoute(
        path: Routes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // Privacy routes (protected)
      GoRoute(
        path: Routes.privacyPolicy,
        name: 'privacy-policy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: Routes.dataRights,
        name: 'data-rights',
        builder: (context, state) => const DataRightsScreen(),
      ),
      GoRoute(
        path: Routes.consentManagement,
        name: 'consent-management',
        builder: (context, state) => const ConsentManagementScreen(),
      ),

      // Notification route (protected)
      // For deep linking from push notifications
      GoRoute(
        path: '/notification/:id',
        name: 'notification-detail',
        builder: (context, state) {
          // Redirect to home for now - notification details can be shown as modal
          return const HomeScreen();
        },
      ),
    ],
  );
});
