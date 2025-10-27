import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/animations.dart';

/// Loading state widget with WCAG 2.1 AA compliance
///
/// Displays a centered loading indicator with optional descriptive text.
/// Includes proper accessibility support for screen readers.
///
/// Example usage:
/// ```dart
/// LoadingState()
/// LoadingState(message: 'Cargando datos...')
/// ```
class LoadingState extends StatelessWidget {
  /// Optional message to display below the loading indicator
  final String? message;

  /// Size of the loading indicator
  final double? size;

  /// Whether to use full screen height
  final bool fullScreen;

  const LoadingState({
    super.key,
    this.message,
    this.size,
    this.fullScreen = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    Widget content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: fullScreen ? MainAxisSize.max : MainAxisSize.min,
      children: [
        // Loading indicator with accessibility
        Semantics(
          label: 'Cargando',
          liveRegion: true,
          child: SizedBox(
            width: size ?? 48.0,
            height: size ?? 48.0,
            child: CircularProgressIndicator(
              strokeWidth: 3.0,
              valueColor: AlwaysStoppedAnimation<Color>(
                colorScheme.primary,
              ),
            ),
          ),
        ),

        // Optional descriptive message
        if (message != null) ...[
          ZendfastSpacing.verticalSpaceL,
          Semantics(
            label: message,
            liveRegion: true,
            child: Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? ZendfastColors.darkTextSecondary
                    : ZendfastColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );

    // Apply fade-in animation
    content = ZendfastAnimations.fadeIn(
      duration: ZendfastAnimations.fast,
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
