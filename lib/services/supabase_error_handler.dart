import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Base class for all Supabase-related exceptions
abstract class SupabaseException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const SupabaseException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => message;
}

/// Authentication-related errors
class SupabaseAuthException extends SupabaseException {
  const SupabaseAuthException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Database operation errors
class SupabaseDatabaseException extends SupabaseException {
  const SupabaseDatabaseException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Network/connectivity errors
class SupabaseNetworkException extends SupabaseException {
  const SupabaseNetworkException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Unknown or unexpected errors
class SupabaseUnknownException extends SupabaseException {
  const SupabaseUnknownException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Centralized error handler for Supabase operations
class SupabaseErrorHandler {
  // Private constructor
  SupabaseErrorHandler._();

  /// Handle authentication errors
  static SupabaseAuthException handleAuthError(AuthException error) {
    final message = _getAuthErrorMessage(error.message, error.statusCode);

    return SupabaseAuthException(
      message: message,
      code: error.statusCode,
      originalError: error,
    );
  }

  /// Handle database errors
  static SupabaseDatabaseException handleDatabaseError(
    PostgrestException error,
  ) {
    final message = _getDatabaseErrorMessage(error.message, error.code);

    return SupabaseDatabaseException(
      message: message,
      code: error.code,
      originalError: error,
    );
  }

  /// Handle network errors
  static SupabaseNetworkException handleNetworkError(dynamic error) {
    String message = 'Error de conexión. Verifica tu conexión a internet.';

    if (error is SocketException) {
      message =
          'No se pudo conectar al servidor. Verifica tu conexión a internet.';
    } else if (error is HttpException) {
      message = 'Error de red: ${error.message}';
    } else if (error is FormatException) {
      message = 'Error al procesar la respuesta del servidor.';
    }

    return SupabaseNetworkException(
      message: message,
      originalError: error,
    );
  }

  /// Handle unknown errors
  static SupabaseUnknownException handleUnknownError(dynamic error) {
    return SupabaseUnknownException(
      message: 'Ocurrió un error inesperado. Por favor, intenta de nuevo.',
      originalError: error,
    );
  }

  /// Retry logic with exponential backoff
  static Future<T> retryOperation<T>({
    required Future<T> Function() operation,
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    Duration delay = initialDelay;

    while (attempts < maxAttempts) {
      try {
        return await operation();
      } catch (e) {
        attempts++;

        if (attempts >= maxAttempts) {
          rethrow;
        }

        // Check if error is retryable
        if (!_isRetryableError(e)) {
          rethrow;
        }

        // Wait before retrying with exponential backoff
        await Future.delayed(delay);
        delay *= 2; // Double the delay for next retry
      }
    }

    throw SupabaseUnknownException(
      message: 'Operación fallida después de $maxAttempts intentos.',
    );
  }

  /// Get user-friendly auth error message in Spanish
  static String _getAuthErrorMessage(String originalMessage, String? code) {
    // Check for common error messages
    final lowerMessage = originalMessage.toLowerCase();

    if (lowerMessage.contains('email not confirmed') ||
        lowerMessage.contains('email confirmation')) {
      return 'Por favor, confirma tu correo electrónico antes de iniciar sesión.';
    }

    if (lowerMessage.contains('invalid login credentials') ||
        lowerMessage.contains('invalid email or password')) {
      return 'Correo electrónico o contraseña incorrectos.';
    }

    if (lowerMessage.contains('user already registered') ||
        lowerMessage.contains('user already exists')) {
      return 'Este correo electrónico ya está registrado.';
    }

    if (lowerMessage.contains('password') && lowerMessage.contains('short')) {
      return 'La contraseña debe tener al menos 8 caracteres.';
    }

    if (lowerMessage.contains('email') && lowerMessage.contains('invalid')) {
      return 'El formato del correo electrónico no es válido.';
    }

    if (lowerMessage.contains('session not found') ||
        lowerMessage.contains('not authenticated')) {
      return 'Sesión expirada. Por favor, inicia sesión nuevamente.';
    }

    if (lowerMessage.contains('otp') || lowerMessage.contains('token')) {
      return 'El código de verificación es inválido o ha expirado.';
    }

    if (lowerMessage.contains('rate limit')) {
      return 'Demasiados intentos. Por favor, espera unos minutos.';
    }

    // Default message
    return 'Error de autenticación: $originalMessage';
  }

  /// Get user-friendly database error message in Spanish
  static String _getDatabaseErrorMessage(String originalMessage, String? code) {
    final lowerMessage = originalMessage.toLowerCase();

    if (lowerMessage.contains('permission denied') ||
        lowerMessage.contains('not allowed')) {
      return 'No tienes permiso para realizar esta operación.';
    }

    if (lowerMessage.contains('foreign key') ||
        lowerMessage.contains('violates')) {
      return 'No se puede completar la operación debido a restricciones de datos.';
    }

    if (lowerMessage.contains('unique') || lowerMessage.contains('duplicate')) {
      return 'Este registro ya existe.';
    }

    if (lowerMessage.contains('not found')) {
      return 'El registro solicitado no fue encontrado.';
    }

    if (lowerMessage.contains('connection') || lowerMessage.contains('timeout')) {
      return 'Error de conexión con la base de datos. Intenta de nuevo.';
    }

    // Default message
    return 'Error de base de datos: $originalMessage';
  }

  /// Check if an error is retryable
  static bool _isRetryableError(dynamic error) {
    // Network errors are usually retryable
    if (error is SocketException ||
        error is HttpException ||
        error is SupabaseNetworkException) {
      return true;
    }

    // Some auth errors are retryable
    if (error is AuthException) {
      final message = error.message.toLowerCase();
      return message.contains('timeout') ||
          message.contains('network') ||
          message.contains('connection');
    }

    // Some database errors are retryable
    if (error is PostgrestException) {
      final message = error.message.toLowerCase();
      return message.contains('timeout') ||
          message.contains('connection') ||
          message.contains('deadlock');
    }

    return false;
  }
}
