import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../main.dart';
import '../providers/auth_computed_providers.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';

/// GoRouter configuration provider
/// Provides routing with auth-based redirects
final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      // Auth state determines redirect
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      // If user is not authenticated and not on an auth route, redirect to login
      if (!isAuthenticated && !isAuthRoute) {
        return '/auth/login';
      }

      // If user is authenticated and on an auth route, redirect to home
      if (isAuthenticated && isAuthRoute) {
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

      // Home route (protected)
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const MyHomePage(title: 'Zendfast'),
      ),
    ],
  );
});
