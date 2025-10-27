import 'package:flutter/material.dart';
import '../../theme/spacing.dart';
import '../../theme/animations.dart';

/// Empty state widget with WCAG 2.1 AA compliance
///
/// Displays an empty state message with optional illustration and actions.
/// Supports multiple variants for different contexts (no data, no results, offline, etc.).
/// Includes proper accessibility support with touch targets >= 48dp and semantic labels.
///
/// Example usage:
/// ```dart
/// EmptyState(
///   type: EmptyStateType.noData,
///   title: 'No hay datos',
///   subtitle: 'Comienza agregando tu primer elemento',
///   onPrimaryAction: () => navigateToCreate(),
///   primaryActionText: 'Crear nuevo',
/// )
/// ```
class EmptyState extends StatelessWidget {
  /// Type of empty state for context-aware defaults
  final EmptyStateType type;

  /// Title to display
  final String title;

  /// Subtitle/description text
  final String subtitle;

  /// Optional custom illustration widget (icon, image, or custom widget)
  final Widget? illustration;

  /// Optional primary action callback
  final VoidCallback? onPrimaryAction;

  /// Primary action button text
  final String? primaryActionText;

  /// Optional secondary action callback
  final VoidCallback? onSecondaryAction;

  /// Secondary action button text
  final String? secondaryActionText;

  /// Whether to use full screen height
  final bool fullScreen;

  const EmptyState({
    super.key,
    this.type = EmptyStateType.noData,
    required this.title,
    required this.subtitle,
    this.illustration,
    this.onPrimaryAction,
    this.primaryActionText,
    this.onSecondaryAction,
    this.secondaryActionText,
    this.fullScreen = true,
  });

  /// Factory constructor for "no data" variant
  factory EmptyState.noData({
    Key? key,
    String? title,
    String? subtitle,
    Widget? illustration,
    VoidCallback? onPrimaryAction,
    String? primaryActionText,
    bool fullScreen = true,
  }) {
    return EmptyState(
      key: key,
      type: EmptyStateType.noData,
      title: title ?? 'No hay datos',
      subtitle: subtitle ?? 'Aún no hay información para mostrar',
      illustration: illustration,
      onPrimaryAction: onPrimaryAction,
      primaryActionText: primaryActionText,
      fullScreen: fullScreen,
    );
  }

  /// Factory constructor for "no results" variant
  factory EmptyState.noResults({
    Key? key,
    String? title,
    String? subtitle,
    Widget? illustration,
    VoidCallback? onPrimaryAction,
    String? primaryActionText,
    bool fullScreen = true,
  }) {
    return EmptyState(
      key: key,
      type: EmptyStateType.noResults,
      title: title ?? 'No se encontraron resultados',
      subtitle: subtitle ?? 'Intenta ajustar los filtros o términos de búsqueda',
      illustration: illustration,
      onPrimaryAction: onPrimaryAction,
      primaryActionText: primaryActionText,
      fullScreen: fullScreen,
    );
  }

  /// Factory constructor for "offline" variant
  factory EmptyState.offline({
    Key? key,
    String? title,
    String? subtitle,
    Widget? illustration,
    VoidCallback? onPrimaryAction,
    String? primaryActionText,
    bool fullScreen = true,
  }) {
    return EmptyState(
      key: key,
      type: EmptyStateType.offline,
      title: title ?? 'Sin conexión',
      subtitle: subtitle ?? 'Verifica tu conexión a internet e intenta nuevamente',
      illustration: illustration,
      onPrimaryAction: onPrimaryAction,
      primaryActionText: primaryActionText ?? 'Reintentar',
      fullScreen: fullScreen,
    );
  }

  /// Factory constructor for "no permission" variant
  factory EmptyState.noPermission({
    Key? key,
    String? title,
    String? subtitle,
    Widget? illustration,
    VoidCallback? onPrimaryAction,
    String? primaryActionText,
    bool fullScreen = true,
  }) {
    return EmptyState(
      key: key,
      type: EmptyStateType.noPermission,
      title: title ?? 'Sin permiso',
      subtitle: subtitle ?? 'No tienes los permisos necesarios para acceder a esta función',
      illustration: illustration,
      onPrimaryAction: onPrimaryAction,
      primaryActionText: primaryActionText,
      fullScreen: fullScreen,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Widget content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: fullScreen ? MainAxisSize.max : MainAxisSize.min,
      children: [
        // Illustration (custom widget or default icon)
        if (illustration != null)
          Semantics(
            image: true,
            label: _getSemanticLabelForType(type),
            child: illustration!,
          )
        else
          Semantics(
            image: true,
            label: _getSemanticLabelForType(type),
            child: Icon(
              _getIconForType(type),
              size: 80.0,
              color: colorScheme.onSurfaceVariant,
            ),
          ),

        ZendfastSpacing.verticalSpaceL,

        // Title
        Semantics(
          header: true,
          child: Padding(
            padding: ZendfastSpacing.horizontalL,
            child: Text(
              title,
              style: textTheme.headlineSmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),

        ZendfastSpacing.verticalSpaceM,

        // Subtitle
        Padding(
          padding: ZendfastSpacing.horizontalL,
          child: Text(
            subtitle,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Actions
        if (onPrimaryAction != null || onSecondaryAction != null) ...[
          ZendfastSpacing.verticalSpaceXl,
          Padding(
            padding: ZendfastSpacing.horizontalL,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Primary action
                if (onPrimaryAction != null)
                  Semantics(
                    button: true,
                    label: primaryActionText ?? 'Acción principal',
                    child: FilledButton(
                      onPressed: onPrimaryAction,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48), // WCAG 48dp minimum
                        padding: const EdgeInsets.symmetric(
                          horizontal: ZendfastSpacing.l,
                          vertical: ZendfastSpacing.m,
                        ),
                      ),
                      child: Text(primaryActionText ?? 'Comenzar'),
                    ),
                  ),

                // Secondary action
                if (onSecondaryAction != null) ...[
                  ZendfastSpacing.verticalSpaceM,
                  Semantics(
                    button: true,
                    label: secondaryActionText ?? 'Acción secundaria',
                    child: OutlinedButton(
                      onPressed: onSecondaryAction,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48), // WCAG 48dp minimum
                        padding: const EdgeInsets.symmetric(
                          horizontal: ZendfastSpacing.l,
                          vertical: ZendfastSpacing.m,
                        ),
                      ),
                      child: Text(secondaryActionText ?? 'Ver más'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );

    // Apply fade-slide animation
    content = ZendfastAnimations.fadeSlideIn(
      duration: ZendfastAnimations.standard,
      child: content,
    );

    // Center the content if full screen
    if (fullScreen) {
      content = Center(child: content);
    }

    return Padding(
      padding: ZendfastSpacing.allM,
      child: content,
    );
  }

  /// Get default icon for empty state type
  IconData _getIconForType(EmptyStateType type) {
    switch (type) {
      case EmptyStateType.noData:
        return Icons.inbox_outlined;
      case EmptyStateType.noResults:
        return Icons.search_off;
      case EmptyStateType.offline:
        return Icons.wifi_off;
      case EmptyStateType.noPermission:
        return Icons.lock_outline;
    }
  }

  /// Get semantic label for empty state type
  String _getSemanticLabelForType(EmptyStateType type) {
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
}

/// Enum for different types of empty states
enum EmptyStateType {
  /// No data available (first time, empty list)
  noData,

  /// Search/filter returned no results
  noResults,

  /// Device is offline
  offline,

  /// User lacks permission
  noPermission,
}
