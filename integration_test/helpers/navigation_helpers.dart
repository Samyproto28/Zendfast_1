/// Navigation helper utilities for E2E integration tests
/// Provides common navigation patterns and route verification
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test_helpers.dart';

/// Navigation helper class for common app navigation patterns
class NavigationHelpers {
  /// Navigate to home screen (assumes user is authenticated)
  static Future<void> goToHome(WidgetTester tester) async {
    // Look for home navigation button or icon
    final homeFinder = find.byIcon(Icons.home);
    if (homeFinder.evaluate().isNotEmpty) {
      await tapAndSettle(tester, homeFinder);
    }
  }

  /// Navigate to fasting screen
  static Future<void> goToFasting(WidgetTester tester) async {
    // Look for fasting navigation button
    final fastingFinder = find.byIcon(Icons.timer);
    if (fastingFinder.evaluate().isNotEmpty) {
      await tapAndSettle(tester, fastingFinder);
    } else {
      // Alternative: Look for text-based navigation
      final textFinder = find.text('Fasting');
      if (textFinder.evaluate().isNotEmpty) {
        await tapAndSettle(tester, textFinder);
      }
    }
  }

  /// Navigate to hydration screen
  static Future<void> goToHydration(WidgetTester tester) async {
    // Look for hydration/water icon
    final hydrationFinder = find.byIcon(Icons.water_drop);
    if (hydrationFinder.evaluate().isNotEmpty) {
      await tapAndSettle(tester, hydrationFinder);
    } else {
      // Alternative: Look for text-based navigation
      final textFinder = find.textContaining('Hydration');
      if (textFinder.evaluate().isEmpty) {
        final altTextFinder = find.textContaining('Water');
        if (altTextFinder.evaluate().isNotEmpty) {
          await tapAndSettle(tester, altTextFinder);
        }
      } else {
        await tapAndSettle(tester, textFinder);
      }
    }
  }

  /// Navigate to settings screen
  static Future<void> goToSettings(WidgetTester tester) async {
    final settingsFinder = find.byIcon(Icons.settings);
    if (settingsFinder.evaluate().isNotEmpty) {
      await tapAndSettle(tester, settingsFinder);
    }
  }

  /// Navigate to profile screen
  static Future<void> goToProfile(WidgetTester tester) async {
    final profileFinder = find.byIcon(Icons.person);
    if (profileFinder.evaluate().isNotEmpty) {
      await tapAndSettle(tester, profileFinder);
    }
  }

  /// Navigate back using back button
  static Future<void> goBack(WidgetTester tester) async {
    final backFinder = find.byType(BackButton);
    if (backFinder.evaluate().isNotEmpty) {
      await tapAndSettle(tester, backFinder);
    } else {
      // Alternative: Use Navigator.pop
      final NavigatorState navigator = tester.state(find.byType(Navigator));
      navigator.pop();
      await tester.pumpAndSettle();
    }
  }

  /// Verify current screen by checking for a specific widget or text
  static void verifyScreen(Finder finder) {
    expect(finder, findsOneWidget);
  }

  /// Verify we're on the home screen
  static void verifyOnHomeScreen() {
    // Look for home screen indicators
    final indicators = [
      find.text('ZendFast'),
      find.text('Home'),
      find.byType(BottomNavigationBar),
    ];

    bool found = false;
    for (final indicator in indicators) {
      if (indicator.evaluate().isNotEmpty) {
        found = true;
        break;
      }
    }

    expect(found, isTrue, reason: 'Not on home screen');
  }

  /// Verify we're on the fasting screen
  static void verifyOnFastingScreen() {
    final indicators = [
      find.textContaining('Fasting'),
      find.textContaining('Start Fast'),
      find.byIcon(Icons.timer),
    ];

    bool found = false;
    for (final indicator in indicators) {
      if (indicator.evaluate().isNotEmpty) {
        found = true;
        break;
      }
    }

    expect(found, isTrue, reason: 'Not on fasting screen');
  }

  /// Verify we're on the hydration screen
  static void verifyOnHydrationScreen() {
    final indicators = [
      find.textContaining('Hydration'),
      find.textContaining('Water'),
      find.byIcon(Icons.water_drop),
    ];

    bool found = false;
    for (final indicator in indicators) {
      if (indicator.evaluate().isNotEmpty) {
        found = true;
        break;
      }
    }

    expect(found, isTrue, reason: 'Not on hydration screen');
  }

  /// Verify we're on the settings screen
  static void verifyOnSettingsScreen() {
    expect(
      find.textContaining('Settings'),
      findsWidgets,
      reason: 'Not on settings screen',
    );
  }

  /// Wait for page transition to complete
  static Future<void> waitForTransition(WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
  }
}

/// Onboarding-specific navigation helpers
class OnboardingNavigation {
  /// Go to next page in onboarding
  static Future<void> nextPage(WidgetTester tester) async {
    final nextFinder = find.text('Next');
    if (nextFinder.evaluate().isNotEmpty) {
      await tapAndSettle(tester, nextFinder);
    } else {
      // Alternative: Look for forward arrow or continue button
      final altFinder = find.byIcon(Icons.arrow_forward);
      if (altFinder.evaluate().isNotEmpty) {
        await tapAndSettle(tester, altFinder);
      } else {
        final continueFinder = find.text('Continue');
        if (continueFinder.evaluate().isNotEmpty) {
          await tapAndSettle(tester, continueFinder);
        }
      }
    }
  }

  /// Skip current onboarding page
  static Future<void> skipPage(WidgetTester tester) async {
    final skipFinder = find.text('Skip');
    if (skipFinder.evaluate().isNotEmpty) {
      await tapAndSettle(tester, skipFinder);
    }
  }

  /// Go to previous page in onboarding
  static Future<void> previousPage(WidgetTester tester) async {
    final backFinder = find.byIcon(Icons.arrow_back);
    if (backFinder.evaluate().isNotEmpty) {
      await tapAndSettle(tester, backFinder);
    }
  }

  /// Accept legal terms (required step)
  static Future<void> acceptLegalTerms(WidgetTester tester) async {
    // Look for acceptance checkbox or button
    final checkboxFinder = find.byType(Checkbox);
    if (checkboxFinder.evaluate().isNotEmpty) {
      await tapAndSettle(tester, checkboxFinder.first);
    }

    // Then click accept/agree button
    final acceptFinder = find.textContaining('Accept');
    if (acceptFinder.evaluate().isNotEmpty) {
      await tapAndSettle(tester, acceptFinder);
    } else {
      final agreeFinder = find.textContaining('Agree');
      if (agreeFinder.evaluate().isNotEmpty) {
        await tapAndSettle(tester, agreeFinder);
      }
    }
  }

  /// Complete entire onboarding flow
  static Future<void> completeOnboarding(WidgetTester tester) async {
    debugLog('Starting onboarding flow');

    // Page 1: Intro - Next
    await waitForAnimations(tester);
    await nextPage(tester);
    debugLog('Passed intro page');

    // Page 2: Legal acceptance - Accept and Next
    await waitForAnimations(tester);
    await acceptLegalTerms(tester);
    await nextPage(tester);
    debugLog('Accepted legal terms');

    // Page 3: Questionnaire - Skip or complete
    await waitForAnimations(tester);
    final skipFinder = find.text('Skip');
    if (skipFinder.evaluate().isNotEmpty) {
      await skipPage(tester);
    } else {
      await nextPage(tester);
    }
    debugLog('Completed/skipped questionnaire');

    // Page 4: Paywall - Skip
    await waitForAnimations(tester);
    final paywallSkipFinder = find.text('Skip');
    if (paywallSkipFinder.evaluate().isNotEmpty) {
      await skipPage(tester);
    } else {
      await nextPage(tester);
    }
    debugLog('Skipped paywall');

    // Page 5: Detox recommendation - Next/Finish
    await waitForAnimations(tester);
    final finishFinder = find.text('Get Started');
    if (finishFinder.evaluate().isNotEmpty) {
      await tapAndSettle(tester, finishFinder);
    } else {
      await nextPage(tester);
    }
    debugLog('Completed onboarding');

    await waitForAnimations(tester);
  }
}

/// Dialog helpers for common app dialogs
class DialogHelpers {
  /// Confirm a dialog by tapping the confirm button
  static Future<void> confirm(WidgetTester tester) async {
    final confirmFinders = [
      find.text('Confirm'),
      find.text('Yes'),
      find.text('OK'),
      find.text('Complete'),
    ];

    for (final finder in confirmFinders) {
      if (finder.evaluate().isNotEmpty) {
        await tapAndSettle(tester, finder);
        return;
      }
    }

    throw Exception('No confirm button found in dialog');
  }

  /// Cancel a dialog
  static Future<void> cancel(WidgetTester tester) async {
    final cancelFinders = [
      find.text('Cancel'),
      find.text('No'),
      find.text('Dismiss'),
    ];

    for (final finder in cancelFinders) {
      if (finder.evaluate().isNotEmpty) {
        await tapAndSettle(tester, finder);
        return;
      }
    }

    throw Exception('No cancel button found in dialog');
  }

  /// Wait for dialog to appear
  static Future<void> waitForDialog(WidgetTester tester) async {
    await waitForWidget(tester, find.byType(AlertDialog));
  }

  /// Verify dialog is showing
  static void verifyDialogShowing() {
    expect(find.byType(AlertDialog), findsOneWidget);
  }

  /// Verify dialog is not showing
  static void verifyDialogNotShowing() {
    expect(find.byType(AlertDialog), findsNothing);
  }
}
