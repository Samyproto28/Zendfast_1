/// Custom widget finders for E2E integration tests
/// Provides reusable finders for common app widgets
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Common widget finders for the app
class AppFinders {
  // === Navigation ===

  /// Find bottom navigation bar
  static Finder get bottomNavBar => find.byType(BottomNavigationBar);

  /// Find navigation bar item by icon
  static Finder navBarItem(IconData icon) => find.byIcon(icon);

  /// Find navigation bar item by text
  static Finder navBarItemByText(String text) => find.text(text);

  // === Buttons ===

  /// Find elevated button by text
  static Finder elevatedButton(String text) {
    return find.ancestor(
      of: find.text(text),
      matching: find.byType(ElevatedButton),
    );
  }

  /// Find text button by text
  static Finder textButton(String text) {
    return find.ancestor(
      of: find.text(text),
      matching: find.byType(TextButton),
    );
  }

  /// Find outlined button by text
  static Finder outlinedButton(String text) {
    return find.ancestor(
      of: find.text(text),
      matching: find.byType(OutlinedButton),
    );
  }

  /// Find icon button by icon
  static Finder iconButton(IconData icon) {
    return find.ancestor(
      of: find.byIcon(icon),
      matching: find.byType(IconButton),
    );
  }

  /// Find floating action button
  static Finder get fab => find.byType(FloatingActionButton);

  // === Input Fields ===

  /// Find text field by label
  static Finder textFieldByLabel(String label) {
    return find.ancestor(
      of: find.text(label),
      matching: find.byType(TextField),
    );
  }

  /// Find text field by hint
  static Finder textFieldByHint(String hint) {
    return find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.hintText == hint,
    );
  }

  /// Find text field by key
  static Finder textFieldByKey(String key) {
    return find.byKey(Key(key));
  }

  // === Dialogs ===

  /// Find alert dialog
  static Finder get alertDialog => find.byType(AlertDialog);

  /// Find dialog by title
  static Finder dialogByTitle(String title) {
    return find.ancestor(
      of: find.text(title),
      matching: find.byType(AlertDialog),
    );
  }

  // === Fasting-specific finders ===

  /// Find "Start Fast" button
  static Finder get startFastButton => find.text('Start Fast');

  /// Find "Complete Fast" button
  static Finder get completeFastButton => find.text('Complete Fast');

  /// Find "End Fast" button (panic button)
  static Finder get endFastButton => find.text('End Fast');

  /// Find timer display (circular progress indicator)
  static Finder get timerDisplay => find.byType(CircularProgressIndicator);

  /// Find fasting plan selection card
  static Finder fastingPlanCard(String planType) {
    return find.ancestor(
      of: find.textContaining(planType),
      matching: find.byType(Card),
    );
  }

  // === Hydration-specific finders ===

  /// Find water intake button
  static Finder waterIntakeButton(int ml) {
    return find.text('${ml}ml');
  }

  /// Find water drop icon
  static Finder get waterDropIcon => find.byIcon(Icons.water_drop);

  // === Onboarding-specific finders ===

  /// Find onboarding page indicator
  static Finder get pageIndicator => find.byType(PageView);

  /// Find "Next" button in onboarding
  static Finder get nextButton => find.text('Next');

  /// Find "Skip" button in onboarding
  static Finder get skipButton => find.text('Skip');

  /// Find "Previous" button in onboarding
  static Finder get previousButton => find.byIcon(Icons.arrow_back);

  /// Find legal acceptance checkbox
  static Finder get legalCheckbox => find.byType(Checkbox);

  /// Find "Accept" or "Agree" button
  static Finder get acceptButton {
    final accept = find.textContaining('Accept');
    if (accept.evaluate().isNotEmpty) return accept;
    return find.textContaining('Agree');
  }

  /// Find "Get Started" button (final onboarding button)
  static Finder get getStartedButton => find.text('Get Started');

  // === Settings-specific finders ===

  /// Find settings list tile by title
  static Finder settingsTile(String title) {
    return find.ancestor(
      of: find.text(title),
      matching: find.byType(ListTile),
    );
  }

  /// Find switch by label
  static Finder switchByLabel(String label) {
    return find.ancestor(
      of: find.text(label),
      matching: find.byType(Switch),
    );
  }

  // === Progress and Loading ===

  /// Find circular progress indicator
  static Finder get loadingIndicator => find.byType(CircularProgressIndicator);

  /// Find linear progress indicator
  static Finder get linearProgress => find.byType(LinearProgressIndicator);

  // === Snackbars and Messages ===

  /// Find snackbar with specific text
  static Finder snackbarWithText(String text) {
    return find.ancestor(
      of: find.text(text),
      matching: find.byType(SnackBar),
    );
  }

  /// Find any snackbar
  static Finder get snackbar => find.byType(SnackBar);

  // === Lists and Scrollables ===

  /// Find list view
  static Finder get listView => find.byType(ListView);

  /// Find scrollable
  static Finder get scrollable => find.byType(Scrollable);

  /// Find list tile by title
  static Finder listTile(String title) {
    return find.ancestor(
      of: find.text(title),
      matching: find.byType(ListTile),
    );
  }

  // === Cards and Containers ===

  /// Find card by content text
  static Finder cardWithText(String text) {
    return find.ancestor(
      of: find.text(text),
      matching: find.byType(Card),
    );
  }

  // === Custom predicates ===

  /// Find widget by predicate
  static Finder byPredicate(bool Function(Widget) predicate) {
    return find.byWidgetPredicate(predicate);
  }

  /// Find enabled button with text
  static Finder enabledButtonWithText(String text) {
    return find.byWidgetPredicate(
      (widget) {
        if (widget is ElevatedButton) {
          return widget.enabled && widget.child.toString().contains(text);
        }
        return false;
      },
    );
  }
}

/// Finders for authentication screens
class AuthFinders {
  /// Find email text field
  static Finder get emailField {
    return find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          (widget.decoration?.labelText?.toLowerCase().contains('email') ??
              false),
    );
  }

  /// Find password text field
  static Finder get passwordField {
    return find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          (widget.decoration?.labelText?.toLowerCase().contains('password') ??
              false),
    );
  }

  /// Find login button
  static Finder get loginButton => find.text('Login');

  /// Find register button
  static Finder get registerButton => find.text('Register');

  /// Find forgot password link
  static Finder get forgotPasswordLink => find.text('Forgot Password?');

  /// Find sign out button
  static Finder get signOutButton => find.text('Sign Out');
}

/// Finders for metrics and statistics
class MetricsFinders {
  /// Find metric card by label
  static Finder metricCard(String label) {
    return find.ancestor(
      of: find.textContaining(label),
      matching: find.byType(Card),
    );
  }

  /// Find streak display
  static Finder get streakDisplay => find.textContaining('streak');

  /// Find total fasts display
  static Finder get totalFastsDisplay => find.textContaining('Total Fasts');

  /// Find average duration display
  static Finder get avgDurationDisplay => find.textContaining('Average');
}

/// Helper class for creating dynamic finders
class DynamicFinders {
  /// Find text containing a pattern
  static Finder textContaining(String pattern) {
    return find.textContaining(pattern, findRichText: true);
  }

  /// Find text matching exactly
  static Finder textExact(String text) {
    return find.text(text);
  }

  /// Find widget by key
  static Finder byKey(String key) {
    return find.byKey(Key(key));
  }

  /// Find first matching widget
  static Finder first(Finder finder) {
    return find.descendant(
      of: finder,
      matching: finder,
      matchRoot: true,
    ).first;
  }

  /// Find last matching widget
  static Finder last(Finder finder) {
    return find.descendant(
      of: finder,
      matching: finder,
      matchRoot: true,
    ).last;
  }
}
