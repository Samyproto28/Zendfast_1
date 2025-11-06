import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_constants.dart';

/// Extension on BuildContext for type-safe navigation using GoRouter.
///
/// These helper methods provide:
/// - Type safety for navigation calls
/// - Centralized navigation logic
/// - Easier refactoring and maintenance
/// - IDE autocomplete support
extension AppNavigation on BuildContext {
  // Auth navigation

  void goToLogin({String? returnTo}) {
    if (returnTo != null) {
      go('${Routes.login}?returnTo=$returnTo');
    } else {
      go(Routes.login);
    }
  }

  void goToRegister() => go(Routes.register);

  void goToForgotPassword() => go(Routes.forgotPassword);

  // Main app navigation

  void goToHome() => go(Routes.home);

  void goToSettings() => go(Routes.settings);

  void goToProfile() => go(Routes.profile);

  // Fasting navigation

  void goToFasting() => go(Routes.fasting);

  void goToFastingStart() => go(Routes.fastingStart);

  void goToFastingProgress() => go(Routes.fastingProgress);

  // Hydration navigation

  void goToHydration() => go(Routes.hydration);

  // Learning navigation

  void goToLearning() => go(Routes.learning);

  void goToLearningArticle(String articleId) {
    go(Routes.learningArticle(articleId));
  }

  // Privacy & GDPR navigation

  void goToPrivacyPolicy() => go(Routes.privacyPolicy);

  void goToDataRights() => go(Routes.dataRights);

  void goToConsentManagement() => go(Routes.consentManagement);

  // Onboarding navigation

  void goToOnboarding() => go(Routes.onboarding);

  // Push navigation (adds to navigation stack instead of replacing)

  void pushToSettings() => push(Routes.settings);

  void pushToProfile() => push(Routes.profile);

  void pushToLearningArticle(String articleId) {
    push(Routes.learningArticle(articleId));
  }

  void pushToPrivacyPolicy() => push(Routes.privacyPolicy);

  void pushToDataRights() => push(Routes.dataRights);

  void pushToConsentManagement() => push(Routes.consentManagement);

  // Navigation helpers

  /// Pop the current route if possible, otherwise go to home
  void popOrGoHome() {
    if (canPop()) {
      pop();
    } else {
      goToHome();
    }
  }

  /// Replace current route (useful for post-auth redirects)
  void replaceWithHome() => go(Routes.home);

  void replaceWithLogin() => go(Routes.login);
}

/// Extension for getting the current route information
extension RouteInfo on BuildContext {
  /// Get the current route path
  String? get currentRoute {
    final router = GoRouter.of(this);
    return router.routeInformationProvider.value.uri.path;
  }

  /// Check if current route matches a specific path
  bool isCurrentRoute(String path) {
    return currentRoute == path;
  }

  /// Check if user is on an auth route
  bool get isOnAuthRoute {
    final route = currentRoute;
    return route?.startsWith('/auth') ?? false;
  }

  /// Check if user is on a protected route
  bool get isOnProtectedRoute {
    final route = currentRoute;
    if (route == null) return false;
    return !isOnAuthRoute &&
        route != Routes.onboarding &&
        route != Routes.privacyPolicy &&
        route != '/';
  }
}
