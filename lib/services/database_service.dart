import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart'; // ignore: depend_on_referenced_packages
import '../models/fasting_session.dart';
import '../models/user_profile.dart';
import '../models/user_metrics.dart';
import '../models/hydration_log.dart';
import '../models/content_item.dart';
import '../models/user_consent.dart';
import '../models/privacy_policy.dart';
import '../models/push_notification.dart';

/// Singleton service for managing Isar database operations
/// Provides CRUD methods for all collections
class DatabaseService {
  static DatabaseService? _instance;
  static Isar? _isar;

  // Private constructor
  DatabaseService._();

  /// Get singleton instance
  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  /// Get Isar instance (must call initialize first)
  Isar get isar {
    if (_isar == null) {
      throw Exception(
        'DatabaseService not initialized. Call initialize() first.',
      );
    }
    return _isar!;
  }

  /// Check if database is initialized
  bool get isInitialized => _isar != null;

  /// Initialize the database
  /// Should be called once at app startup
  Future<void> initialize() async {
    if (_isar != null) return; // Already initialized

    final dir = await getApplicationDocumentsDirectory();

    _isar = await Isar.open(
      [
        FastingSessionSchema,
        UserProfileSchema,
        UserMetricsSchema,
        HydrationLogSchema,
        ContentItemSchema,
        UserConsentSchema,
        PrivacyPolicySchema,
        PushNotificationSchema,
      ],
      directory: dir.path,
      inspector: true, // Enable Isar Inspector in debug mode
    );
  }

  /// Close the database
  /// Should be called when the app is being disposed
  Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }

  // ============================================================================
  // FastingSession CRUD Operations
  // ============================================================================

  /// Create a new fasting session
  Future<int> createFastingSession(FastingSession session) async {
    return await isar.writeTxn(() async {
      return await isar.fastingSessions.put(session);
    });
  }

  /// Get a fasting session by ID
  Future<FastingSession?> getFastingSession(int id) async {
    return await isar.fastingSessions.get(id);
  }

  /// Get all fasting sessions for a user
  Future<List<FastingSession>> getUserFastingSessions(String userId) async {
    return await isar.fastingSessions
        .filter()
        .userIdEqualTo(userId)
        .sortByStartTimeDesc()
        .findAll();
  }

  /// Get active fasting session for a user (if any)
  Future<FastingSession?> getActiveFastingSession(String userId) async {
    return await isar.fastingSessions
        .filter()
        .userIdEqualTo(userId)
        .endTimeIsNull()
        .findFirst();
  }

  /// Get completed fasting sessions for a user
  Future<List<FastingSession>> getCompletedFastingSessions(
    String userId,
  ) async {
    return await isar.fastingSessions
        .filter()
        .userIdEqualTo(userId)
        .completedEqualTo(true)
        .sortByStartTimeDesc()
        .findAll();
  }

  /// Update a fasting session
  Future<int> updateFastingSession(FastingSession session) async {
    return await isar.writeTxn(() async {
      return await isar.fastingSessions.put(session);
    });
  }

  /// Delete a fasting session
  Future<bool> deleteFastingSession(int id) async {
    return await isar.writeTxn(() async {
      return await isar.fastingSessions.delete(id);
    });
  }

  // ============================================================================
  // UserProfile CRUD Operations
  // ============================================================================

  /// Save or update a user profile
  Future<int> saveUserProfile(UserProfile profile) async {
    profile.markUpdated();
    return await isar.writeTxn(() async {
      return await isar.userProfiles.put(profile);
    });
  }

  /// Get user profile by user ID
  Future<UserProfile?> getUserProfile(String userId) async {
    return await isar.userProfiles.filter().userIdEqualTo(userId).findFirst();
  }

  /// Delete a user profile
  Future<bool> deleteUserProfile(int id) async {
    return await isar.writeTxn(() async {
      return await isar.userProfiles.delete(id);
    });
  }

  // ============================================================================
  // UserMetrics CRUD Operations
  // ============================================================================

  /// Save or update user metrics
  Future<int> saveUserMetrics(UserMetrics metrics) async {
    metrics.markUpdated();
    return await isar.writeTxn(() async {
      return await isar.userMetrics.put(metrics);
    });
  }

  /// Get user metrics by user ID
  Future<UserMetrics?> getUserMetrics(String userId) async {
    return await isar.userMetrics.filter().userIdEqualTo(userId).findFirst();
  }

  /// Get or create user metrics for a user
  /// Returns existing metrics or creates new ones if they don't exist
  Future<UserMetrics> getOrCreateUserMetrics(String userId) async {
    final existing = await getUserMetrics(userId);
    if (existing != null) {
      return existing;
    }

    // Create new metrics
    final newMetrics = UserMetrics(userId: userId);
    await saveUserMetrics(newMetrics);
    return newMetrics;
  }

  /// Delete user metrics
  Future<bool> deleteUserMetrics(int id) async {
    return await isar.writeTxn(() async {
      return await isar.userMetrics.delete(id);
    });
  }

  // ============================================================================
  // HydrationLog CRUD Operations
  // ============================================================================

  /// Log hydration
  Future<int> logHydration(HydrationLog log) async {
    return await isar.writeTxn(() async {
      return await isar.hydrationLogs.put(log);
    });
  }

  /// Get hydration log by ID
  Future<HydrationLog?> getHydrationLog(int id) async {
    return await isar.hydrationLogs.get(id);
  }

  /// Get today's hydration logs for a user
  Future<List<HydrationLog>> getTodayHydration(String userId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return await isar.hydrationLogs
        .filter()
        .userIdEqualTo(userId)
        .timestampBetween(startOfDay, endOfDay)
        .sortByTimestampDesc()
        .findAll();
  }

  /// Get total hydration for today in milliliters
  Future<double> getTodayTotalHydration(String userId) async {
    final logs = await getTodayHydration(userId);
    return logs.fold<double>(0.0, (sum, log) => sum + log.amountMl);
  }

  /// Get hydration logs for a date range
  Future<List<HydrationLog>> getHydrationRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await isar.hydrationLogs
        .filter()
        .userIdEqualTo(userId)
        .timestampBetween(startDate, endDate)
        .sortByTimestampDesc()
        .findAll();
  }

  /// Delete a hydration log
  Future<bool> deleteHydrationLog(int id) async {
    return await isar.writeTxn(() async {
      return await isar.hydrationLogs.delete(id);
    });
  }

  // ============================================================================
  // ContentItem CRUD Operations
  // ============================================================================

  /// Create or update a content item
  Future<int> saveContentItem(ContentItem item) async {
    return await isar.writeTxn(() async {
      return await isar.contentItems.put(item);
    });
  }

  /// Get content item by ID
  Future<ContentItem?> getContentItem(int id) async {
    return await isar.contentItems.get(id);
  }

  /// Get all content items with optional filters
  Future<List<ContentItem>> getContentItems({
    ContentType? type,
    ContentCategory? category,
    bool? isPremium,
  }) async {
    // Build query based on provided filters
    if (type != null && category != null && isPremium != null) {
      return await isar.contentItems
          .filter()
          .contentTypeEqualTo(type)
          .and()
          .categoryEqualTo(category)
          .and()
          .isPremiumEqualTo(isPremium)
          .findAll();
    } else if (type != null && category != null) {
      return await isar.contentItems
          .filter()
          .contentTypeEqualTo(type)
          .and()
          .categoryEqualTo(category)
          .findAll();
    } else if (type != null && isPremium != null) {
      return await isar.contentItems
          .filter()
          .contentTypeEqualTo(type)
          .and()
          .isPremiumEqualTo(isPremium)
          .findAll();
    } else if (category != null && isPremium != null) {
      return await isar.contentItems
          .filter()
          .categoryEqualTo(category)
          .and()
          .isPremiumEqualTo(isPremium)
          .findAll();
    } else if (type != null) {
      return await isar.contentItems
          .filter()
          .contentTypeEqualTo(type)
          .findAll();
    } else if (category != null) {
      return await isar.contentItems
          .filter()
          .categoryEqualTo(category)
          .findAll();
    } else if (isPremium != null) {
      return await isar.contentItems
          .filter()
          .isPremiumEqualTo(isPremium)
          .findAll();
    }

    // No filters, return all
    return await isar.contentItems.where().findAll();
  }

  /// Search content by title
  Future<List<ContentItem>> searchContentByTitle(String query) async {
    return await isar.contentItems
        .filter()
        .titleContains(query, caseSensitive: false)
        .sortByTitle()
        .findAll();
  }

  /// Get free content items
  Future<List<ContentItem>> getFreeContent() async {
    return await getContentItems(isPremium: false);
  }

  /// Get premium content items
  Future<List<ContentItem>> getPremiumContent() async {
    return await getContentItems(isPremium: true);
  }

  /// Delete a content item
  Future<bool> deleteContentItem(int id) async {
    return await isar.writeTxn(() async {
      return await isar.contentItems.delete(id);
    });
  }

  // ============================================================================
  // Batch Operations
  // ============================================================================

  /// Bulk insert hydration logs
  Future<void> bulkInsertHydrationLogs(List<HydrationLog> logs) async {
    await isar.writeTxn(() async {
      await isar.hydrationLogs.putAll(logs);
    });
  }

  /// Bulk insert content items
  Future<void> bulkInsertContentItems(List<ContentItem> items) async {
    await isar.writeTxn(() async {
      await isar.contentItems.putAll(items);
    });
  }

  // ============================================================================
  // Database Statistics
  // ============================================================================

  /// Get total count of each collection
  Future<Map<String, int>> getDatabaseStats() async {
    return {
      'fastingSessions': await isar.fastingSessions.count(),
      'userProfiles': await isar.userProfiles.count(),
      'userMetrics': await isar.userMetrics.count(),
      'hydrationLogs': await isar.hydrationLogs.count(),
      'contentItems': await isar.contentItems.count(),
    };
  }

  /// Clear all data from all collections (use with caution!)
  Future<void> clearAllData() async {
    await isar.writeTxn(() async {
      await isar.fastingSessions.clear();
      await isar.userProfiles.clear();
      await isar.userMetrics.clear();
      await isar.hydrationLogs.clear();
      await isar.contentItems.clear();
      await isar.userConsents.clear();
      await isar.privacyPolicys.clear();
    });
  }

  // ============================================================================
  // UserConsent CRUD Operations
  // ============================================================================

  /// Save or update user consent
  Future<int> saveUserConsent(UserConsent consent) async {
    consent.markUpdated();
    return await isar.writeTxn(() async {
      return await isar.userConsents.put(consent);
    });
  }

  /// Get user consents by user ID
  Future<List<UserConsent>> getUserConsents(String userId) async {
    return await isar.userConsents.filter().userIdEqualTo(userId).findAll();
  }

  /// Delete user consent
  Future<bool> deleteUserConsent(int id) async {
    return await isar.writeTxn(() async {
      return await isar.userConsents.delete(id);
    });
  }

  // ============================================================================
  // PrivacyPolicy CRUD Operations
  // ============================================================================

  /// Save or update privacy policy
  Future<int> savePrivacyPolicy(PrivacyPolicy policy) async {
    policy.markUpdated();
    return await isar.writeTxn(() async {
      return await isar.privacyPolicys.put(policy);
    });
  }

  /// Get active privacy policy
  Future<PrivacyPolicy?> getActivePrivacyPolicy() async {
    return await isar.privacyPolicys.filter().isActiveEqualTo(true).findFirst();
  }

  /// Get privacy policy by version
  Future<PrivacyPolicy?> getPrivacyPolicyByVersion(int version) async {
    return await isar.privacyPolicys.filter().versionEqualTo(version).findFirst();
  }

  /// Delete privacy policy
  Future<bool> deletePrivacyPolicy(int id) async {
    return await isar.writeTxn(() async {
      return await isar.privacyPolicys.delete(id);
    });
  }
}
