import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/fasting_state.dart';
import '../../providers/timer_provider.dart';
import '../../theme/colors.dart';

/// Large timer display with dynamic colors based on fasting state
///
/// Shows elapsed time in HH:MM:SS format with 48sp bold typography.
/// Colors change smoothly based on current fasting state:
/// - Fasting: Green (growth, active)
/// - Paused: Orange (caution, paused)
/// - Idle: Grey (neutral, waiting)
/// - Completed: Teal (success, primary)
class FastingTimerDisplay extends ConsumerWidget {
  const FastingTimerDisplay({super.key});

  /// Get the appropriate color for the current fasting state
  Color _getTimerColor(FastingState state, ColorScheme colorScheme) {
    switch (state) {
      case FastingState.fasting:
        return ZendfastColors.secondaryGreen; // Active fasting - green
      case FastingState.paused:
        return ZendfastColors.panicOrange; // Paused - orange/yellow
      case FastingState.completed:
        return colorScheme.primary; // Completed - primary teal
      case FastingState.idle:
        return colorScheme.onSurfaceVariant; // Idle - grey
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // Get current state and formatted time
    final fastingState = timerState?.state ?? FastingState.idle;
    final displayTime = timerState?.formattedElapsedTime ?? '00:00:00';
    final timerColor = _getTimerColor(fastingState, colorScheme);

    return Semantics(
      label: 'Timer: $displayTime',
      value: 'Estado: ${fastingState.displayName}',
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        style: GoogleFonts.inter(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: timerColor,
          // Use tabular figures for consistent width during updates
          fontFeatures: const [
            FontFeature.tabularFigures(),
          ],
          letterSpacing: 2.0,
        ),
        child: Text(
          displayTime,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
