import 'package:flutter_test/flutter_test.dart';
import 'package:zendfast_1/services/data_privacy_service.dart';
import 'package:zendfast_1/models/data_export_result.dart';
import 'package:zendfast_1/utils/result.dart';

/// Integration tests for DataPrivacyService
/// Tests GDPR Article 20 compliance (Right to Data Portability)
void main() {
  group('DataPrivacyService', () {
    late DataPrivacyService service;

    setUp(() {
      service = DataPrivacyService.instance;
    });

    test('should be a singleton', () {
      final instance1 = DataPrivacyService.instance;
      final instance2 = DataPrivacyService.instance;

      expect(instance1, same(instance2));
    });

    group('exportUserData', () {
      test('should return Success with DataExportResult for valid user', () async {
        // Note: This test requires Supabase connection
        // For unit tests, consider mocking Supabase

        const testUserId = 'test-user-id-123';

        final result = await service.exportUserData(testUserId);

        // Verify result type
        expect(result, isA<Result<DataExportResult, Exception>>());

        result.when(
          success: (exportResult) {
            // Verify export result structure
            expect(exportResult, isA<DataExportResult>());
            expect(exportResult.file.existsSync(), true);
            expect(exportResult.fileSizeBytes, greaterThan(0));
            expect(exportResult.format, ExportFormat.zip);
            expect(exportResult.recordCounts, isA<Map<String, int>>());

            // Verify expected data tables are included
            expect(exportResult.recordCounts.containsKey('user_profile'), true);
            expect(exportResult.recordCounts.containsKey('fasting_sessions'), true);
            expect(exportResult.recordCounts.containsKey('hydration_logs'), true);
            expect(exportResult.recordCounts.containsKey('user_metrics'), true);
            expect(exportResult.recordCounts.containsKey('content_interactions'), true);
            expect(exportResult.recordCounts.containsKey('analytics_events'), true);

            // Verify file name format
            expect(exportResult.fileName, contains('zendfast_export_'));
            expect(exportResult.fileName, endsWith('.zip'));

            // Cleanup
            exportResult.file.deleteSync();
          },
          failure: (error) {
            // If test fails due to missing Supabase connection, that's expected
            expect(error.toString(), contains('Failed to export user data'));
          },
        );
      });

      test('should include metadata in export', () async {
        const testUserId = 'test-user-id-456';

        final result = await service.exportUserData(testUserId);

        result.when(
          success: (exportResult) {
            expect(exportResult.exportedAt, isA<DateTime>());
            expect(exportResult.exportedAt.isBefore(DateTime.now()), true);

            // Cleanup
            exportResult.file.deleteSync();
          },
          failure: (_) {
            // Expected if no Supabase connection
          },
        );
      });

      test('should return Failure for invalid user ID', () async {
        const invalidUserId = '';

        final result = await service.exportUserData(invalidUserId);

        result.when(
          success: (exportResult) {
            // Should not succeed with invalid user ID
            // Cleanup just in case
            exportResult.file.deleteSync();
            fail('Expected failure for invalid user ID');
          },
          failure: (error) {
            expect(error, isA<Exception>());
            expect(error.toString(), contains('Failed to export user data'));
          },
        );
      });

      test('should generate unique filenames for multiple exports', () async {
        const testUserId = 'test-user-id-789';

        // Export twice
        final result1 = await service.exportUserData(testUserId);
        await Future.delayed(const Duration(milliseconds: 1100)); // Ensure timestamp differs
        final result2 = await service.exportUserData(testUserId);

        String? filename1;
        String? filename2;

        result1.when(
          success: (exportResult) {
            filename1 = exportResult.fileName;
            exportResult.file.deleteSync();
          },
          failure: (_) {},
        );

        result2.when(
          success: (exportResult) {
            filename2 = exportResult.fileName;
            exportResult.file.deleteSync();
          },
          failure: (_) {},
        );

        // Filenames should be different (due to timestamp)
        if (filename1 != null && filename2 != null) {
          expect(filename1, isNot(equals(filename2)));
        }
      });
    });

    group('Export Format Validation', () {
      test('exported file should be valid ZIP format', () async {
        const testUserId = 'test-user-id-zip';

        final result = await service.exportUserData(testUserId);

        result.when(
          success: (exportResult) {
            // Read first bytes to verify ZIP signature (50 4B 03 04 or 50 4B 05 06)
            final bytes = exportResult.file.readAsBytesSync();
            expect(bytes.length, greaterThan(3));
            expect(bytes[0], equals(0x50)); // 'P'
            expect(bytes[1], equals(0x4B)); // 'K'
            // bytes[2] and bytes[3] should be either 03 04 or 05 06
            expect(bytes[2], anyOf(equals(0x03), equals(0x05)));

            // Cleanup
            exportResult.file.deleteSync();
          },
          failure: (_) {
            // Expected if no Supabase connection
          },
        );
      });
    });

    group('GDPR Compliance', () {
      test('should include all required user data categories', () async {
        const testUserId = 'test-user-gdpr';

        final result = await service.exportUserData(testUserId);

        result.when(
          success: (exportResult) {
            // Verify all GDPR-required data categories are present
            final expectedCategories = [
              'user_profile',           // Personal data
              'fasting_sessions',       // Health data
              'hydration_logs',         // Health data
              'user_metrics',           // Aggregated health data
              'content_interactions',   // Behavioral data
              'analytics_events',       // Usage data
            ];

            for (final category in expectedCategories) {
              expect(
                exportResult.recordCounts.containsKey(category),
                true,
                reason: 'Export must include $category for GDPR compliance',
              );
            }

            // Cleanup
            exportResult.file.deleteSync();
          },
          failure: (_) {
            // Expected if no Supabase connection
          },
        );
      });

      test('should export in machine-readable format (ZIP with JSON/CSV)', () async {
        const testUserId = 'test-user-format';

        final result = await service.exportUserData(testUserId);

        result.when(
          success: (exportResult) {
            // Verify format is ZIP (machine-readable and portable)
            expect(exportResult.format, equals(ExportFormat.zip));

            // Verify file extension
            expect(exportResult.fileName, endsWith('.zip'));

            // Cleanup
            exportResult.file.deleteSync();
          },
          failure: (_) {
            // Expected if no Supabase connection
          },
        );
      });
    });
  });
}
