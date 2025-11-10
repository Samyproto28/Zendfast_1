import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/fasting_state.dart';
import '../../providers/timer_provider.dart';
import '../../theme/colors.dart';

/// Contextual information display for fasting session
///
/// Shows:
/// - Current phase (fasting/eating window/paused)
/// - Elapsed time vs remaining time
/// - Next milestone based on plan type
///
/// Uses AnimatedSwitcher for smooth transitions between states.
class FastingContextInfo extends ConsumerStatefulWidget {
  const FastingContextInfo({super.key});

  @override
  ConsumerState<FastingContextInfo> createState() => _FastingContextInfoState();
}

class _FastingContextInfoState extends ConsumerState<FastingContextInfo> {
  bool _showRemaining = true; // Toggle between elapsed/remaining

  /// Get phase label with emoji based on fasting state
  String _getPhaseLabel(FastingState state) {
    switch (state) {
      case FastingState.fasting:
        return '🌙 Ayunando';
      case FastingState.paused:
        return '⏸️ Pausado';
      case FastingState.completed:
        return '✅ Completado';
      case FastingState.idle:
        return '🍽️ Listo para comenzar';
    }
  }

  /// Get phase description based on fasting state
  String _getPhaseDescription(FastingState state, int elapsedHours, int remainingHours) {
    switch (state) {
      case FastingState.fasting:
        return 'Mantén el enfoque y la hidratación';
      case FastingState.paused:
        return 'Reanudar cuando estés listo';
      case FastingState.completed:
        return '¡Excelente trabajo!';
      case FastingState.idle:
        return 'Selecciona un plan e inicia';
    }
  }

  /// Calculate next milestone message
  String _getNextMilestone(
    FastingState state,
    int remainingHours,
    int durationMinutes,
  ) {
    if (state == FastingState.idle || state == FastingState.completed) {
      return '';
    }

    if (remainingHours <= 0) {
      return '¡Meta alcanzada!';
    }

    final milestones = _calculateMilestones(durationMinutes);

    // Find the next milestone
    for (final milestone in milestones) {
      if (remainingHours >= (milestone['hours'] as int)) {
        return '${milestone['hours']} horas hasta ${milestone['label']}';
      }
    }

    return '$remainingHours horas restantes';
  }

  /// Calculate milestone points based on plan duration
  List<Map<String, dynamic>> _calculateMilestones(int durationMinutes) {
    final durationHours = durationMinutes / 60;
    final milestones = <Map<String, dynamic>>[];

    if (durationHours >= 12) {
      milestones.add({'hours': 12, 'label': 'fase de cetosis'});
    }
    if (durationHours >= 16) {
      milestones.add({'hours': 16, 'label': 'autofagia'});
    }
    if (durationHours >= 18) {
      milestones.add({'hours': 18, 'label': 'beneficios máximos'});
    }
    if (durationHours >= 24) {
      milestones.add({'hours': 24, 'label': 'ayuno extendido'});
    }

    // Sort in descending order
    milestones.sort((a, b) => (b['hours'] as int).compareTo(a['hours'] as int));

    return milestones;
  }

  /// Format hours and minutes nicely
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '$hours h $minutes min';
    } else if (hours > 0) {
      return '$hours horas';
    } else {
      return '$minutes minutos';
    }
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Get current state data
    final fastingState = timerState?.state ?? FastingState.idle;
    final elapsedMs = timerState?.elapsedMilliseconds ?? 0;
    final remainingMs = timerState?.remainingMilliseconds ?? 0;
    final durationMinutes = timerState?.durationMinutes ?? 960; // Default 16h

    final elapsedDuration = Duration(milliseconds: elapsedMs);
    final remainingDuration = Duration(milliseconds: remainingMs);
    final elapsedHours = elapsedDuration.inHours;
    final remainingHours = remainingDuration.inHours;

    final phaseLabel = _getPhaseLabel(fastingState);
    final phaseDescription = _getPhaseDescription(fastingState, elapsedHours, remainingHours);
    final nextMilestone = _getNextMilestone(fastingState, remainingHours, durationMinutes);

    return Semantics(
      label: 'Información del ayuno',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Phase label with icon
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: animation,
                    child: child,
                  ),
                );
              },
              child: Text(
                phaseLabel,
                key: ValueKey(phaseLabel),
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: fastingState == FastingState.fasting
                      ? ZendfastColors.secondaryGreen
                      : colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 8),

            // Phase description
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                phaseDescription,
                key: ValueKey(phaseDescription),
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            if (fastingState == FastingState.fasting || fastingState == FastingState.paused) ...[
              const SizedBox(height: 24),

              // Time information toggle
              InkWell(
                onTap: () {
                  setState(() {
                    _showRemaining = !_showRemaining;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _showRemaining ? Icons.timer_outlined : Icons.timelapse,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                        child: Text(
                          _showRemaining
                              ? '${_formatDuration(remainingDuration)} restantes'
                              : '${_formatDuration(elapsedDuration)} transcurridos',
                          key: ValueKey(_showRemaining),
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Next milestone
              if (nextMilestone.isNotEmpty)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Container(
                    key: ValueKey(nextMilestone),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: ZendfastColors.secondaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.flag_outlined,
                          size: 16,
                          color: ZendfastColors.secondaryGreen,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          nextMilestone,
                          style: textTheme.bodySmall?.copyWith(
                            color: ZendfastColors.secondaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
