import 'package:flutter/material.dart';
import '../../theme/spacing.dart';
import '../../theme/animations.dart';

/// Error state widget with WCAG 2.1 AA compliance
///
/// Displays an error message with optional retry functionality.
/// Includes proper accessibility support with touch targets >= 48dp,
/// semantic labels, and screen reader announcements.
///
/// Example usage:
/// ```dart
/// ErrorState(
///   message: 'No se pudo cargar los datos',
///   onRetry: () => loadData(),
/// )
/// ```
class ErrorState extends StatelessWidget {
  /// Error message to display
  final String message;

  /// Optional custom error title (defaults to "Error")
  final String? title;

  /// Optional retry callback - if provided, shows retry button
  final VoidCallback? onRetry;

  /// Optional custom retry button text (defaults to "Reintentar")
  final String? retryText;

  /// Whether to use full screen height
  final bool fullScreen;

  /// Optional custom error icon
  final IconData? icon;

  const ErrorState({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.retryText,
    this.fullScreen = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Widget content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: fullScreen ? MainAxisSize.max : MainAxisSize.min,
      children: [
        // Error icon with semantic label
        Semantics(
          label: 'Error',
          child: Icon(
            icon ?? Icons.error_outline,
            size: 64.0,
            color: colorScheme.error,
          ),
        ),

        ZendfastSpacing.verticalSpaceL,

        // Error title
        Semantics(
          header: true,
          child: Text(
            title ?? 'Error',
            style: textTheme.headlineSmall?.copyWith(
              color: colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        ZendfastSpacing.verticalSpaceM,

        // Error message with live region for screen readers
        Semantics(
          label: message,
          liveRegion: true,
          child: Padding(
            padding: ZendfastSpacing.horizontalL,
            child: Text(
              message,
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),

        // Retry button if callback provided
        if (onRetry != null) ...[
          ZendfastSpacing.verticalSpaceXl,
          Semantics(
            button: true,
            label: retryText ?? 'Reintentar',
            hint: 'Toca para volver a intentar',
            child: FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(retryText ?? 'Reintentar'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(160, 48), // WCAG 48dp minimum touch target
                padding: const EdgeInsets.symmetric(
                  horizontal: ZendfastSpacing.l,
                  vertical: ZendfastSpacing.m,
                ),
              ),
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
}
