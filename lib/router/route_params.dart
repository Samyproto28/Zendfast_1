import 'package:go_router/go_router.dart';

/// Type-safe route parameters for routes that accept URL parameters.
///
/// These classes extract and validate parameters from GoRouterState,
/// ensuring type safety and preventing runtime errors from missing/invalid parameters.

/// Parameters for learning article detail route
class ArticleRouteParams {
  final String articleId;

  ArticleRouteParams({required this.articleId});

  /// Extract article ID from GoRouterState path parameters
  static ArticleRouteParams fromState(GoRouterState state) {
    final id = state.pathParameters['id'];
    if (id == null || id.isEmpty) {
      throw ArgumentError('Article ID is required but was not provided');
    }
    return ArticleRouteParams(articleId: id);
  }

  /// Extract article ID from optional query parameters (for deep links)
  static ArticleRouteParams? fromQueryParams(GoRouterState state) {
    final id = state.uri.queryParameters['id'];
    if (id == null || id.isEmpty) {
      return null;
    }
    return ArticleRouteParams(articleId: id);
  }
}

/// Parameters for notification detail route
class NotificationRouteParams {
  final String notificationId;

  NotificationRouteParams({required this.notificationId});

  /// Extract notification ID from GoRouterState path parameters
  static NotificationRouteParams fromState(GoRouterState state) {
    final id = state.pathParameters['id'];
    if (id == null || id.isEmpty) {
      throw ArgumentError('Notification ID is required but was not provided');
    }
    return NotificationRouteParams(notificationId: id);
  }
}

/// Query parameters for redirecting after authentication
class RedirectQueryParams {
  final String? returnTo;

  RedirectQueryParams({this.returnTo});

  /// Extract redirect path from query parameters
  static RedirectQueryParams fromState(GoRouterState state) {
    return RedirectQueryParams(
      returnTo: state.uri.queryParameters['returnTo'],
    );
  }

  /// Build query parameters map for navigation
  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    if (returnTo != null && returnTo!.isNotEmpty) {
      params['returnTo'] = returnTo!;
    }
    return params;
  }
}

/// Extra data that can be passed between routes (not in URL)
class FastingRouteExtra {
  final String? fastType;
  final Duration? duration;
  final DateTime? startTime;

  FastingRouteExtra({
    this.fastType,
    this.duration,
    this.startTime,
  });
}

/// Extra data for learning content
class LearningRouteExtra {
  final String? category;
  final String? searchQuery;

  LearningRouteExtra({
    this.category,
    this.searchQuery,
  });
}
