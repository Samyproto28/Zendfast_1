import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../main.dart';
import '../providers/auth_computed_providers.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/onboarding/onboarding_coordinator.dart';
import '../screens/privacy/privacy_policy_screen.dart';
import '../screens/privacy/data_rights_screen.dart';
import '../screens/privacy/consent_management_screen.dart';
import '../services/database_service.dart';

/// GoRouter configuration provider
/// Provides routing with auth-based redirects and onboarding flow
final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
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
        path: '/home',
        name: 'home',
        builder: (context, state) => const MyHomePage(title: 'Zendfast'),
      ),

      // Privacy routes (protected)
      GoRoute(
        path: '/privacy-policy',
        name: 'privacy-policy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/data-rights',
        name: 'data-rights',
        builder: (context, state) => const DataRightsScreen(),
      ),
      GoRoute(
        path: '/consent-management',
        name: 'consent-management',
        builder: (context, state) => const ConsentManagementScreen(),
      ),
    ],
  );
});
