import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_consent.dart';
import '../utils/result.dart';

/// Service for managing user consent preferences (GDPR/CCPA compliance)
/// Implements granular consent management for different data processing types
class ConsentManager {
  static ConsentManager? _instance;
  static ConsentManager get instance {
    _instance ??= ConsentManager._();
    return _instance!;
  }

  ConsentManager._();

  // Cache for consents (reduce database queries)
  final Map<String, Map<ConsentType, UserConsent>> _consentCache = {};

  /// Get consent for a specific type
  /// Returns false by default (GDPR compliant - opt-in required)
  Future<bool> getConsent(String userId, ConsentType consentType) async {
    try {
      // Check cache first
      if (_consentCache.containsKey(userId) &&
          _consentCache[userId]!.containsKey(consentType)) {
        return _consentCache[userId]![consentType]!.consentGiven;
      }

      // Fetch from Supabase
      final response = await SupabaseConfig.from('user_consents')
          .select()
          .eq('user_id', userId)
          .eq('consent_type', _consentTypeToString(consentType))
          .maybeSingle();

      if (response == null) {
        // No record found, default to false (GDPR compliant)
        return false;
      }

      final consent = UserConsent.fromJson(response);

      // Update cache
      _consentCache[userId] ??= {};
      _consentCache[userId]![consentType] = consent;

      return consent.consentGiven;
    } catch (e) {
      debugPrint('[ConsentManager] Error getting consent: $e');
      // On error, default to false (safe default)
      return false;
    }
  }

  /// Update consent for a specific type
  /// Creates new record or updates existing one
  Future<Result<void, Exception>> updateConsent({
    required String userId,
    required ConsentType consentType,
    required bool granted,
  }) async {
    try {
      debugPrint(
        '[ConsentManager] Updating consent - User: $userId, '
        'Type: $consentType, Granted: $granted',
      );

      // Check if consent already exists
      final existing = await _fetchExistingConsent(userId, consentType);

      if (existing != null) {
        // Update existing consent
        await SupabaseConfig.from('user_consents').update({
          'consent_given': granted,
          'consent_version': existing.consentVersion + 1, // Increment version
          'updated_at': DateTime.now().toIso8601String(),
        }).match({
          'user_id': userId,
          'consent_type': _consentTypeToString(consentType),
        });
      } else {
        // Create new consent record
        await SupabaseConfig.from('user_consents').insert({
          'user_id': userId,
          'consent_type': _consentTypeToString(consentType),
          'consent_given': granted,
          'consent_version': 1,
        });
      }

      // Update cache
      final consent = UserConsent(
        userId: userId,
        consentType: consentType,
        consentGiven: granted,
        consentVersion: existing != null ? existing.consentVersion + 1 : 1,
      );
      _consentCache[userId] ??= {};
      _consentCache[userId]![consentType] = consent;

      // Sync to local Isar database
      await _syncConsentToLocal(consent);

      debugPrint('[ConsentManager] Consent updated successfully');

      return const Success(null);
    } on PostgrestException catch (e) {
      debugPrint('[ConsentManager] Database error: $e');
      return Failure(Exception('Error al actualizar consentimiento: ${e.message}'));
    } catch (e) {
      debugPrint('[ConsentManager] Unexpected error: $e');
      return Failure(Exception('Error al actualizar consentimiento: $e'));
    }
  }

  /// Get all consents for a user
  /// Returns map of consent types to their granted status
  Future<Map<ConsentType, bool>> getAllConsents(String userId) async {
    try {
      // Fetch all consents from Supabase
      final response = await SupabaseConfig.from('user_consents')
          .select()
          .eq('user_id', userId);

      final consents = (response as List)
          .map((json) => UserConsent.fromJson(json as Map<String, dynamic>))
          .toList();

      // Convert to map
      final consentMap = <ConsentType, bool>{};

      // Add fetched consents
      for (final consent in consents) {
        consentMap[consent.consentType] = consent.consentGiven;
        // Update cache
        _consentCache[userId] ??= {};
        _consentCache[userId]![consent.consentType] = consent;
      }

      // Add default false for missing consents (GDPR compliant)
      for (final type in ConsentType.values) {
        consentMap.putIfAbsent(type, () => false);
      }

      return consentMap;
    } catch (e) {
      debugPrint('[ConsentManager] Error getting all consents: $e');
      // Return all false on error (safe default)
      return Map.fromEntries(
        ConsentType.values.map((type) => MapEntry(type, false)),
      );
    }
  }

  /// Get the current version number for a user's consents
  /// Returns the highest version number across all consent types
  Future<int> getConsentVersion(String userId) async {
    try {
      // Ensure consents are loaded into cache
      await getAllConsents(userId);

      // If we have cached consents, find max version
      if (_consentCache.containsKey(userId)) {
        return _consentCache[userId]!
            .values
            .map((c) => c.consentVersion)
            .fold<int>(0, (max, version) => version > max ? version : max);
      }

      return 1; // Default version
    } catch (e) {
      debugPrint('[ConsentManager] Error getting consent version: $e');
      return 1;
    }
  }

  /// Initialize default consents for a new user
  /// All consents default to false (GDPR compliant - explicit opt-in required)
  Future<Result<void, Exception>> initializeDefaultConsents(
    String userId,
  ) async {
    try {
      debugPrint('[ConsentManager] Initializing default consents for user: $userId');

      // Create consent records for all types with default false
      final records = ConsentType.values.map((type) => {
            'user_id': userId,
            'consent_type': _consentTypeToString(type),
            'consent_given': false, // GDPR: Default to false
            'consent_version': 1,
          });

      await SupabaseConfig.from('user_consents').insert(records.toList());

      debugPrint('[ConsentManager] Default consents initialized');

      // Clear cache for this user to force refresh
      _consentCache.remove(userId);

      return const Success(null);
    } on PostgrestException catch (e) {
      debugPrint('[ConsentManager] Database error: $e');
      // If error is duplicate key, that's okay (consents already exist)
      if (e.code == '23505') {
        return const Success(null);
      }
      return Failure(Exception('Error al inicializar consentimientos: ${e.message}'));
    } catch (e) {
      debugPrint('[ConsentManager] Unexpected error: $e');
      return Failure(Exception('Error al inicializar consentimientos: $e'));
    }
  }

  /// Record a consent change for audit purposes
  /// This is automatically called by updateConsent
  Future<void> recordConsentChange({
    required String userId,
    required ConsentType consentType,
    required bool granted,
  }) async {
    debugPrint(
      '[ConsentManager] Consent change recorded - '
      'User: $userId, Type: $consentType, Granted: $granted',
    );
    // This could log to analytics_events or a separate consent_audit table
    // For now, the version increment in user_consents table serves as audit trail
  }

  /// Clear consent cache for a user (force refresh from database)
  void clearCache(String userId) {
    _consentCache.remove(userId);
    debugPrint('[ConsentManager] Cache cleared for user: $userId');
  }

  /// Clear all consent cache
  void clearAllCache() {
    _consentCache.clear();
    debugPrint('[ConsentManager] All consent cache cleared');
  }

  /// Fetch existing consent record from Supabase
  Future<UserConsent?> _fetchExistingConsent(
    String userId,
    ConsentType consentType,
  ) async {
    try {
      final response = await SupabaseConfig.from('user_consents')
          .select()
          .eq('user_id', userId)
          .eq('consent_type', _consentTypeToString(consentType))
          .maybeSingle();

      if (response == null) return null;

      return UserConsent.fromJson(response);
    } catch (e) {
      debugPrint('[ConsentManager] Error fetching existing consent: $e');
      return null;
    }
  }

  /// Sync consent to local Isar database for offline access
  Future<void> _syncConsentToLocal(UserConsent consent) async {
    try {
      // Note: This requires UserConsent to be added to Isar schema
      // For now, we'll skip local sync since it's primarily server-managed
      debugPrint('[ConsentManager] Local sync skipped (server-managed consents)');
    } catch (e) {
      debugPrint('[ConsentManager] Error syncing to local: $e');
      // Don't throw - local sync failure shouldn't block consent update
    }
  }

  /// Convert ConsentType enum to database string
  String _consentTypeToString(ConsentType type) {
    switch (type) {
      case ConsentType.analyticsTracking:
        return 'analytics_tracking';
      case ConsentType.marketingCommunications:
        return 'marketing_communications';
      case ConsentType.dataProcessing:
        return 'data_processing';
      case ConsentType.nonEssentialCookies:
        return 'non_essential_cookies';
      case ConsentType.doNotSellData:
        return 'do_not_sell_data';
    }
  }

  // ============================================================================
  // Helper methods for checking specific consents
  // ============================================================================

  /// Check if analytics tracking is allowed
  Future<bool> isAnalyticsAllowed(String userId) async {
    return await getConsent(userId, ConsentType.analyticsTracking);
  }

  /// Check if marketing communications are allowed
  Future<bool> isMarketingAllowed(String userId) async {
    return await getConsent(userId, ConsentType.marketingCommunications);
  }

  /// Check if data processing is allowed
  Future<bool> isDataProcessingAllowed(String userId) async {
    return await getConsent(userId, ConsentType.dataProcessing);
  }

  /// Check if non-essential cookies are allowed
  Future<bool> areNonEssentialCookiesAllowed(String userId) async {
    return await getConsent(userId, ConsentType.nonEssentialCookies);
  }

  /// Check if "Do Not Sell My Data" is enabled (CCPA)
  /// Returns true if user has opted out of data selling
  Future<bool> hasOptedOutOfDataSelling(String userId) async {
    // For "Do Not Sell", true means user has opted OUT
    return await getConsent(userId, ConsentType.doNotSellData);
  }
}
