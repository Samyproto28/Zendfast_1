import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../models/auth_state.dart';
import '../services/auth_service.dart';
import '../services/consent_manager.dart';
import '../utils/result.dart';
import '../services/supabase_error_handler.dart';

/// Provider for AuthNotifier
/// Manages authentication state and exposes auth methods
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Auth State Notifier
/// Listens to AuthService and provides auth methods
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService = AuthService.instance;
  StreamSubscription<AuthState>? _authSubscription;

  AuthNotifier() : super(AuthState.loading()) {
    _initialize();
  }

  /// Initialize auth state listener
  void _initialize() {
    // Set initial state
    state = _authService.currentState;

    // Listen to auth state changes
    _authSubscription = _authService.authStateChanges.listen((newState) {
      state = newState;
    });
  }

  /// Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    // Set loading state
    state = AuthState.loading();

    final result = await _authService.signIn(
      email: email,
      password: password,
    );

    result.when(
      success: (response) {
        // State will be updated automatically by the auth state listener
        // No need to set state here
      },
      failure: (error) {
        state = AuthState.unauthenticated(errorMessage: error.message);
      },
    );
  }

  /// Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    // Set loading state
    state = AuthState.loading();

    final result = await _authService.signUp(
      email: email,
      password: password,
    );

    result.when(
      success: (response) async {
        // State will be updated automatically by the auth state listener

        // Initialize default consents for new user (GDPR/CCPA compliance)
        final userId = response.user?.id;
        if (userId != null) {
          debugPrint('[Auth] Initializing default consents for new user: $userId');
          final consentResult = await ConsentManager.instance
              .initializeDefaultConsents(userId);

          consentResult.when(
            success: (_) => debugPrint('[Auth] Default consents initialized successfully'),
            failure: (error) => debugPrint('[Auth] Failed to initialize consents: $error'),
          );
          // Note: We don't fail registration if consent initialization fails
          // The user can still set consents later
        }
      },
      failure: (error) {
        state = AuthState.unauthenticated(errorMessage: error.message);
      },
    );
  }

  /// Sign out the current user
  Future<void> signOut() async {
    final result = await _authService.signOut();

    result.when(
      success: (_) {
        // State will be updated automatically by the auth state listener
      },
      failure: (error) {
        // Even if sign out fails, we should probably still clear the state
        // But we can log the error
        state = AuthState.unauthenticated(errorMessage: error.message);
      },
    );
  }

  /// Send password reset email
  Future<Result<void, SupabaseAuthException>> resetPassword({
    required String email,
  }) async {
    return await _authService.resetPassword(email: email);
  }

  /// Update password (must be authenticated)
  Future<Result<UserResponse, SupabaseAuthException>> updatePassword({
    required String newPassword,
  }) async {
    return await _authService.updatePassword(newPassword: newPassword);
  }

  /// Refresh the current session
  Future<void> refreshSession() async {
    final result = await _authService.refreshSession();

    result.when(
      success: (response) {
        // State will be updated automatically by the auth state listener
      },
      failure: (error) {
        state = AuthState.unauthenticated(errorMessage: error.message);
      },
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
