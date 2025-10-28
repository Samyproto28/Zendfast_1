import 'package:flutter_test/flutter_test.dart';
import 'package:zendfast_1/models/user_consent.dart';

void main() {
  group('UserConsent Model Tests', () {
    group('Constructor and Defaults', () {
      test('default constructor creates consent with GDPR-compliant defaults', () {
        final consent = UserConsent(
          userId: 'user123',
          consentType: ConsentType.analyticsTracking,
        );

        expect(consent.userId, 'user123');
        expect(consent.consentType, ConsentType.analyticsTracking);
        expect(consent.consentGiven, false); // GDPR: Default to false
        expect(consent.consentVersion, 1);
        expect(consent.createdAt, isNotNull);
        expect(consent.updatedAt, isNotNull);
      });

      test('constructor allows explicit consentGiven value', () {
        final consent = UserConsent(
          userId: 'user123',
          consentType: ConsentType.marketingCommunications,
          consentGiven: true,
        );

        expect(consent.consentGiven, true);
      });

      test('constructor allows custom consentVersion', () {
        final consent = UserConsent(
          userId: 'user123',
          consentType: ConsentType.dataProcessing,
          consentVersion: 5,
        );

        expect(consent.consentVersion, 5);
      });

      test('createdAt and updatedAt are set to current time', () {
        final before = DateTime.now();
        final consent = UserConsent(
          userId: 'user123',
          consentType: ConsentType.nonEssentialCookies,
        );
        final after = DateTime.now();

        expect(consent.createdAt.isAfter(before.subtract(const Duration(seconds: 1))), true);
        expect(consent.createdAt.isBefore(after.add(const Duration(seconds: 1))), true);
        expect(consent.updatedAt.isAfter(before.subtract(const Duration(seconds: 1))), true);
        expect(consent.updatedAt.isBefore(after.add(const Duration(seconds: 1))), true);
      });
    });

    group('ConsentType Enum Tests', () {
      test('all consent types are defined', () {
        expect(ConsentType.values.length, 5);
        expect(ConsentType.values, contains(ConsentType.analyticsTracking));
        expect(ConsentType.values, contains(ConsentType.marketingCommunications));
        expect(ConsentType.values, contains(ConsentType.dataProcessing));
        expect(ConsentType.values, contains(ConsentType.nonEssentialCookies));
        expect(ConsentType.values, contains(ConsentType.doNotSellData));
      });

      test('consent type converts to correct snake_case string', () {
        final analyticsConsent = UserConsent(
          userId: 'user123',
          consentType: ConsentType.analyticsTracking,
        );
        expect(analyticsConsent.consentTypeString, 'analytics_tracking');

        final marketingConsent = UserConsent(
          userId: 'user123',
          consentType: ConsentType.marketingCommunications,
        );
        expect(marketingConsent.consentTypeString, 'marketing_communications');

        final dataConsent = UserConsent(
          userId: 'user123',
          consentType: ConsentType.dataProcessing,
        );
        expect(dataConsent.consentTypeString, 'data_processing');

        final cookiesConsent = UserConsent(
          userId: 'user123',
          consentType: ConsentType.nonEssentialCookies,
        );
        expect(cookiesConsent.consentTypeString, 'non_essential_cookies');

        final doNotSellConsent = UserConsent(
          userId: 'user123',
          consentType: ConsentType.doNotSellData,
        );
        expect(doNotSellConsent.consentTypeString, 'do_not_sell_data');
      });
    });

    group('Display Name and Description Tests', () {
      test('analyticsTracking has correct Spanish display text', () {
        final consent = UserConsent(
          userId: 'user123',
          consentType: ConsentType.analyticsTracking,
        );

        expect(consent.displayName, 'Seguimiento de Analytics');
        expect(consent.description, 'Permitir el seguimiento de tu uso de la app para mejorar nuestros servicios.');
      });

      test('marketingCommunications has correct Spanish display text', () {
        final consent = UserConsent(
          userId: 'user123',
          consentType: ConsentType.marketingCommunications,
        );

        expect(consent.displayName, 'Comunicaciones de Marketing');
        expect(consent.description, 'Recibir emails de marketing, notificaciones promocionales y actualizaciones.');
      });

      test('dataProcessing has correct Spanish display text', () {
        final consent = UserConsent(
          userId: 'user123',
          consentType: ConsentType.dataProcessing,
        );

        expect(consent.displayName, 'Procesamiento de Datos');
        expect(consent.description, 'Permitir el procesamiento de tus datos por servicios de terceros confiables.');
      });

      test('nonEssentialCookies has correct Spanish display text', () {
        final consent = UserConsent(
          userId: 'user123',
          consentType: ConsentType.nonEssentialCookies,
        );

        expect(consent.displayName, 'Cookies No Esenciales');
        expect(consent.description, 'Almacenar cookies y datos locales opcionales para mejorar tu experiencia.');
      });

      test('doNotSellData has correct Spanish display text (CCPA)', () {
        final consent = UserConsent(
          userId: 'user123',
          consentType: ConsentType.doNotSellData,
        );

        expect(consent.displayName, 'No Vender Mis Datos (CCPA)');
        expect(consent.description, 'Ejercer tu derecho bajo CCPA para que no vendamos tu información personal.');
      });
    });

    group('markUpdated() Tests', () {
      test('markUpdated updates the updatedAt timestamp', () async {
        final consent = UserConsent(
          userId: 'user123',
          consentType: ConsentType.analyticsTracking,
        );

        final originalUpdatedAt = consent.updatedAt;

        // Wait a bit to ensure timestamp difference
        await Future.delayed(const Duration(milliseconds: 10));

        consent.markUpdated();

        expect(consent.updatedAt.isAfter(originalUpdatedAt), true);
        expect(consent.createdAt, isNot(equals(consent.updatedAt)));
      });

      test('markUpdated does not change other fields', () async {
        final consent = UserConsent(
          userId: 'user123',
          consentType: ConsentType.dataProcessing,
          consentGiven: true,
          consentVersion: 2,
        );

        final originalUserId = consent.userId;
        final originalConsentType = consent.consentType;
        final originalConsentGiven = consent.consentGiven;
        final originalVersion = consent.consentVersion;
        final originalCreatedAt = consent.createdAt;

        await Future.delayed(const Duration(milliseconds: 10));
        consent.markUpdated();

        expect(consent.userId, originalUserId);
        expect(consent.consentType, originalConsentType);
        expect(consent.consentGiven, originalConsentGiven);
        expect(consent.consentVersion, originalVersion);
        expect(consent.createdAt, originalCreatedAt);
      });
    });

    group('JSON Serialization Tests', () {
      test('toJson() serializes all fields correctly with snake_case keys', () {
        final consent = UserConsent(
          userId: 'user123',
          consentType: ConsentType.analyticsTracking,
          consentGiven: true,
          consentVersion: 3,
        );

        final json = consent.toJson();

        expect(json['user_id'], 'user123');
        expect(json['consent_type'], 'analytics_tracking');
        expect(json['consent_given'], true);
        expect(json['consent_version'], 3);
        expect(json['created_at'], isNotNull);
        expect(json['updated_at'], isNotNull);
      });

      test('toJson() handles false consentGiven correctly', () {
        final consent = UserConsent(
          userId: 'user123',
          consentType: ConsentType.marketingCommunications,
          consentGiven: false,
        );

        final json = consent.toJson();

        expect(json['consent_given'], false);
      });

      test('fromJson() deserializes all fields correctly', () {
        final json = {
          'user_id': 'user456',
          'consent_type': 'marketing_communications',
          'consent_given': true,
          'consent_version': 5,
          'created_at': DateTime(2024, 1, 15).toIso8601String(),
          'updated_at': DateTime(2024, 1, 20).toIso8601String(),
        };

        final consent = UserConsent.fromJson(json);

        expect(consent.userId, 'user456');
        expect(consent.consentType, ConsentType.marketingCommunications);
        expect(consent.consentGiven, true);
        expect(consent.consentVersion, 5);
        expect(consent.createdAt, DateTime(2024, 1, 15));
        expect(consent.updatedAt, DateTime(2024, 1, 20));
      });

      test('fromJson() handles all consent types correctly', () {
        final testCases = [
          ('analytics_tracking', ConsentType.analyticsTracking),
          ('marketing_communications', ConsentType.marketingCommunications),
          ('data_processing', ConsentType.dataProcessing),
          ('non_essential_cookies', ConsentType.nonEssentialCookies),
          ('do_not_sell_data', ConsentType.doNotSellData),
        ];

        for (final testCase in testCases) {
          final json = {
            'user_id': 'user123',
            'consent_type': testCase.$1,
            'consent_given': false,
            'consent_version': 1,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          };

          final consent = UserConsent.fromJson(json);
          expect(consent.consentType, testCase.$2);
        }
      });

      test('fromJson() handles missing optional fields with defaults', () {
        final json = {
          'user_id': 'user123',
          'consent_type': 'analytics_tracking',
          // Missing consent_given, should default to false
          // Missing consent_version, should default to 1
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        final consent = UserConsent.fromJson(json);

        expect(consent.consentGiven, false); // GDPR default
        expect(consent.consentVersion, 1);
      });

      test('JSON roundtrip preserves all data', () {
        final original = UserConsent(
          userId: 'user789',
          consentType: ConsentType.nonEssentialCookies,
          consentGiven: true,
          consentVersion: 7,
        );

        final json = original.toJson();
        final restored = UserConsent.fromJson(json);

        expect(restored.userId, original.userId);
        expect(restored.consentType, original.consentType);
        expect(restored.consentGiven, original.consentGiven);
        expect(restored.consentVersion, original.consentVersion);
      });

      test('fromJson() throws on unknown consent type', () {
        final json = {
          'user_id': 'user123',
          'consent_type': 'unknown_consent_type',
          'consent_given': false,
          'consent_version': 1,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        expect(
          () => UserConsent.fromJson(json),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Edge Cases and Validation', () {
      test('handles empty userId', () {
        final consent = UserConsent(
          userId: '',
          consentType: ConsentType.analyticsTracking,
        );

        expect(consent.userId, '');
        expect(consent.toJson()['user_id'], '');
      });

      test('handles very long userId', () {
        final longUserId = 'x' * 500;
        final consent = UserConsent(
          userId: longUserId,
          consentType: ConsentType.dataProcessing,
        );

        expect(consent.userId, longUserId);
        expect(consent.toJson()['user_id'], longUserId);
      });

      test('handles version number 0', () {
        final consent = UserConsent(
          userId: 'user123',
          consentType: ConsentType.marketingCommunications,
          consentVersion: 0,
        );

        expect(consent.consentVersion, 0);
      });

      test('handles very high version number', () {
        final consent = UserConsent(
          userId: 'user123',
          consentType: ConsentType.analyticsTracking,
          consentVersion: 999999,
        );

        expect(consent.consentVersion, 999999);
      });
    });

    group('GDPR Compliance Tests', () {
      test('default consent is false (opt-in required)', () {
        for (final type in ConsentType.values) {
          final consent = UserConsent(
            userId: 'user123',
            consentType: type,
          );

          expect(
            consent.consentGiven,
            false,
            reason: 'GDPR requires explicit opt-in: ${type.name} should default to false',
          );
        }
      });

      test('consent can be explicitly granted', () {
        for (final type in ConsentType.values) {
          final consent = UserConsent(
            userId: 'user123',
            consentType: type,
            consentGiven: true,
          );

          expect(consent.consentGiven, true);
        }
      });

      test('consent can be revoked (set to false)', () {
        final consent = UserConsent(
          userId: 'user123',
          consentType: ConsentType.analyticsTracking,
          consentGiven: true,
        );

        expect(consent.consentGiven, true);

        // In practice, you would update via service and create new version
        // but the model should support false values
        final revokedConsent = UserConsent(
          userId: consent.userId,
          consentType: consent.consentType,
          consentGiven: false,
          consentVersion: consent.consentVersion + 1,
        );

        expect(revokedConsent.consentGiven, false);
        expect(revokedConsent.consentVersion, greaterThan(consent.consentVersion));
      });
    });

    group('CCPA Compliance Tests', () {
      test('doNotSellData consent type exists for CCPA', () {
        final consent = UserConsent(
          userId: 'user123',
          consentType: ConsentType.doNotSellData,
        );

        expect(consent.consentType, ConsentType.doNotSellData);
        expect(consent.displayName, contains('CCPA'));
      });

      test('doNotSellData defaults to false (no opt-out by default)', () {
        final consent = UserConsent(
          userId: 'user123',
          consentType: ConsentType.doNotSellData,
        );

        expect(consent.consentGiven, false);
      });

      test('doNotSellData can be set to true (user opts out)', () {
        final consent = UserConsent(
          userId: 'user123',
          consentType: ConsentType.doNotSellData,
          consentGiven: true,
        );

        expect(consent.consentGiven, true);
      });
    });
  });
}
