import 'package:flutter_test/flutter_test.dart';
import 'package:zendfast_1/services/analytics_service.dart';

void main() {
  group('AnalyticsService', () {
    late AnalyticsService analyticsService;

    setUp(() {
      analyticsService = AnalyticsService.instance;
    });

    test('should be a singleton instance', () {
      final instance1 = AnalyticsService.instance;
      final instance2 = AnalyticsService.instance;

      expect(instance1, same(instance2));
    });

    test('should log event with name only', () async {
      // This test verifies the method accepts eventName
      expect(
        () async => await analyticsService.logEvent('test_event'),
        returnsNormally,
      );
    });

    test('should log event with name and parameters', () async {
      // This test verifies the method accepts parameters
      expect(
        () async => await analyticsService.logEvent(
          'test_event',
          parameters: {
            'param1': 'value1',
            'param2': 123,
          },
        ),
        returnsNormally,
      );
    });

    test('should handle null parameters gracefully', () async {
      expect(
        () async => await analyticsService.logEvent(
          'test_event',
          parameters: null,
        ),
        returnsNormally,
      );
    });

    test('should complete without throwing for panic_button_used event', () async {
      // Specific test for the panic button analytics event
      expect(
        () async => await analyticsService.logEvent(
          'panic_button_used',
          parameters: {
            'timestamp': DateTime.now().toIso8601String(),
            'fasting_duration_minutes': 180,
            'plan_type': '16:8',
            'elapsed_minutes': 120,
          },
        ),
        returnsNormally,
      );
    });
  });
}
