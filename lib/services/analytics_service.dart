/// Analytics service for tracking user events and interactions.
///
/// This is a minimal implementation that logs events to the console.
/// In the future, this can be enhanced with Firebase Analytics or other
/// analytics platforms.
class AnalyticsService {
  // Singleton pattern
  static final AnalyticsService instance = AnalyticsService._internal();

  AnalyticsService._internal();

  /// Logs an analytics event with optional parameters.
  ///
  /// [eventName] The name of the event to log.
  /// [parameters] Optional map of event parameters.
  ///
  /// Example:
  /// ```dart
  /// AnalyticsService.instance.logEvent(
  ///   'panic_button_used',
  ///   parameters: {
  ///     'timestamp': DateTime.now().toIso8601String(),
  ///     'fasting_duration_minutes': 180,
  ///   },
  /// );
  /// ```
  Future<void> logEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
  }) async {
    final timestamp = DateTime.now().toIso8601String();
    final paramString = parameters != null ? ', Params: $parameters' : '';

    // Log to console for now
    // In production, this would send to Firebase Analytics or similar
    print('[Analytics] [$timestamp] Event: $eventName$paramString');

    // Fire-and-forget pattern - return immediately
    return;
  }
}
