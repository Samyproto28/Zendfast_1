import 'package:supabase_flutter/supabase_flutter.dart';

/// Represents the current authentication state of the application
enum AuthStatus {
  /// User is authenticated with a valid session
  authenticated,

  /// User is not authenticated
  unauthenticated,

  /// Authentication state is being determined (initial load)
  loading,
}

/// Wrapper class for authentication state with user data
class AuthState {
  /// Current authentication status
  final AuthStatus status;

  /// Authenticated user (null if unauthenticated)
  final User? user;

  /// Current session (null if unauthenticated)
  final Session? session;

  /// Optional error message
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.session,
    this.errorMessage,
  });

  /// Create an authenticated state
  factory AuthState.authenticated({
    required User user,
    required Session session,
  }) {
    return AuthState(
      status: AuthStatus.authenticated,
      user: user,
      session: session,
    );
  }

  /// Create an unauthenticated state
  factory AuthState.unauthenticated({String? errorMessage}) {
    return AuthState(
      status: AuthStatus.unauthenticated,
      errorMessage: errorMessage,
    );
  }

  /// Create a loading state
  factory AuthState.loading() {
    return const AuthState(
      status: AuthStatus.loading,
    );
  }

  /// Check if user is authenticated
  bool get isAuthenticated => status == AuthStatus.authenticated;

  /// Check if authentication is in progress
  bool get isLoading => status == AuthStatus.loading;

  /// Check if user is unauthenticated
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;

  /// Get user ID (null if not authenticated)
  String? get userId => user?.id;

  /// Get user email (null if not authenticated)
  String? get userEmail => user?.email;

  @override
  String toString() {
    return 'AuthState(status: $status, user: ${user?.email}, error: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthState &&
        other.status == status &&
        other.user?.id == user?.id &&
        other.session?.accessToken == session?.accessToken &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return Object.hash(
      status,
      user?.id,
      session?.accessToken,
      errorMessage,
    );
  }

  /// Copy this AuthState with optional field updates
  AuthState copyWith({
    AuthStatus? status,
    User? user,
    Session? session,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      session: session ?? this.session,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
