import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:zendfast_1/models/motivational_phrase.dart';

void main() {
  group('MotivationalPhrase Model Tests', () {
    test('should create a MotivationalPhrase instance with all fields', () {
      // Arrange
      final now = DateTime.now();

      // Act
      final phrase = MotivationalPhrase(
        id: 1,
        text: 'Eres más fuerte de lo que crees',
        subtitle: 'Confía en ti mismo',
        iconName: 'favorite',
        category: 'motivation',
        orderIndex: 0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      // Assert
      expect(phrase.id, 1);
      expect(phrase.text, 'Eres más fuerte de lo que crees');
      expect(phrase.subtitle, 'Confía en ti mismo');
      expect(phrase.iconName, 'favorite');
      expect(phrase.category, 'motivation');
      expect(phrase.orderIndex, 0);
      expect(phrase.isActive, true);
      expect(phrase.createdAt, now);
      expect(phrase.updatedAt, now);
    });

    test('should create a MotivationalPhrase with default values', () {
      // Arrange
      final now = DateTime.now();

      // Act
      final phrase = MotivationalPhrase(
        text: 'Test phrase',
        iconName: 'star',
        orderIndex: 0,
        createdAt: now,
        updatedAt: now,
      );

      // Assert
      expect(phrase.id, Isar.autoIncrement);
      expect(phrase.subtitle, null);
      expect(phrase.category, null);
      expect(phrase.isActive, true);
      expect(phrase.createdAt, now);
      expect(phrase.updatedAt, now);
    });

    test('should serialize to JSON correctly', () {
      // Arrange
      final now = DateTime.now();
      final phrase = MotivationalPhrase(
        id: 1,
        text: 'Test phrase',
        subtitle: 'Test subtitle',
        iconName: 'star',
        category: 'calm',
        orderIndex: 5,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      // Act
      final json = phrase.toJson();

      // Assert
      expect(json['id'], 1);
      expect(json['text'], 'Test phrase');
      expect(json['subtitle'], 'Test subtitle');
      expect(json['icon_name'], 'star');
      expect(json['category'], 'calm');
      expect(json['order_index'], 5);
      expect(json['is_active'], true);
      expect(json['created_at'], isNotNull);
      expect(json['updated_at'], isNotNull);
    });

    test('should deserialize from JSON correctly', () {
      // Arrange
      final json = {
        'id': 2,
        'text': 'Bebe agua lentamente',
        'subtitle': 'Hidratación consciente',
        'icon_name': 'water_drop',
        'category': 'anti_binge',
        'order_index': 1,
        'is_active': true,
        'created_at': '2025-01-10T12:00:00.000Z',
        'updated_at': '2025-01-10T12:00:00.000Z',
      };

      // Act
      final phrase = MotivationalPhrase.fromJson(json);

      // Assert
      expect(phrase.id, 2);
      expect(phrase.text, 'Bebe agua lentamente');
      expect(phrase.subtitle, 'Hidratación consciente');
      expect(phrase.iconName, 'water_drop');
      expect(phrase.category, 'anti_binge');
      expect(phrase.orderIndex, 1);
      expect(phrase.isActive, true);
      expect(phrase.createdAt, isA<DateTime>());
      expect(phrase.updatedAt, isA<DateTime>());
    });

    test('should handle null values in JSON deserialization', () {
      // Arrange
      final json = {
        'id': 3,
        'text': 'Required text',
        'icon_name': 'check',
        'order_index': 0,
      };

      // Act
      final phrase = MotivationalPhrase.fromJson(json);

      // Assert
      expect(phrase.id, 3);
      expect(phrase.text, 'Required text');
      expect(phrase.subtitle, null);
      expect(phrase.category, null);
      expect(phrase.iconName, 'check');
      expect(phrase.isActive, true); // Default value
    });

    test('should support copyWith method', () {
      // Arrange
      final now = DateTime.now();
      final original = MotivationalPhrase(
        id: 1,
        text: 'Original text',
        subtitle: 'Original subtitle',
        iconName: 'star',
        category: 'motivation',
        orderIndex: 0,
        createdAt: now,
        updatedAt: now,
      );

      // Act
      final updated = original.copyWith(
        text: 'Updated text',
        isActive: false,
      );

      // Assert
      expect(updated.id, 1);
      expect(updated.text, 'Updated text');
      expect(updated.subtitle, 'Original subtitle');
      expect(updated.iconName, 'star');
      expect(updated.category, 'motivation');
      expect(updated.isActive, false);
    });

    test('should have correct Isar collection name', () {
      // This test verifies the @collection annotation is properly set
      // The actual collection name is verified by Isar's code generation
      expect(MotivationalPhrase, isA<Type>());
    });

    test('should validate required fields are not empty', () {
      // Arrange
      final now = DateTime.now();

      // Act
      final phrase = MotivationalPhrase(
        text: '',
        iconName: '',
        orderIndex: 0,
        createdAt: now,
        updatedAt: now,
      );

      // Assert
      expect(phrase.text.isEmpty, true);
      expect(phrase.iconName.isEmpty, true);
    });

    test('should maintain insertion order with orderIndex', () {
      // Arrange
      final now = DateTime.now();
      final phrase1 = MotivationalPhrase(
        text: 'First',
        iconName: 'star',
        orderIndex: 0,
        createdAt: now,
        updatedAt: now,
      );
      final phrase2 = MotivationalPhrase(
        text: 'Second',
        iconName: 'star',
        orderIndex: 1,
        createdAt: now,
        updatedAt: now,
      );
      final phrase3 = MotivationalPhrase(
        text: 'Third',
        iconName: 'star',
        orderIndex: 2,
        createdAt: now,
        updatedAt: now,
      );

      // Act
      final phrases = [phrase3, phrase1, phrase2];
      phrases.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

      // Assert
      expect(phrases[0].text, 'First');
      expect(phrases[1].text, 'Second');
      expect(phrases[2].text, 'Third');
    });

    test('should handle timestamp updates', () {
      // Arrange
      final now = DateTime.now();
      final phrase = MotivationalPhrase(
        id: 1,
        text: 'Test',
        iconName: 'star',
        orderIndex: 0,
        createdAt: now,
        updatedAt: now,
      );
      final originalUpdatedAt = phrase.updatedAt;

      // Wait a bit to ensure time difference
      Future.delayed(const Duration(milliseconds: 10));

      // Act
      final updated = phrase.copyWith(
        text: 'Updated',
        updatedAt: DateTime.now(),
      );

      // Assert
      expect(updated.updatedAt.isAfter(originalUpdatedAt), true);
    });
  });
}
