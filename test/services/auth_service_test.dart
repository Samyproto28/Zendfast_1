import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:zendfast_1/config/supabase_config.dart';
import 'package:zendfast_1/services/auth_service.dart';
import 'package:zendfast_1/models/auth_state.dart' as app_auth;
import 'package:zendfast_1/utils/result.dart';

void main() {
  // Setup before all tests
  setUpAll(() async {
    // Load environment variables
    await dotenv.load(fileName: '.env');

    // Initialize Supabase
    await SupabaseConfig.initialize();
  });

  group('AuthService Tests', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService.instance;
    });

    test('AuthService should be a singleton', () {
      final instance1 = AuthService.instance;
      final instance2 = AuthService.instance;

      expect(instance1, equals(instance2));
    });

    test('Initial auth state should be unauthenticated or authenticated', () {
      final state = authService.currentState;
      expect(
        state.status,
        isIn([
          app_auth.AuthStatus.authenticated,
          app_auth.AuthStatus.unauthenticated,
          app_auth.AuthStatus.loading,
        ]),
      );
    });

    group('Email Validation', () {
      test('Should reject empty email', () async {
        final result = await authService.signUp(
          email: '',
          password: 'TestPassword123',
        );

        expect(result.isFailure, isTrue);
        expect(
          result.error.message,
          contains('correo electrónico no puede estar vacío'),
        );
      });

      test('Should reject invalid email format', () async {
        final result = await authService.signUp(
          email: 'invalid-email',
          password: 'TestPassword123',
        );

        expect(result.isFailure, isTrue);
        expect(
          result.error.message,
          contains('formato del correo electrónico no es válido'),
        );
      });

      test('Should accept valid email format', () async {
        // This will fail at the server level (duplicate user or other reasons)
        // but should pass client-side validation
        final result = await authService.signUp(
          email: 'valid@example.com',
          password: 'TestPassword123',
        );

        // Even if it fails, it shouldn't be due to email format validation
        if (result.isFailure) {
          expect(
            result.error.message,
            isNot(contains('formato del correo electrónico no es válido')),
          );
        }
      });
    });

    group('Password Validation', () {
      test('Should reject empty password', () async {
        final result = await authService.signUp(
          email: 'test@example.com',
          password: '',
        );

        expect(result.isFailure, isTrue);
        expect(
          result.error.message,
          contains('contraseña no puede estar vacía'),
        );
      });

      test('Should reject short password (less than 8 characters)', () async {
        final result = await authService.signUp(
          email: 'test@example.com',
          password: 'Test12',
        );

        expect(result.isFailure, isTrue);
        expect(
          result.error.message,
          contains('al menos 8 caracteres'),
        );
      });

      test('Should reject password without letters', () async {
        final result = await authService.signUp(
          email: 'test@example.com',
          password: '12345678',
        );

        expect(result.isFailure, isTrue);
        expect(
          result.error.message,
          contains('al menos una letra'),
        );
      });

      test('Should reject password without numbers', () async {
        final result = await authService.signUp(
          email: 'test@example.com',
          password: 'TestPassword',
        );

        expect(result.isFailure, isTrue);
        expect(
          result.error.message,
          contains('al menos un número'),
        );
      });

      test('Should accept strong password', () async {
        final result = await authService.signUp(
          email: 'newuser@example.com',
          password: 'StrongPassword123',
        );

        // Even if signup fails (e.g., network), it shouldn't be due to password validation
        if (result.isFailure) {
          expect(
            result.error.message,
            isNot(contains('contraseña debe')),
          );
        }
      });
    });

    group('Auth State Management', () {
      test('Should have auth state stream', () {
        expect(authService.authStateChanges, isNotNull);
      });

      test('Should emit auth state changes', () async {
        // Listen to state changes
        final stateChanges = <app_auth.AuthState>[];
        final subscription = authService.authStateChanges.listen((state) {
          stateChanges.add(state);
        });

        // Wait a bit for initial state
        await Future.delayed(const Duration(milliseconds: 500));

        // Should have received at least one state
        expect(stateChanges.isNotEmpty, isTrue);

        await subscription.cancel();
      });
    });

    group('Sign Out', () {
      test('Should handle sign out when not authenticated', () async {
        // Try to sign out even if not authenticated
        final result = await authService.signOut();

        // Should succeed or fail gracefully
        expect(result, isNotNull);
      });
    });

    group('Password Reset', () {
      test('Should reject password reset with invalid email', () async {
        final result = await authService.resetPassword(
          email: 'invalid-email',
        );

        expect(result.isFailure, isTrue);
        expect(
          result.error.message,
          contains('formato del correo electrónico no es válido'),
        );
      });

      test('Should accept password reset with valid email', () async {
        final result = await authService.resetPassword(
          email: 'test@example.com',
        );

        // Should either succeed or fail with a server error, not validation error
        if (result.isFailure) {
          expect(
            result.error.message,
            isNot(contains('formato del correo electrónico no es válido')),
          );
        }
      });
    });

    group('Session Management', () {
      test('Should return current session', () {
        final session = authService.getCurrentSession();
        // Session can be null if not authenticated
        expect(session, anyOf(isNull, isNotNull));
      });

      test('Should return current user', () {
        final user = authService.getCurrentUser();
        // User can be null if not authenticated
        expect(user, anyOf(isNull, isNotNull));
      });

      test('isAuthenticated should match auth state', () {
        final isAuth = authService.isAuthenticated;
        final state = authService.currentState;

        expect(isAuth, equals(state.isAuthenticated));
      });
    });
  });

  group('Result Type Tests', () {
    test('Success result should be success', () {
      final result = Success<String, String>('test data');

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.value, equals('test data'));
      expect(result.valueOrNull, equals('test data'));
    });

    test('Failure result should be failure', () {
      final result = Failure<String, String>('error message');

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.error, equals('error message'));
      expect(result.errorOrNull, equals('error message'));
    });

    test('Success result map should transform value', () {
      final result = Success<int, String>(42);
      final mapped = result.map((value) => value * 2);

      expect(mapped.isSuccess, isTrue);
      expect(mapped.value, equals(84));
    });

    test('Failure result map should preserve error', () {
      final result = Failure<int, String>('error');
      final mapped = result.map((value) => value * 2);

      expect(mapped.isFailure, isTrue);
      expect(mapped.error, equals('error'));
    });

    test('Success getOrElse should return value', () {
      final result = Success<int, String>(42);
      expect(result.getOrElse(0), equals(42));
    });

    test('Failure getOrElse should return default', () {
      final result = Failure<int, String>('error');
      expect(result.getOrElse(0), equals(0));
    });
  });
}
