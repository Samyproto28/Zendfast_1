import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/ui_state.dart';
import '../../providers/ui_state_provider.dart';
import '../../theme/animations.dart';
import 'loading_state.dart';
import 'error_state.dart';
import 'empty_state.dart';

/// Adaptive State Wrapper
///
/// Automatically displays the appropriate UI state (loading, error, empty, or success)
/// based on the global UI state provider. Provides a clean, declarative way to handle
/// different UI states without manual conditional rendering.
///
/// The widget watches the global `uiStateProvider` and renders:
/// 1. LoadingState - when `isLoading == true`
/// 2. ErrorState - when `hasError == true`
/// 3. EmptyState - when `isEmpty == true`
/// 4. Success content (via builder) - when none of the above are true
///
/// Example usage:
/// ```dart
/// AdaptiveStateWrapper(
///   builder: (context) => MySuccessContent(),
///   loadingMessage: 'Cargando datos...',
///   onRetry: () => ref.read(myProvider.notifier).loadData(),
///   onEmptyAction: () => navigateToCreate(),
///   emptyActionText: 'Crear nuevo',
/// )
/// ```
///
/// Example with auth:
/// ```dart
/// AdaptiveStateWrapper(
///   builder: (context) => AuthenticatedDashboard(),
///   onRetry: () => ref.read(authNotifierProvider.notifier).refreshSession(),
/// )
/// ```
///
/// Example with list:
/// ```dart
/// AdaptiveStateWrapper(
///   builder: (context) => ListView(children: items),
///   emptyTitle: 'No hay elementos',
///   emptySubtitle: 'Comienza agregando tu primer elemento',
///   onEmptyAction: () => navigateToCreateItem(),
///   emptyActionText: 'Agregar elemento',
/// )
/// ```
class AdaptiveStateWrapper extends ConsumerWidget {
  /// Builder function for success/idle state content
  final Widget Function(BuildContext context) builder;

  /// Optional loading message to display
  final String? loadingMessage;

  /// Optional size for loading indicator
  final double? loadingSize;

  /// Optional error retry callback
  final VoidCallback? onRetry;

  /// Optional custom error title
  final String? errorTitle;

  /// Optional custom retry button text
  final String? retryText;

  /// Optional empty state primary action
  final VoidCallback? onEmptyAction;

  /// Optional empty state primary action text
  final String? emptyActionText;

  /// Optional empty state secondary action
  final VoidCallback? onEmptySecondaryAction;

  /// Optional empty state secondary action text
  final String? emptySecondaryActionText;

  /// Optional custom empty state title (overrides default from type)
  final String? emptyTitle;

  /// Optional custom empty state subtitle (overrides default from type)
  final String? emptySubtitle;

  /// Optional custom empty state illustration
  final Widget? emptyIllustration;

  /// Whether to use full screen for state widgets
  final bool fullScreen;

  const AdaptiveStateWrapper({
    super.key,
    required this.builder,
    this.loadingMessage,
    this.loadingSize,
    this.onRetry,
    this.errorTitle,
    this.retryText,
    this.onEmptyAction,
    this.emptyActionText,
    this.onEmptySecondaryAction,
    this.emptySecondaryActionText,
    this.emptyTitle,
    this.emptySubtitle,
    this.emptyIllustration,
    this.fullScreen = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(uiStateProvider);

    // Use AnimatedSwitcher for smooth transitions between states
    return AnimatedSwitcher(
      duration: ZendfastAnimations.standard,
      switchInCurve: ZendfastAnimations.emphasizedDecelerateCurve,
      switchOutCurve: ZendfastAnimations.emphasizedAccelerateCurve,
      transitionBuilder: (child, animation) {
        // Fade transition for smooth state changes
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: _buildStateWidget(context, uiState),
    );
  }

  /// Build the appropriate widget based on current state
  Widget _buildStateWidget(BuildContext context, UIState uiState) {
    // Priority: Loading > Error > Empty > Success

    // 1. Loading state
    if (uiState.isLoading) {
      return LoadingState(
        key: const ValueKey('loading'),
        message: loadingMessage,
        size: loadingSize,
        fullScreen: fullScreen,
      );
    }

    // 2. Error state
    if (uiState.hasError) {
      return ErrorState(
        key: const ValueKey('error'),
        message: uiState.errorMessage!,
        title: errorTitle,
        onRetry: onRetry,
        retryText: retryText,
        fullScreen: fullScreen,
      );
    }

    // 3. Empty state
    if (uiState.isEmpty) {
      // Get title and subtitle from state type or use custom overrides
      final type = uiState.emptyStateType ?? EmptyStateType.noData;

      // Use factory constructors if no custom title/subtitle provided
      if (emptyTitle == null && emptySubtitle == null) {
        return _buildFactoryEmptyState(type);
      }

      // Use custom EmptyState if title or subtitle is provided
      return EmptyState(
        key: const ValueKey('empty'),
        type: type,
        title: emptyTitle ?? _getDefaultTitleForType(type),
        subtitle: emptySubtitle ?? _getDefaultSubtitleForType(type),
        illustration: emptyIllustration,
        onPrimaryAction: onEmptyAction,
        primaryActionText: emptyActionText,
        onSecondaryAction: onEmptySecondaryAction,
        secondaryActionText: emptySecondaryActionText,
        fullScreen: fullScreen,
      );
    }

    // 4. Success/idle state - show builder content
    return KeyedSubtree(
      key: const ValueKey('success'),
      child: builder(context),
    );
  }

  /// Build EmptyState using factory constructors for better defaults
  Widget _buildFactoryEmptyState(EmptyStateType type) {
    switch (type) {
      case EmptyStateType.noData:
        return EmptyState.noData(
          key: const ValueKey('empty'),
          title: emptyTitle,
          subtitle: emptySubtitle,
          illustration: emptyIllustration,
          onPrimaryAction: onEmptyAction,
          primaryActionText: emptyActionText,
          fullScreen: fullScreen,
        );
      case EmptyStateType.noResults:
        return EmptyState.noResults(
          key: const ValueKey('empty'),
          title: emptyTitle,
          subtitle: emptySubtitle,
          illustration: emptyIllustration,
          onPrimaryAction: onEmptyAction,
          primaryActionText: emptyActionText,
          fullScreen: fullScreen,
        );
      case EmptyStateType.offline:
        return EmptyState.offline(
          key: const ValueKey('empty'),
          title: emptyTitle,
          subtitle: emptySubtitle,
          illustration: emptyIllustration,
          onPrimaryAction: onEmptyAction ?? onRetry, // Use retry for offline
          primaryActionText: emptyActionText,
          fullScreen: fullScreen,
        );
      case EmptyStateType.noPermission:
        return EmptyState.noPermission(
          key: const ValueKey('empty'),
          title: emptyTitle,
          subtitle: emptySubtitle,
          illustration: emptyIllustration,
          onPrimaryAction: onEmptyAction,
          primaryActionText: emptyActionText,
          fullScreen: fullScreen,
        );
    }
  }

  /// Get default title for empty state type
  String _getDefaultTitleForType(EmptyStateType type) {
    switch (type) {
      case EmptyStateType.noData:
        return 'No hay datos';
      case EmptyStateType.noResults:
        return 'No se encontraron resultados';
      case EmptyStateType.offline:
        return 'Sin conexión';
      case EmptyStateType.noPermission:
        return 'Sin permiso';
    }
  }

  /// Get default subtitle for empty state type
  String _getDefaultSubtitleForType(EmptyStateType type) {
    switch (type) {
      case EmptyStateType.noData:
        return 'Aún no hay información para mostrar';
      case EmptyStateType.noResults:
        return 'Intenta ajustar los filtros o términos de búsqueda';
      case EmptyStateType.offline:
        return 'Verifica tu conexión a internet e intenta nuevamente';
      case EmptyStateType.noPermission:
        return 'No tienes los permisos necesarios para acceder a esta función';
    }
  }
}
