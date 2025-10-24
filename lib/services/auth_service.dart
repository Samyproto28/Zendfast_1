import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/auth_state.dart' as app_auth;
import '../utils/result.dart';
import 'supabase_error_handler.dart';

/// Singleton service for managing authentication with Supabase
/// Provides methods for sign up, sign in, sign out, password reset, and auth state management
class AuthService {
  static AuthService? _instance;
  static AuthService get instance {
    _instance ??= AuthService._();
    return _instance!;
  }

  // Private constructor
  AuthService._() {
    _initializeAuthStateListener();
  }

  // Stream controller for auth state changes
  final _authStateController = StreamController<app_auth.AuthState>.broadcast();

  // Current auth state
  app_auth.AuthState _currentState = app_auth.AuthState.loading();

  /// Stream of authentication state changes
  Stream<app_auth.AuthState> get authStateChanges => _authStateController.stream;

  /// Current authentication state
  app_auth.AuthState get currentState => _currentState;

  /// Check if user is currently authenticated
  bool get isAuthenticated => _currentState.isAuthenticated;

  /// Get current user (null if not authenticated)
  User? get currentUser => _currentState.user;

  /// Get current session (null if not authenticated)
  Session? get currentSession => _currentState.session;

  /// Get current user ID (null if not authenticated)
  String? get currentUserId => _currentState.userId;

  /// Initialize auth state listener
  void _initializeAuthStateListener() {
    // Listen to Supabase auth state changes
    SupabaseConfig.auth.onAuthStateChange.listen((authState) {
      final session = authState.session;

      app_auth.AuthState newState;

      if (session != null) {
        newState = app_auth.AuthState.authenticated(
          user: session.user,
          session: session,
        );
      } else {
        newState = app_auth.AuthState.unauthenticated();
      }

      _currentState = newState;
      _authStateController.add(newState);
    });

    // Set initial state
    final currentSession = SupabaseConfig.auth.currentSession;
    if (currentSession != null) {
      _currentState = app_auth.AuthState.authenticated(
        user: currentSession.user,
        session: currentSession,
      );
    } else {
      _currentState = app_auth.AuthState.unauthenticated();
    }
    _authStateController.add(_currentState);
  }

  /// Sign up a new user with email and password
  ///
  /// Returns [Result] with [AuthResponse] on success or [SupabaseAuthException] on failure
  Future<Result<AuthResponse, SupabaseAuthException>> signUp({
    required String email,
    required String password,
  }) async {
    try {
      // Validate email
      final emailValidation = _validateEmail(email);
      if (emailValidation != null) {
        return Failure(SupabaseAuthException(message: emailValidation));
      }

      // Validate password
      final passwordValidation = _validatePassword(password);
      if (passwordValidation != null) {
        return Failure(SupabaseAuthException(message: passwordValidation));
      }

      // Attempt sign up
      final response = await SupabaseConfig.auth.signUp(
        email: email.trim(),
        password: password,
      );

      return Success(response);
    } on AuthException catch (e) {
      return Failure(SupabaseErrorHandler.handleAuthError(e));
    } catch (e) {
      if (_isNetworkError(e)) {
        return Failure(
          SupabaseAuthException(
            message: 'Error de conexión. Verifica tu internet.',
            originalError: e,
          ),
        );
      }
      return Failure(
        SupabaseAuthException(
          message: 'Error al crear cuenta: ${e.toString()}',
          originalError: e,
        ),
      );
    }
  }

  /// Sign in an existing user with email and password
  ///
  /// Returns [Result] with [AuthResponse] on success or [SupabaseAuthException] on failure
  Future<Result<AuthResponse, SupabaseAuthException>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Validate email
      final emailValidation = _validateEmail(email);
      if (emailValidation != null) {
        return Failure(SupabaseAuthException(message: emailValidation));
      }

      // Attempt sign in
      final response = await SupabaseConfig.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      return Success(response);
    } on AuthException catch (e) {
      return Failure(SupabaseErrorHandler.handleAuthError(e));
    } catch (e) {
      if (_isNetworkError(e)) {
        return Failure(
          SupabaseAuthException(
            message: 'Error de conexión. Verifica tu internet.',
            originalError: e,
          ),
        );
      }
      return Failure(
        SupabaseAuthException(
          message: 'Error al iniciar sesión: ${e.toString()}',
          originalError: e,
        ),
      );
    }
  }

  /// Sign out the current user
  ///
  /// Returns [Result] with void on success or [SupabaseAuthException] on failure
  Future<Result<void, SupabaseAuthException>> signOut() async {
    try {
      await SupabaseConfig.auth.signOut();
      return const Success(null);
    } on AuthException catch (e) {
      return Failure(SupabaseErrorHandler.handleAuthError(e));
    } catch (e) {
      return Failure(
        SupabaseAuthException(
          message: 'Error al cerrar sesión: ${e.toString()}',
          originalError: e,
        ),
      );
    }
  }

  /// Send a password reset email
  ///
  /// Returns [Result] with void on success or [SupabaseAuthException] on failure
  Future<Result<void, SupabaseAuthException>> resetPassword({
    required String email,
  }) async {
    try {
      // Validate email
      final emailValidation = _validateEmail(email);
      if (emailValidation != null) {
        return Failure(SupabaseAuthException(message: emailValidation));
      }

      await SupabaseConfig.auth.resetPasswordForEmail(email.trim());

      return const Success(null);
    } on AuthException catch (e) {
      return Failure(SupabaseErrorHandler.handleAuthError(e));
    } catch (e) {
      if (_isNetworkError(e)) {
        return Failure(
          SupabaseAuthException(
            message: 'Error de conexión. Verifica tu internet.',
            originalError: e,
          ),
        );
      }
      return Failure(
        SupabaseAuthException(
          message: 'Error al enviar correo de recuperación: ${e.toString()}',
          originalError: e,
        ),
      );
    }
  }

  /// Update the user's password (must be authenticated)
  ///
  /// Returns [Result] with [UserResponse] on success or [SupabaseAuthException] on failure
  Future<Result<UserResponse, SupabaseAuthException>> updatePassword({
    required String newPassword,
  }) async {
    try {
      // Check if user is authenticated
      if (!isAuthenticated) {
        return const Failure(
          SupabaseAuthException(
            message: 'Debes iniciar sesión para cambiar la contraseña.',
          ),
        );
      }

      // Validate password
      final passwordValidation = _validatePassword(newPassword);
      if (passwordValidation != null) {
        return Failure(SupabaseAuthException(message: passwordValidation));
      }

      final response = await SupabaseConfig.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      return Success(response);
    } on AuthException catch (e) {
      return Failure(SupabaseErrorHandler.handleAuthError(e));
    } catch (e) {
      return Failure(
        SupabaseAuthException(
          message: 'Error al actualizar contraseña: ${e.toString()}',
          originalError: e,
        ),
      );
    }
  }

  /// Refresh the current session
  ///
  /// Returns [Result] with [AuthResponse] on success or [SupabaseAuthException] on failure
  Future<Result<AuthResponse, SupabaseAuthException>> refreshSession() async {
    try {
      final response = await SupabaseConfig.auth.refreshSession();
      return Success(response);
    } on AuthException catch (e) {
      return Failure(SupabaseErrorHandler.handleAuthError(e));
    } catch (e) {
      return Failure(
        SupabaseAuthException(
          message: 'Error al refrescar sesión: ${e.toString()}',
          originalError: e,
        ),
      );
    }
  }

  /// Get the current session
  ///
  /// Returns the current session or null if not authenticated
  Session? getCurrentSession() {
    return SupabaseConfig.auth.currentSession;
  }

  /// Get the current user
  ///
  /// Returns the current user or null if not authenticated
  User? getCurrentUser() {
    return SupabaseConfig.auth.currentUser;
  }

  // ============================================================================
  // Validation Methods
  // ============================================================================

  /// Validate email format
  ///
  /// Returns error message if invalid, null if valid
  String? _validateEmail(String email) {
    if (email.trim().isEmpty) {
      return 'El correo electrónico no puede estar vacío.';
    }

    // Basic email regex pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email.trim())) {
      return 'El formato del correo electrónico no es válido.';
    }

    return null;
  }

  /// Validate password strength
  ///
  /// Returns error message if invalid, null if valid
  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return 'La contraseña no puede estar vacía.';
    }

    if (password.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres.';
    }

    // Check for at least one letter
    if (!password.contains(RegExp(r'[a-zA-Z]'))) {
      return 'La contraseña debe contener al menos una letra.';
    }

    // Check for at least one number
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'La contraseña debe contener al menos un número.';
    }

    return null;
  }

  /// Check if error is network-related
  bool _isNetworkError(dynamic error) {
    return error.toString().toLowerCase().contains('network') ||
        error.toString().toLowerCase().contains('connection') ||
        error.toString().toLowerCase().contains('socket');
  }

  // ============================================================================
  // Cleanup
  // ============================================================================

  /// Dispose resources
  void dispose() {
    _authStateController.close();
  }
}