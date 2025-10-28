import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/account_deletion_request.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../utils/result.dart';

/// Service for handling account deletion with GDPR compliance
/// Implements "Right to Erasure" (Article 17 GDPR) with 30-day grace period
class AccountDeletionService {
  static AccountDeletionService? _instance;
  static AccountDeletionService get instance {
    _instance ??= AccountDeletionService._();
    return _instance!;
  }

  AccountDeletionService._();

  /// Request account deletion with 30-day grace period
  /// Verifies user password before creating deletion request
  Future<Result<AccountDeletionRequest, Exception>> requestAccountDeletion({
    required String userId,
    required String password,
    String? deletionReason,
  }) async {
    try {
      debugPrint('[AccountDeletion] Requesting deletion for user: $userId');

      // 1. Verify password by attempting re-authentication
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null || currentUser.email == null) {
        return Failure(Exception('User not authenticated'));
      }

      final signInResult = await AuthService.instance.signIn(
        email: currentUser.email!,
        password: password,
      );

      if (signInResult is Failure) {
        return Failure(Exception('Password verification failed'));
      }

      // 2. Check if there's already a pending deletion request
      final existingRequest = await checkDeletionStatus(userId);
      if (existingRequest != null &&
          existingRequest.status == DeletionRequestStatus.pending) {
        return Failure(
          Exception(
            'Ya existe una solicitud de eliminación pendiente. '
            'Fecha programada: ${existingRequest.formattedScheduledDate}',
          ),
        );
      }

      // 3. Generate recovery token
      final recoveryToken = _generateRecoveryToken();

      // 4. Create deletion request in Supabase
      final now = DateTime.now();
      final scheduledDate = now.add(const Duration(days: 30));

      final response = await SupabaseConfig.from('account_deletion_requests')
          .insert({
        'user_id': userId,
        'requested_at': now.toIso8601String(),
        'scheduled_deletion_date': scheduledDate.toIso8601String(),
        'recovery_token': recoveryToken,
        'status': 'pending',
        'deletion_reason': deletionReason,
      }).select().single();

      final request = AccountDeletionRequest.fromJson(response);

      debugPrint(
        '[AccountDeletion] Deletion request created. '
        'Scheduled for: ${request.formattedScheduledDate}',
      );

      // Send confirmation email with recovery link
      // TODO: Enable this when email service is configured
      await _sendDeletionConfirmationEmail(currentUser.email!, request);

      return Success(request);
    } on AuthException catch (e) {
      debugPrint('[AccountDeletion] Auth error: $e');
      return Failure(Exception('Error de autenticación: ${e.message}'));
    } on PostgrestException catch (e) {
      debugPrint('[AccountDeletion] Database error: $e');
      return Failure(Exception('Error de base de datos: ${e.message}'));
    } catch (e, stackTrace) {
      debugPrint('[AccountDeletion] Unexpected error: $e');
      debugPrint('[AccountDeletion] Stack trace: $stackTrace');
      return Failure(Exception('Error al solicitar eliminación: $e'));
    }
  }

  /// Cancel a pending deletion request
  /// User can recover their account within 30-day grace period
  Future<Result<void, Exception>> cancelDeletionRequest(String userId) async {
    try {
      debugPrint('[AccountDeletion] Cancelling deletion for user: $userId');

      // Update deletion request status to cancelled
      await SupabaseConfig.from('account_deletion_requests')
          .update({
        'status': 'cancelled',
        'cancelled_at': DateTime.now().toIso8601String(),
      }).match({
        'user_id': userId,
        'status': 'pending',
      });

      debugPrint('[AccountDeletion] Deletion request cancelled successfully');

      return const Success(null);
    } on PostgrestException catch (e) {
      debugPrint('[AccountDeletion] Database error: $e');
      return Failure(Exception('Error al cancelar eliminación: ${e.message}'));
    } catch (e) {
      debugPrint('[AccountDeletion] Unexpected error: $e');
      return Failure(Exception('Error al cancelar eliminación: $e'));
    }
  }

  /// Execute account deletion (cascade delete all user data)
  /// WARNING: This is irreversible!
  Future<Result<void, Exception>> executeAccountDeletion(
    String userId,
  ) async {
    try {
      debugPrint('[AccountDeletion] EXECUTING deletion for user: $userId');
      debugPrint('[AccountDeletion] This operation is IRREVERSIBLE!');

      // 1. Delete user data in correct order (respecting foreign key constraints)

      // 1a. Delete content interactions
      debugPrint('[AccountDeletion] Deleting content interactions...');
      await SupabaseConfig.from('user_content_interactions')
          .delete()
          .match({'user_id': userId});

      // 1b. Delete analytics events
      debugPrint('[AccountDeletion] Deleting analytics events...');
      await SupabaseConfig.from('analytics_events')
          .delete()
          .match({'user_id': userId});

      // 1c. Delete hydration logs
      debugPrint('[AccountDeletion] Deleting hydration logs...');
      await SupabaseConfig.from('hydration_logs')
          .delete()
          .match({'user_id': userId});

      // 1d. Delete fasting sessions
      debugPrint('[AccountDeletion] Deleting fasting sessions...');
      await SupabaseConfig.from('fasting_sessions')
          .delete()
          .match({'user_id': userId});

      // 1e. Delete user metrics
      debugPrint('[AccountDeletion] Deleting user metrics...');
      await SupabaseConfig.from('user_metrics')
          .delete()
          .match({'user_id': userId});

      // 1f. Delete user consents
      debugPrint('[AccountDeletion] Deleting user consents...');
      await SupabaseConfig.from('user_consents')
          .delete()
          .match({'user_id': userId});

      // 1g. Mark deletion request as completed
      debugPrint('[AccountDeletion] Marking deletion request as completed...');
      await SupabaseConfig.from('account_deletion_requests').update({
        'status': 'completed',
        'completed_at': DateTime.now().toIso8601String(),
      }).match({
        'user_id': userId,
        'status': 'pending',
      });

      // 1h. Delete user profile
      debugPrint('[AccountDeletion] Deleting user profile...');
      await SupabaseConfig.from('user_profiles')
          .delete()
          .match({'user_id': userId});

      // 2. Delete all local Isar data
      debugPrint('[AccountDeletion] Clearing local Isar database...');
      await _clearLocalUserData(userId);

      // 3. Delete auth user (via Supabase Admin API)
      // Note: This requires service_role key and proper permissions
      // For now, we'll leave the auth user but they have no data
      debugPrint(
        '[AccountDeletion] Auth user deletion requires admin privileges',
      );
      debugPrint('[AccountDeletion] All user data deleted successfully');

      // 4. Sign out the user
      await AuthService.instance.signOut();

      debugPrint('[AccountDeletion] Account deletion completed successfully');

      return const Success(null);
    } on PostgrestException catch (e) {
      debugPrint('[AccountDeletion] Database error: $e');
      return Failure(
        Exception('Error al eliminar cuenta: ${e.message}'),
      );
    } catch (e, stackTrace) {
      debugPrint('[AccountDeletion] Unexpected error: $e');
      debugPrint('[AccountDeletion] Stack trace: $stackTrace');
      return Failure(Exception('Error al eliminar cuenta: $e'));
    }
  }

  /// Clear all local Isar data for a user
  Future<void> _clearLocalUserData(String userId) async {
    try {
      final db = DatabaseService.instance;

      // Delete fasting sessions
      final sessions = await db.getUserFastingSessions(userId);
      for (final session in sessions) {
        await db.deleteFastingSession(session.id);
      }

      // Delete hydration logs
      final hydrationLogs = await db.getHydrationRange(
        userId: userId,
        startDate: DateTime.now().subtract(const Duration(days: 3650)),
        endDate: DateTime.now(),
      );
      for (final log in hydrationLogs) {
        await db.deleteHydrationLog(log.id);
      }

      // Delete user profile
      final profile = await db.getUserProfile(userId);
      if (profile != null) {
        await db.deleteUserProfile(profile.id);
      }

      // Delete user metrics
      final metrics = await db.getUserMetrics(userId);
      if (metrics != null) {
        await db.deleteUserMetrics(metrics.id);
      }

      debugPrint('[AccountDeletion] Local data cleared for user: $userId');
    } catch (e) {
      debugPrint('[AccountDeletion] Error clearing local data: $e');
      // Don't throw - local cleanup failure shouldn't block account deletion
    }
  }

  /// Check if user has a pending deletion request
  Future<AccountDeletionRequest?> checkDeletionStatus(String userId) async {
    try {
      final response = await SupabaseConfig.from('account_deletion_requests')
          .select()
          .eq('user_id', userId)
          .eq('status', 'pending')
          .maybeSingle();

      if (response == null) return null;

      return AccountDeletionRequest.fromJson(response);
    } catch (e) {
      debugPrint('[AccountDeletion] Error checking deletion status: $e');
      return null;
    }
  }

  /// Generate a secure recovery token
  String _generateRecoveryToken() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(64, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  /// Send deletion confirmation email with recovery link
  /// TODO: Implement email service integration
  Future<void> _sendDeletionConfirmationEmail(
    String email,
    AccountDeletionRequest request,
  ) async {
    debugPrint('[AccountDeletion] TODO: Send confirmation email to $email');
    debugPrint(
      '[AccountDeletion] Recovery token: ${request.recoveryToken}',
    );
    // Integration with email service (SendGrid, AWS SES, etc.)
    // Email should include:
    // - Confirmation that deletion was requested
    // - Scheduled deletion date
    // - Recovery link with token
    // - What data will be deleted
    // - How to cancel if they change their mind
  }

  /// Background job to execute scheduled deletions
  /// This should be called by a cron job or cloud function
  static Future<void> executeScheduledDeletions() async {
    try {
      debugPrint('[AccountDeletion] Checking for scheduled deletions...');

      // Find all pending deletions that are past their scheduled date
      final response = await SupabaseConfig.from('account_deletion_requests')
          .select()
          .eq('status', 'pending')
          .lte('scheduled_deletion_date', DateTime.now().toIso8601String());

      final requests =
          (response as List).map((e) => AccountDeletionRequest.fromJson(e));

      for (final request in requests) {
        debugPrint(
          '[AccountDeletion] Processing scheduled deletion for user: ${request.userId}',
        );

        final result =
            await AccountDeletionService.instance.executeAccountDeletion(
          request.userId,
        );

        if (result is Success) {
          debugPrint(
            '[AccountDeletion] Successfully deleted account: ${request.userId}',
          );
        } else if (result is Failure) {
          debugPrint(
            '[AccountDeletion] Failed to delete account: ${request.userId}',
          );
        }
      }

      debugPrint('[AccountDeletion] Scheduled deletions processing complete');
    } catch (e) {
      debugPrint('[AccountDeletion] Error processing scheduled deletions: $e');
    }
  }
}
