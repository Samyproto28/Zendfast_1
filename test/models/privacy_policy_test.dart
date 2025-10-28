import 'package:flutter_test/flutter_test.dart';
import 'package:zendfast_1/models/privacy_policy.dart';

void main() {
  group('PrivacyPolicy Model Tests', () {
    group('Constructor and Defaults', () {
      test('constructor creates policy with required fields', () {
        final policy = PrivacyPolicy(
          version: 1,
          content: 'Privacy policy content here...',
          effectiveDate: DateTime(2024, 1, 1),
        );

        expect(policy.version, 1);
        expect(policy.content, 'Privacy policy content here...');
        expect(policy.language, 'es'); // Default
        expect(policy.effectiveDate, DateTime(2024, 1, 1));
        expect(policy.isActive, false); // Default
        expect(policy.createdAt, isNotNull);
        expect(policy.updatedAt, isNotNull);
      });

      test('constructor allows custom language', () {
        final policy = PrivacyPolicy(
          version: 1,
          content: 'Privacy policy content...',
          language: 'en',
          effectiveDate: DateTime(2024, 1, 1),
        );

        expect(policy.language, 'en');
      });

      test('constructor allows setting isActive', () {
        final policy = PrivacyPolicy(
          version: 1,
          content: 'Privacy policy content...',
          effectiveDate: DateTime(2024, 1, 1),
          isActive: true,
        );

        expect(policy.isActive, true);
      });
    });

    group('markUpdated() Tests', () {
      test('markUpdated updates the updatedAt timestamp', () async {
        final policy = PrivacyPolicy(
          version: 1,
          content: 'Content',
          effectiveDate: DateTime.now(),
        );

        final originalUpdatedAt = policy.updatedAt;
        await Future.delayed(const Duration(milliseconds: 10));

        policy.markUpdated();

        expect(policy.updatedAt.isAfter(originalUpdatedAt), true);
      });
    });

    group('Formatted Date Tests', () {
      test('formattedEffectiveDate returns correct format', () {
        final policy = PrivacyPolicy(
          version: 1,
          content: 'Content',
          effectiveDate: DateTime(2024, 3, 15),
        );

        expect(policy.formattedEffectiveDate, '15/03/2024');
      });

      test('formattedEffectiveDate pads single digits', () {
        final policy = PrivacyPolicy(
          version: 1,
          content: 'Content',
          effectiveDate: DateTime(2024, 1, 5),
        );

        expect(policy.formattedEffectiveDate, '05/01/2024');
      });
    });

    group('Content Preview Tests', () {
      test('contentPreview returns full content when under 200 chars', () {
        final shortContent = 'This is a short privacy policy';
        final policy = PrivacyPolicy(
          version: 1,
          content: shortContent,
          effectiveDate: DateTime.now(),
        );

        expect(policy.contentPreview, shortContent);
        expect(policy.contentPreview.endsWith('...'), false);
      });

      test('contentPreview truncates long content with ellipsis', () {
        final longContent = 'a' * 300;
        final policy = PrivacyPolicy(
          version: 1,
          content: longContent,
          effectiveDate: DateTime.now(),
        );

        expect(policy.contentPreview.length, 203); // 200 + '...'
        expect(policy.contentPreview.endsWith('...'), true);
        expect(policy.contentPreview.substring(0, 200), longContent.substring(0, 200));
      });

      test('contentPreview handles exactly 200 characters', () {
        final exactContent = 'a' * 200;
        final policy = PrivacyPolicy(
          version: 1,
          content: exactContent,
          effectiveDate: DateTime.now(),
        );

        expect(policy.contentPreview, exactContent);
        expect(policy.contentPreview.endsWith('...'), false);
      });
    });

    group('JSON Serialization Tests', () {
      test('toJson() serializes all fields with snake_case keys', () {
        final policy = PrivacyPolicy(
          version: 3,
          content: 'Privacy policy content...',
          language: 'en',
          effectiveDate: DateTime(2024, 6, 1),
          isActive: true,
        );

        final json = policy.toJson();

        expect(json['version'], 3);
        expect(json['content'], 'Privacy policy content...');
        expect(json['language'], 'en');
        expect(json['effective_date'], '2024-06-01T00:00:00.000');
        expect(json['is_active'], true);
        expect(json['created_at'], isNotNull);
        expect(json['updated_at'], isNotNull);
      });

      test('fromJson() deserializes all fields correctly', () {
        final json = {
          'version': 5,
          'content': 'Updated privacy policy',
          'language': 'es',
          'effective_date': '2024-07-01T00:00:00.000Z',
          'is_active': false,
          'created_at': '2024-06-01T00:00:00.000Z',
          'updated_at': '2024-06-15T00:00:00.000Z',
        };

        final policy = PrivacyPolicy.fromJson(json);

        expect(policy.version, 5);
        expect(policy.content, 'Updated privacy policy');
        expect(policy.language, 'es');
        expect(policy.effectiveDate, DateTime.parse('2024-07-01T00:00:00.000Z'));
        expect(policy.isActive, false);
      });

      test('fromJson() handles missing optional fields with defaults', () {
        final json = {
          'version': 1,
          'content': 'Content',
          // Missing language
          'effective_date': '2024-01-01T00:00:00.000Z',
          // Missing is_active
        };

        final policy = PrivacyPolicy.fromJson(json);

        expect(policy.language, 'es'); // Default
        expect(policy.isActive, false); // Default
      });

      test('JSON roundtrip preserves all data', () {
        final original = PrivacyPolicy(
          version: 10,
          content: 'Test content with unicode: àéîôû',
          language: 'fr',
          effectiveDate: DateTime(2024, 12, 25),
          isActive: true,
        );

        final json = original.toJson();
        final restored = PrivacyPolicy.fromJson(json);

        expect(restored.version, original.version);
        expect(restored.content, original.content);
        expect(restored.language, original.language);
        expect(restored.isActive, original.isActive);
      });
    });

    group('Edge Cases', () {
      test('handles empty content', () {
        final policy = PrivacyPolicy(
          version: 1,
          content: '',
          effectiveDate: DateTime.now(),
        );

        expect(policy.content, '');
        expect(policy.contentPreview, '');
      });

      test('handles very long content', () {
        final longContent = 'a' * 100000;
        final policy = PrivacyPolicy(
          version: 1,
          content: longContent,
          effectiveDate: DateTime.now(),
        );

        expect(policy.content.length, 100000);
        expect(policy.contentPreview.length, 203);
      });

      test('handles version 0', () {
        final policy = PrivacyPolicy(
          version: 0,
          content: 'Content',
          effectiveDate: DateTime.now(),
        );

        expect(policy.version, 0);
      });

      test('handles high version numbers', () {
        final policy = PrivacyPolicy(
          version: 999,
          content: 'Content',
          effectiveDate: DateTime.now(),
        );

        expect(policy.version, 999);
      });

      test('handles special characters in content', () {
        final specialContent = 'Content with\n\nnew lines\t\ttabs and "quotes"';
        final policy = PrivacyPolicy(
          version: 1,
          content: specialContent,
          effectiveDate: DateTime.now(),
        );

        expect(policy.content, specialContent);

        final json = policy.toJson();
        final restored = PrivacyPolicy.fromJson(json);
        expect(restored.content, specialContent);
      });

      test('handles markdown content', () {
        final markdown = '# Privacy Policy\n\n## Section 1\n\n**Bold** and *italic* text';
        final policy = PrivacyPolicy(
          version: 1,
          content: markdown,
          effectiveDate: DateTime.now(),
        );

        expect(policy.content, markdown);
      });
    });

    group('Multi-language Support', () {
      test('supports ISO 639-1 language codes', () {
        final languages = ['es', 'en', 'fr', 'de', 'it', 'pt', 'ja', 'zh'];

        for (final lang in languages) {
          final policy = PrivacyPolicy(
            version: 1,
            content: 'Content',
            language: lang,
            effectiveDate: DateTime.now(),
          );

          expect(policy.language, lang);
        }
      });
    });

    group('Version Management', () {
      test('different versions can coexist', () {
        final v1 = PrivacyPolicy(
          version: 1,
          content: 'Version 1 content',
          effectiveDate: DateTime(2024, 1, 1),
          isActive: false,
        );

        final v2 = PrivacyPolicy(
          version: 2,
          content: 'Version 2 content',
          effectiveDate: DateTime(2024, 6, 1),
          isActive: true,
        );

        expect(v1.version, 1);
        expect(v2.version, 2);
        expect(v1.isActive, false);
        expect(v2.isActive, true);
      });
    });
  });
}
