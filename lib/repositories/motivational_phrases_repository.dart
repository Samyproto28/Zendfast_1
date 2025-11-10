import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zendfast_1/models/motivational_phrase.dart';

/// Repository for managing motivational phrases used in the panic modal.
///
/// This repository handles:
/// - Loading phrases from local Isar cache
/// - Fetching phrases from Supabase
/// - Cache invalidation (7-day expiration)
/// - Providing fallback phrases when offline
///
/// Follows singleton pattern for consistent state across the app.
class MotivationalPhrasesRepository {
  static final MotivationalPhrasesRepository instance =
      MotivationalPhrasesRepository._internal();

  MotivationalPhrasesRepository._internal();

  /// Isar database instance
  Isar? _isar;

  /// SharedPreferences for cache timestamp
  SharedPreferences? _prefs;

  /// Cache timestamp key
  static const String _cacheTimestampKey = 'motivational_phrases_cache_timestamp';

  /// Cache duration (7 days)
  static const Duration _cacheDuration = Duration(days: 7);

  /// Initialize the repository with Isar instance
  Future<void> initialize(Isar isar) async {
    _isar = isar;
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get motivational phrases (from cache or fallback)
  Future<List<MotivationalPhrase>> getMotivationalPhrases() async {
    try {
      // Check if cache is valid
      if (_isar != null && !(await isCacheExpired())) {
        final cachedPhrases = await loadFromCache();
        if (cachedPhrases != null && cachedPhrases.isNotEmpty) {
          return cachedPhrases
              .where((p) => p.isActive)
              .toList()
            ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
        }
      }

      // Return fallback phrases if cache is empty or expired
      return getFallbackPhrases();
    } catch (e) {
      // Return fallback phrases on error
      return getFallbackPhrases();
    }
  }

  /// Get fallback motivational phrases (hardcoded for offline use)
  List<MotivationalPhrase> getFallbackPhrases() {
    final now = DateTime.now();
    return [
      MotivationalPhrase(
        text: 'Eres más fuerte de lo que crees',
        subtitle: 'Confía en ti mismo',
        iconName: 'favorite',
        category: 'motivation',
        orderIndex: 0,
        createdAt: now,
        updatedAt: now,
      ),
      MotivationalPhrase(
        text: 'Bebe agua lentamente',
        subtitle: 'Hidratación consciente',
        iconName: 'water_drop',
        category: 'anti_binge',
        orderIndex: 1,
        createdAt: now,
        updatedAt: now,
      ),
      MotivationalPhrase(
        text: 'Toma 5 respiraciones profundas',
        subtitle: 'Técnica 4-7-8',
        iconName: 'air',
        category: 'calm',
        orderIndex: 2,
        createdAt: now,
        updatedAt: now,
      ),
      MotivationalPhrase(
        text: 'Sal a caminar 5 minutos',
        subtitle: 'Movimiento consciente',
        iconName: 'directions_walk',
        category: 'calm',
        orderIndex: 3,
        createdAt: now,
        updatedAt: now,
      ),
      MotivationalPhrase(
        text: 'Llama a un amigo',
        subtitle: 'Apoyo social',
        iconName: 'phone',
        category: 'motivation',
        orderIndex: 4,
        createdAt: now,
        updatedAt: now,
      ),
      MotivationalPhrase(
        text: 'Medita 5 minutos',
        subtitle: 'Ejercicio de respiración guiada',
        iconName: 'self_improvement',
        category: 'calm',
        orderIndex: 5,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  /// Load phrases from Isar cache
  Future<List<MotivationalPhrase>?> loadFromCache() async {
    if (_isar == null) return null;

    try {
      final phrases = await _isar!.motivationalPhrases
          .where()
          .sortByOrderIndex()
          .findAll();
      return phrases;
    } catch (e) {
      return null;
    }
  }

  /// Save phrases to Isar cache
  Future<void> saveToCache(List<MotivationalPhrase> phrases) async {
    if (_isar == null) return;

    try {
      await _isar!.writeTxn(() async {
        // Clear existing phrases
        await _isar!.motivationalPhrases.clear();
        // Add new phrases
        await _isar!.motivationalPhrases.putAll(phrases);
      });

      // Update cache timestamp
      await saveCacheTimestamp(DateTime.now());
    } catch (e) {
      // Silently fail - fallback phrases will be used
    }
  }

  /// Check if cache is expired (older than 7 days)
  Future<bool> isCacheExpired() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }

    final timestampMillis = _prefs!.getInt(_cacheTimestampKey);
    if (timestampMillis == null) {
      return true; // No timestamp = expired
    }

    final timestamp = DateTime.fromMillisecondsSinceEpoch(timestampMillis);
    final difference = DateTime.now().difference(timestamp);

    return difference > _cacheDuration;
  }

  /// Save cache timestamp
  Future<void> saveCacheTimestamp(DateTime timestamp) async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }

    await _prefs!.setInt(_cacheTimestampKey, timestamp.millisecondsSinceEpoch);
  }

  /// Clear all cached phrases
  Future<void> clearCache() async {
    if (_isar == null) return;

    try {
      await _isar!.writeTxn(() async {
        await _isar!.motivationalPhrases.clear();
      });

      // Clear timestamp
      if (_prefs == null) {
        _prefs = await SharedPreferences.getInstance();
      }
      await _prefs!.remove(_cacheTimestampKey);
    } catch (e) {
      // Silently fail
    }
  }

  /// Refresh phrases from Supabase
  Future<void> refreshFromSupabase() async {
    try {
      final supabase = Supabase.instance.client;

      final response = await supabase
          .from('motivational_phrases')
          .select()
          .eq('is_active', true)
          .order('order_index');

      final List<dynamic> data = response as List<dynamic>;

      final phrases = data
          .map((json) => MotivationalPhrase.fromJson(json as Map<String, dynamic>))
          .toList();

      if (phrases.isNotEmpty) {
        await saveToCache(phrases);
      }
    } catch (e) {
      // Silently fail - fallback phrases will be used
      // In production, you might want to log this error
    }
  }

  /// Get phrases by category
  Future<List<MotivationalPhrase>> getPhrasesByCategory(String category) async {
    if (_isar == null) {
      // Return fallback phrases filtered by category
      return getFallbackPhrases()
          .where((p) => p.category == category)
          .toList();
    }

    try {
      final phrases = await _isar!.motivationalPhrases
          .filter()
          .categoryEqualTo(category)
          .isActiveEqualTo(true)
          .sortByOrderIndex()
          .findAll();

      return phrases.isNotEmpty
          ? phrases
          : getFallbackPhrases().where((p) => p.category == category).toList();
    } catch (e) {
      return getFallbackPhrases()
          .where((p) => p.category == category)
          .toList();
    }
  }
}
