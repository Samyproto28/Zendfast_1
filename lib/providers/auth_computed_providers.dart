import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_provider.dart';

/// Provider that returns whether the user is currently authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.isAuthenticated;
});

/// Provider that returns the current user (null if not authenticated)
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.user;
});

/// Provider that returns the current user ID (null if not authenticated)
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.userId;
});

/// Provider that returns the current user email (null if not authenticated)
final currentUserEmailProvider = Provider<String?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.userEmail;
});

/// Provider that returns whether auth is currently loading
final isAuthLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.isLoading;
});

/// Provider that returns the current auth error message (null if no error)
final authErrorMessageProvider = Provider<String?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.errorMessage;
});
