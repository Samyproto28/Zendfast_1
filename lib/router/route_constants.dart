/// Route path constants for type-safe navigation throughout the app.
///
/// Use these constants instead of hardcoding route strings to:
/// - Prevent typos and routing errors
/// - Enable IDE autocomplete and refactoring
/// - Centralize route definitions
class Routes {
  // Prevent instantiation
  Routes._();

  // Auth routes
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';

  // Onboarding routes
  static const String onboarding = '/onboarding';

  // Main app routes
  static const String home = '/home';
  static const String settings = '/settings';
  static const String profile = '/profile';

  // Fasting routes
  static const String fasting = '/fasting';
  static const String fastingStart = '/fasting/start';
  static const String fastingProgress = '/fasting/progress';

  // Hydration route
  static const String hydration = '/hydration';

  // Learning routes
  static const String learning = '/learning';
  static const String learningArticles = '/learning/articles';

  /// Learning article detail route with :id parameter
  /// Use [learningArticle] helper to build the full path
  static const String learningArticleRoute = '/learning/articles/:id';

  // Privacy & GDPR routes
  static const String privacyPolicy = '/privacy-policy';
  static const String dataRights = '/data-rights';
  static const String consentManagement = '/consent-management';

  // Error routes
  static const String notFound = '/404';

  // Helper methods for routes with parameters

  /// Build learning article route with specific article ID
  static String learningArticle(String articleId) {
    return '/learning/articles/$articleId';
  }

  /// Build notification detail route with specific notification ID
  static String notification(String notificationId) {
    return '/notification/$notificationId';
  }
}

/// Route names for named navigation (if needed)
class RouteNames {
  RouteNames._();

  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgot-password';
  static const String onboarding = 'onboarding';
  static const String home = 'home';
  static const String settings = 'settings';
  static const String profile = 'profile';
  static const String fasting = 'fasting';
  static const String fastingStart = 'fasting-start';
  static const String fastingProgress = 'fasting-progress';
  static const String hydration = 'hydration';
  static const String learning = 'learning';
  static const String learningArticle = 'learning-article';
  static const String privacyPolicy = 'privacy-policy';
  static const String dataRights = 'data-rights';
  static const String consentManagement = 'consent-management';
  static const String notFound = 'not-found';
}
