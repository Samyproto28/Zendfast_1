import 'package:flutter_test/flutter_test.dart';
import 'package:zendfast_1/models/motivational_phrase.dart';
import 'package:zendfast_1/repositories/motivational_phrases_repository.dart';

void main() {
  late MotivationalPhrasesRepository repository;

  setUp(() {
    repository = MotivationalPhrasesRepository.instance;
  });

  group('MotivationalPhrasesRepository Tests', () {
    test('should be a singleton', () {
      // Arrange & Act
      final instance1 = MotivationalPhrasesRepository.instance;
      final instance2 = MotivationalPhrasesRepository.instance;

      // Assert
      expect(identical(instance1, instance2), true);
    });

    test('should return fallback phrases when cache is empty or not initialized',
        () async {
      // Act
      final phrases = await repository.getMotivationalPhrases();

      // Assert
      expect(phrases, isNotEmpty);
      expect(phrases.length, greaterThanOrEqualTo(6)); // At least 6 fallback phrases
      expect(phrases.any((p) => p.text.contains('más fuerte')), true);
      expect(phrases.any((p) => p.text.contains('Medita')), true);
      expect(phrases.any((p) => p.text.contains('agua')), true);
    });

    test('should provide all 6 fallback phrases with correct order', () {
      // Act
      final fallbackPhrases = repository.getFallbackPhrases();

      // Assert
      expect(fallbackPhrases.length, 6);

      // Verify order
      expect(fallbackPhrases[0].text, 'Eres más fuerte de lo que crees');
      expect(fallbackPhrases[0].orderIndex, 0);

      expect(fallbackPhrases[1].text, 'Bebe agua lentamente');
      expect(fallbackPhrases[1].orderIndex, 1);

      expect(fallbackPhrases[2].text, 'Toma 5 respiraciones profundas');
      expect(fallbackPhrases[2].orderIndex, 2);

      expect(fallbackPhrases[3].text, 'Sal a caminar 5 minutos');
      expect(fallbackPhrases[3].orderIndex, 3);

      expect(fallbackPhrases[4].text, 'Llama a un amigo');
      expect(fallbackPhrases[4].orderIndex, 4);

      expect(fallbackPhrases[5].text, 'Medita 5 minutos');
      expect(fallbackPhrases[5].orderIndex, 5);
    });

    test('should include subtitles and icons for all fallback phrases', () {
      // Act
      final fallbackPhrases = repository.getFallbackPhrases();

      // Assert
      for (final phrase in fallbackPhrases) {
        expect(phrase.subtitle, isNotNull);
        expect(phrase.subtitle!.isNotEmpty, true);
        expect(phrase.iconName.isNotEmpty, true);
      }
    });

    test('should categorize fallback phrases correctly', () {
      // Act
      final fallbackPhrases = repository.getFallbackPhrases();

      // Assert
      final motivationPhrases =
          fallbackPhrases.where((p) => p.category == 'motivation').toList();
      final calmPhrases =
          fallbackPhrases.where((p) => p.category == 'calm').toList();
      final antiBingePhrases =
          fallbackPhrases.where((p) => p.category == 'anti_binge').toList();

      expect(motivationPhrases.length, 2); // 2 motivation phrases
      expect(calmPhrases.length, 3); // 3 calm phrases
      expect(antiBingePhrases.length, 1); // 1 anti_binge phrase
    });

    test('should set all fallback phrases as active by default', () {
      // Act
      final fallbackPhrases = repository.getFallbackPhrases();

      // Assert
      expect(fallbackPhrases.every((p) => p.isActive), true);
    });

    test('should set valid timestamps for fallback phrases', () {
      // Act
      final fallbackPhrases = repository.getFallbackPhrases();

      // Assert
      final now = DateTime.now();
      for (final phrase in fallbackPhrases) {
        expect(phrase.createdAt, isNotNull);
        expect(phrase.updatedAt, isNotNull);
        expect(phrase.createdAt.isBefore(now.add(const Duration(seconds: 1))),
            true);
        expect(phrase.updatedAt.isBefore(now.add(const Duration(seconds: 1))),
            true);
      }
    });

    test('should have specific meditation phrase for breathing screen', () {
      // Act
      final fallbackPhrases = repository.getFallbackPhrases();
      final meditationPhrase =
          fallbackPhrases.firstWhere((p) => p.text.contains('Medita'));

      // Assert
      expect(meditationPhrase.text, 'Medita 5 minutos');
      expect(meditationPhrase.subtitle, contains('respiración'));
      expect(meditationPhrase.iconName, 'self_improvement');
      expect(meditationPhrase.category, 'calm');
    });

    test('should filter phrases by category from fallback', () {
      // Arrange
      final repository = MotivationalPhrasesRepository.instance;

      // Act
      final calmPhrases = repository
          .getFallbackPhrases()
          .where((p) => p.category == 'calm')
          .toList();

      // Assert
      expect(calmPhrases.length, 3);
      expect(calmPhrases.every((p) => p.category == 'calm'), true);
    });

    test('should maintain phrase ordering with orderIndex', () {
      // Act
      final fallbackPhrases = repository.getFallbackPhrases();
      final sortedPhrases = List<MotivationalPhrase>.from(fallbackPhrases)
        ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

      // Assert
      for (int i = 0; i < sortedPhrases.length; i++) {
        expect(sortedPhrases[i].orderIndex, i);
        expect(sortedPhrases[i], fallbackPhrases[i]);
      }
    });

    test('should have unique icons for variety', () {
      // Act
      final fallbackPhrases = repository.getFallbackPhrases();
      final icons = fallbackPhrases.map((p) => p.iconName).toSet();

      // Assert
      expect(icons.length, greaterThan(3)); // At least some variety
    });

    test('should handle error gracefully and return fallback', () async {
      // Arrange - Repository without initialization (simulates error state)
      final newRepository = MotivationalPhrasesRepository.instance;

      // Act
      final phrases = await newRepository.getMotivationalPhrases();

      // Assert - Should still return fallback phrases
      expect(phrases, isNotEmpty);
      expect(phrases.length, greaterThanOrEqualTo(6));
    });

    test('should support Spanish language in phrases', () {
      // Act
      final fallbackPhrases = repository.getFallbackPhrases();

      // Assert - At least some phrases should contain Spanish accented characters
      final phrasesWithAccents =
          fallbackPhrases.where((p) => p.text.contains(RegExp(r'[áéíóúñ]')));
      expect(phrasesWithAccents.length, greaterThan(0),
          reason: 'Should have some phrases with Spanish characters');

      // Verify Spanish words are present
      expect(fallbackPhrases.any((p) => p.text.contains('más')), true);
      expect(fallbackPhrases.any((p) => p.text.contains('respiraciones')), true);
    });
  });

  group('MotivationalPhrasesRepository Cache Logic Tests', () {
    test('should handle missing Isar gracefully', () async {
      // Act
      final result = await repository.loadFromCache();

      // Assert - Should return null when Isar not initialized
      expect(result, null);
    });

    test('should return fallback phrases when loadFromCache returns null',
        () async {
      // Arrange
      final cachedPhrases = await repository.loadFromCache();
      expect(cachedPhrases, null); // Verify cache is null

      // Act
      final phrases = await repository.getMotivationalPhrases();

      // Assert
      expect(phrases, isNotEmpty);
      expect(phrases.length, 6); // Should return all fallback phrases
    });

    test('refreshFromSupabase should not throw even without initialization',
        () async {
      // Act & Assert
      expect(
          () async => await repository.refreshFromSupabase(), returnsNormally);
    });

    test('clearCache should not throw without initialization', () async {
      // Act & Assert
      expect(() async => await repository.clearCache(), returnsNormally);
    });

    test('saveToCache should not throw without initialization', () async {
      // Arrange
      final testPhrases = [
        MotivationalPhrase(
          text: 'Test',
          iconName: 'star',
          orderIndex: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      // Act & Assert
      expect(() async => await repository.saveToCache(testPhrases),
          returnsNormally);
    });
  });
}
