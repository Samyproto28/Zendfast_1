/// Mock Supabase implementation for E2E testing
/// Provides deterministic responses for authentication, database, and storage operations
library;

import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Mock Supabase client
class MockSupabaseClient extends Mock implements SupabaseClient {}

/// Mock GoTrue (Auth) client
class MockGoTrueClient extends Mock implements GoTrueClient {}

/// Mock Database query builder
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

/// Mock PostgrestFilterBuilder for query filtering
class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder {}

/// Mock Storage client
class MockSupabaseStorageClient extends Mock implements SupabaseStorageClient {}

/// Mock Realtime client
class MockRealtimeClient extends Mock implements RealtimeClient {}

/// Mock Functions client
class MockFunctionsClient extends Mock implements FunctionsClient {}

/// Mock Auth response
class MockAuthResponse extends Mock implements AuthResponse {}

/// Mock User
class MockUser extends Mock implements User {}

/// Mock Session
class MockSession extends Mock implements Session {}

/// Helper class to setup common mock responses
class SupabaseMocks {
  final MockSupabaseClient client;
  final MockGoTrueClient auth;
  final Map<String, MockSupabaseQueryBuilder> queryBuilders = {};

  SupabaseMocks()
      : client = MockSupabaseClient(),
        auth = MockGoTrueClient() {
    // Setup basic client structure
    when(() => client.auth).thenReturn(auth);
  }

  /// Setup successful auth sign in
  void setupSuccessfulSignIn({
    String userId = 'test-user-id',
    String email = 'test@zendfast.com',
  }) {
    final user = MockUser();
    final session = MockSession();
    final authResponse = MockAuthResponse();

    when(() => user.id).thenReturn(userId);
    when(() => user.email).thenReturn(email);
    when(() => session.user).thenReturn(user);
    when(() => authResponse.user).thenReturn(user);
    when(() => authResponse.session).thenReturn(session);

    when(
      () => auth.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => authResponse);

    when(() => auth.currentUser).thenReturn(user);
    when(() => auth.currentSession).thenReturn(session);
  }

  /// Setup successful auth sign up
  void setupSuccessfulSignUp({
    String userId = 'test-user-id',
    String email = 'test@zendfast.com',
  }) {
    final user = MockUser();
    final session = MockSession();
    final authResponse = MockAuthResponse();

    when(() => user.id).thenReturn(userId);
    when(() => user.email).thenReturn(email);
    when(() => session.user).thenReturn(user);
    when(() => authResponse.user).thenReturn(user);
    when(() => authResponse.session).thenReturn(session);

    when(
      () => auth.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => authResponse);
  }

  /// Setup auth sign out
  void setupSignOut() {
    when(() => auth.signOut()).thenAnswer((_) async => {});
  }

  /// Setup failed auth (wrong credentials)
  void setupFailedAuth() {
    when(
      () => auth.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(
      AuthException('Invalid login credentials'),
    );
  }

  /// Setup offline auth (network error)
  void setupOfflineAuth() {
    when(
      () => auth.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(
      Exception('Network error: Unable to reach server'),
    );
  }

  /// Setup database query for a table
  MockSupabaseQueryBuilder setupTable(String table) {
    if (!queryBuilders.containsKey(table)) {
      queryBuilders[table] = MockSupabaseQueryBuilder();
    }

    final builder = queryBuilders[table]!;
    when(() => client.from(table)).thenReturn(builder);

    return builder;
  }

  // Note: Complex Supabase query builder mocking removed
  // The builder pattern used by Supabase (select/insert/upsert/update/delete)
  // returns builder objects, not Futures, making mocking complex.
  // For E2E tests that need Supabase mocking, implement specific mocks
  // as needed for each test case.

  /// Setup table builder (basic setup)
  /// Returns a mock query builder for the specified table
  /// Actual query methods should be mocked in individual tests as needed
  MockSupabaseQueryBuilder getTableBuilder(String table) {
    return setupTable(table);
  }

  /// Verify auth sign in was called
  void verifySignInCalled({int times = 1}) {
    verify(
      () => auth.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).called(times);
  }

  // Note: Database query verification methods removed
  // Implement specific verifications in individual tests as needed

  /// Reset all mocks
  void reset() {
    resetMocktailState();
  }
}

/// Preset mock configurations for common test scenarios
class MockScenarios {
  /// Authenticated user (basic setup)
  static SupabaseMocks authenticatedUser() {
    final mocks = SupabaseMocks();
    mocks.setupSuccessfulSignIn();
    return mocks;
  }

  /// User with active fasting session (basic setup)
  /// Note: Additional query mocking should be done in individual tests
  static SupabaseMocks userWithActiveFast() {
    final mocks = SupabaseMocks();
    mocks.setupSuccessfulSignIn();
    // Additional table setup can be done by tests using getTableBuilder()
    return mocks;
  }

  /// User with metrics history (basic setup)
  /// Note: Additional query mocking should be done in individual tests
  static SupabaseMocks userWithMetrics() {
    final mocks = SupabaseMocks();
    mocks.setupSuccessfulSignIn();
    // Additional table setup can be done by tests using getTableBuilder()
    return mocks;
  }

  /// Offline scenario (all network calls fail)
  static SupabaseMocks offline() {
    final mocks = SupabaseMocks();
    mocks.setupOfflineAuth();
    // Additional error setup can be done by tests using getTableBuilder()
    return mocks;
  }

  /// Failed authentication
  static SupabaseMocks failedAuth() {
    final mocks = SupabaseMocks();
    mocks.setupFailedAuth();
    return mocks;
  }
}
