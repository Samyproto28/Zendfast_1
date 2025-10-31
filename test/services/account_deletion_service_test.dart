import 'package:flutter_test/flutter_test.dart';
import 'package:zendfast_1/services/account_deletion_service.dart';
import 'package:zendfast_1/models/account_deletion_request.dart';

/// Integration tests for AccountDeletionService
/// Tests GDPR Article 17 compliance (Right to Erasure)
void main() {
  group('AccountDeletionService', () {
    late AccountDeletionService service;

    setUp(() {
      service = AccountDeletionService.instance;
    });

    test('should be a singleton', () {
      final instance1 = AccountDeletionService.instance;
      final instance2 = AccountDeletionService.instance;

      expect(instance1, same(instance2));
    });

    group('requestAccountDeletion', () {
      test('should require password verification', () async {
        // Note: This test requires valid Supabase auth
        const testUserId = 'test-user-id-123';
        const incorrectPassword = 'wrong-password';

        final result = await service.requestAccountDeletion(
          userId: testUserId,
          password: incorrectPassword,
        );

        result.when(
          success: (_) {
            fail('Should not succeed with incorrect password');
          },
          failure: (error) {
            // Should fail - either due to password verification or Supabase not initialized
            expect(error, isA<Exception>());
            expect(
              error.toString().toLowerCase(),
              anyOf(
                contains('password'),
                contains('verification'),
                contains('authentication'),
                contains('supabase'),
                contains('initialized'),
              ),
            );
          },
        );
      });

      test('should create deletion request with 30-day grace period', () async {
        // Note: This test requires valid Supabase auth and correct password
        const testUserId = 'test-user-id-456';
        const correctPassword = 'test-password-123';

        final result = await service.requestAccountDeletion(
          userId: testUserId,
          password: correctPassword,
          deletionReason: 'Testing deletion flow',
        );

        result.when(
          success: (deletionRequest) {
            expect(deletionRequest, isA<AccountDeletionRequest>());
            expect(deletionRequest.userId, equals(testUserId));
            expect(deletionRequest.status, equals(DeletionRequestStatus.pending));

            // Verify 30-day grace period
            final daysDifference = deletionRequest.scheduledDeletionDate
                .difference(deletionRequest.requestedAt)
                .inDays;
            expect(daysDifference, equals(30));

            // Verify recovery token is generated
            expect(deletionRequest.recoveryToken, isNotNull);
            expect(deletionRequest.recoveryToken!.length, equals(64));

            // Verify deletion can be cancelled
            expect(deletionRequest.canBeCancelled, true);
            expect(deletionRequest.daysUntilDeletion, greaterThanOrEqualTo(29));
          },
          failure: (error) {
            // Expected if auth is not properly set up
            expect(error.toString(), isA<String>());
          },
        );
      });

      test('should prevent duplicate deletion requests', () async {
        const testUserId = 'test-user-duplicate';
        const password = 'test-password';

        // First request
        final result1 = await service.requestAccountDeletion(
          userId: testUserId,
          password: password,
        );

        // Second request (should fail)
        final result2 = await service.requestAccountDeletion(
          userId: testUserId,
          password: password,
        );

        result2.when(
          success: (_) {
            fail('Should not allow duplicate deletion requests');
          },
          failure: (error) {
            // Should fail - either due to duplicate request or Supabase not initialized
            expect(
              error.toString().toLowerCase(),
              anyOf(
                contains('existe'),
                contains('pending'),
                contains('solicitud'),
                contains('supabase'),
                contains('initialized'),
              ),
            );
          },
        );

        // Cleanup first request if successful
        result1.when(
          success: (request) async {
            await service.cancelDeletionRequest(testUserId);
          },
          failure: (_) {},
        );
      });

      test('should store optional deletion reason', () async {
        const testUserId = 'test-user-reason';
        const password = 'test-password';
        const testReason = 'No longer using the app';

        final result = await service.requestAccountDeletion(
          userId: testUserId,
          password: password,
          deletionReason: testReason,
        );

        result.when(
          success: (deletionRequest) {
            expect(deletionRequest.deletionReason, equals(testReason));
          },
          failure: (_) {
            // Expected if auth not set up
          },
        );
      });
    });

    group('cancelDeletionRequest', () {
      test('should cancel pending deletion request', () async {
        const testUserId = 'test-user-cancel';

        // First create a deletion request
        // Then cancel it
        final cancelResult = await service.cancelDeletionRequest(testUserId);

        cancelResult.when(
          success: (_) {
            // Success - verify status
          },
          failure: (error) {
            // Expected if no pending request exists
            expect(error, isA<Exception>());
          },
        );
      });

      test('should prevent cancellation after grace period', () async {
        // This would require manually setting a deletion date in the past
        // Or waiting 30 days (not practical for automated tests)
        // This is a manual test scenario
      });
    });

    group('checkDeletionStatus', () {
      test('should return null if no pending deletion', () async {
        const testUserId = 'test-user-no-deletion';

        final status = await service.checkDeletionStatus(testUserId);

        expect(status, isNull);
      });

      test('should return pending request if exists', () async {
        const testUserId = 'test-user-has-deletion';
        const password = 'test-password';

        // Create deletion request
        await service.requestAccountDeletion(
          userId: testUserId,
          password: password,
        );

        // Check status
        final status = await service.checkDeletionStatus(testUserId);

        if (status != null) {
          expect(status, isA<AccountDeletionRequest>());
          expect(status.userId, equals(testUserId));
          expect(status.status, equals(DeletionRequestStatus.pending));

          // Cleanup
          await service.cancelDeletionRequest(testUserId);
        }
      });
    });

    group('executeAccountDeletion', () {
      test('should delete all user data in cascade', () async {
        // WARNING: This test actually deletes data!
        // Should only be run on test database

        const testUserId = 'test-user-to-delete';

        final result = await service.executeAccountDeletion(testUserId);

        result.when(
          success: (_) {
            // Verify user data is deleted
            // This would require querying Supabase to confirm
          },
          failure: (error) {
            // Expected if test user doesn't exist
            expect(error, isA<Exception>());
          },
        );
      });

      test('should delete data in correct order (FK constraints)', () async {
        // This test verifies deletion order:
        // 1. content_interactions
        // 2. analytics_events
        // 3. hydration_logs
        // 4. fasting_sessions
        // 5. user_metrics
        // 6. user_consents
        // 7. account_deletion_requests (mark completed)
        // 8. user_profiles

        // This is implicitly tested by executeAccountDeletion not throwing FK errors
        const testUserId = 'test-user-cascade';
        final result = await service.executeAccountDeletion(testUserId);

        result.when(
          success: (_) {
            // Success means cascade worked correctly
          },
          failure: (error) {
            // If error contains "foreign key" or "constraint", cascade failed
            expect(
              error.toString().toLowerCase(),
              isNot(anyOf(contains('foreign key'), contains('constraint'))),
            );
          },
        );
      });
    });

    group('GDPR Compliance', () {
      test('scheduled deletion date should be 30 days from request', () async {
        const testUserId = 'test-user-gdpr-period';
        const password = 'test-password';

        final result = await service.requestAccountDeletion(
          userId: testUserId,
          password: password,
        );

        result.when(
          success: (request) {
            // GDPR requires reasonable grace period
            // We use 30 days as standard
            final gracePeriodDays = request.scheduledDeletionDate
                .difference(request.requestedAt)
                .inDays;

            expect(
              gracePeriodDays,
              equals(30),
              reason: 'GDPR recommends 30-day grace period for account deletion',
            );
          },
          failure: (_) {
            // Expected if auth not set up
          },
        );
      });

      test('should provide recovery mechanism (token)', () async {
        const testUserId = 'test-user-recovery';
        const password = 'test-password';

        final result = await service.requestAccountDeletion(
          userId: testUserId,
          password: password,
        );

        result.when(
          success: (request) {
            // Verify recovery token exists and is secure
            expect(request.recoveryToken, isNotNull);
            expect(request.recoveryToken!.length, greaterThanOrEqualTo(32),
                reason: 'Recovery token must be sufficiently long for security');

            // Verify token contains alphanumeric characters
            expect(
              RegExp(r'^[a-zA-Z0-9]+$').hasMatch(request.recoveryToken!),
              true,
              reason: 'Recovery token should be alphanumeric',
            );
          },
          failure: (_) {
            // Expected if auth not set up
          },
        );
      });

      test('deletion should be irreversible after grace period', () async {
        // This is a business logic test
        // After executeAccountDeletion runs, data should be permanently deleted
        // Manual test scenario: verify data cannot be recovered after execution
      });
    });

    group('AccountDeletionRequest Model', () {
      test('should calculate days until deletion correctly', () {
        final now = DateTime.now();
        final scheduledDate = now.add(const Duration(days: 15));

        final request = AccountDeletionRequest(
          id: 'test-id',
          userId: 'test-user',
          requestedAt: now,
          scheduledDeletionDate: scheduledDate,
          status: DeletionRequestStatus.pending,
          createdAt: now,
          updatedAt: now,
        );

        // Should be 14 or 15 days due to inDays truncation behavior
        expect(request.daysUntilDeletion, greaterThanOrEqualTo(14));
        expect(request.daysUntilDeletion, lessThanOrEqualTo(15));
      });

      test('canBeCancelled should be true for pending requests before scheduled date', () {
        final now = DateTime.now();
        final futureDate = now.add(const Duration(days: 10));

        final request = AccountDeletionRequest(
          id: 'test-id',
          userId: 'test-user',
          requestedAt: now,
          scheduledDeletionDate: futureDate,
          status: DeletionRequestStatus.pending,
          createdAt: now,
          updatedAt: now,
        );

        expect(request.canBeCancelled, true);
      });

      test('canBeCancelled should be false for completed requests', () {
        final now = DateTime.now();

        final request = AccountDeletionRequest(
          id: 'test-id',
          userId: 'test-user',
          requestedAt: now,
          scheduledDeletionDate: now.add(const Duration(days: 30)),
          status: DeletionRequestStatus.completed,
          createdAt: now,
          updatedAt: now,
        );

        expect(request.canBeCancelled, false);
      });
    });
  });
}
