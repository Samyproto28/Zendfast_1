/// Common test helper utilities for E2E integration tests
/// Provides setup, teardown, and common test operations
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Initialize integration test binding
/// Call this at the beginning of each test file
void initializeIntegrationTest() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
}

/// Common test setup operations
class TestSetup {
  /// Initialize test environment
  static Future<void> initialize() async {
    // Ensure Flutter test binding is initialized
    TestWidgetsFlutterBinding.ensureInitialized();
  }

  /// Clean up after tests
  static Future<void> cleanup() async {
    // Add any cleanup operations here
    // e.g., clear test database, reset state, etc.
  }
}

/// Wait for all animations and async operations to complete
Future<void> waitForAnimations(WidgetTester tester) async {
  await tester.pumpAndSettle(const Duration(seconds: 5));
}

/// Wait for a specific widget to appear
Future<void> waitForWidget(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final end = DateTime.now().add(timeout);

  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));

    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }

  throw Exception('Widget not found within timeout: $finder');
}

/// Wait for a widget to disappear
Future<void> waitForWidgetToDisappear(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final end = DateTime.now().add(timeout);

  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));

    if (finder.evaluate().isEmpty) {
      return;
    }
  }

  throw Exception('Widget still visible after timeout: $finder');
}

/// Scroll until a widget is visible
Future<void> scrollUntilVisible(
  WidgetTester tester,
  Finder finder,
  Finder scrollable, {
  double delta = 100.0,
  int maxScrolls = 50,
}) async {
  for (var i = 0; i < maxScrolls; i++) {
    if (finder.evaluate().isNotEmpty) {
      return;
    }

    await tester.drag(scrollable, Offset(0, -delta));
    await tester.pumpAndSettle();
  }

  throw Exception('Widget not found after scrolling: $finder');
}

/// Tap a widget and wait for animations
Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Enter text in a text field and wait for animations
Future<void> enterTextAndSettle(
  WidgetTester tester,
  Finder finder,
  String text,
) async {
  await tester.enterText(finder, text);
  await tester.pumpAndSettle();
}

/// Verify a widget exists and is visible
void verifyVisible(Finder finder) {
  expect(finder, findsOneWidget);
}

/// Verify a widget does not exist
void verifyNotFound(Finder finder) {
  expect(finder, findsNothing);
}

/// Verify multiple widgets exist
void verifyCount(Finder finder, int count) {
  expect(finder, findsNWidgets(count));
}

/// Print debug message with timestamp (for test debugging)
void debugLog(String message) {
  final timestamp = DateTime.now().toIso8601String();
  debugPrint('[$timestamp] $message');
}

/// Delay helper for UI interactions
Future<void> delay(Duration duration) async {
  await Future.delayed(duration);
}

/// Take a screenshot (for debugging failed tests)
/// Note: Only works with integration_test binding
Future<void> takeScreenshot(
  WidgetTester tester,
  String name,
) async {
  final binding = IntegrationTestWidgetsFlutterBinding.instance;
  await binding.takeScreenshot(name);
}

/// Verify text appears somewhere on screen
void verifyTextExists(String text) {
  expect(find.textContaining(text), findsWidgets);
}

/// Verify text appears exactly once on screen
void verifyTextExistsOnce(String text) {
  expect(find.text(text), findsOneWidget);
}

/// Extension methods for easier testing
extension WidgetTesterExtensions on WidgetTester {
  /// Tap and settle in one call
  Future<void> tapWidget(Finder finder) async {
    await tap(finder);
    await pumpAndSettle();
  }

  /// Enter text and settle in one call
  Future<void> typeText(Finder finder, String text) async {
    await enterText(finder, text);
    await pumpAndSettle();
  }

  /// Wait for widget to appear
  Future<void> waitFor(Finder finder, {Duration? timeout}) async {
    await waitForWidget(this, finder, timeout: timeout ?? const Duration(seconds: 10));
  }

  /// Scroll to widget
  Future<void> scrollTo(Finder finder, Finder scrollable) async {
    await scrollUntilVisible(this, finder, scrollable);
  }
}

/// Test matcher helpers
class TestMatchers {
  /// Matcher for checking if a widget is enabled
  static Matcher isEnabled() {
    return isNot(isA<Widget>().having(
      (w) => (w as dynamic).enabled,
      'enabled',
      false,
    ));
  }

  /// Matcher for checking if text contains a substring
  static Matcher containsText(String substring) {
    return contains(substring);
  }
}
