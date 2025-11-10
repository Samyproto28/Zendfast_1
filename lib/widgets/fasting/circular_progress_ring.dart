import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/fasting_state.dart';
import '../../providers/timer_provider.dart';
import '../../theme/colors.dart';
import 'fasting_timer_display.dart';

/// Circular progress ring that wraps around the timer display
///
/// Shows fasting progress as a circular indicator with dynamic colors.
/// The timer display is positioned in the center of the ring.
/// Progress animates smoothly as the timer updates.
class CircularProgressRing extends ConsumerWidget {
  const CircularProgressRing({super.key});

  /// Get the appropriate color for the current fasting state
  Color _getProgressColor(FastingState state, ColorScheme colorScheme) {
    switch (state) {
      case FastingState.fasting:
        return ZendfastColors.secondaryGreen; // Active fasting - green
      case FastingState.paused:
        return ZendfastColors.panicOrange; // Paused - orange
      case FastingState.completed:
        return colorScheme.primary; // Completed - primary teal
      case FastingState.idle:
        return colorScheme.onSurfaceVariant.withValues(alpha: 0.3); // Idle - light grey
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // Get current state and progress
    final fastingState = timerState?.state ?? FastingState.idle;
    final progress = timerState?.progress ?? 0.0;
    final progressColor = _getProgressColor(fastingState, colorScheme);

    return Semantics(
      label: 'Progreso del ayuno',
      value: '${(progress * 100).toStringAsFixed(0)}% completado',
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background circle (track)
            SizedBox(
              width: 280,
              height: 280,
              child: CircularProgressIndicator(
                value: 1.0, // Full circle as background
                strokeWidth: 8,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
            // Animated progress circle
            SizedBox(
              width: 280,
              height: 280,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                tween: Tween<double>(
                  begin: 0.0,
                  end: progress,
                ),
                builder: (context, animatedProgress, child) {
                  return CircularProgressIndicator(
                    value: animatedProgress,
                    strokeWidth: 8,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    strokeCap: StrokeCap.round,
                  );
                },
              ),
            ),
            // Timer display in center
            const FastingTimerDisplay(),
          ],
        ),
      ),
    );
  }
}
