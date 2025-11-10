import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zendfast_1/services/breathing_exercise_service.dart';
import 'package:zendfast_1/theme/colors.dart';
import 'package:zendfast_1/theme/spacing.dart';
import 'package:zendfast_1/widgets/breathing/breathing_timer_widget.dart';

/// Screen for 5-minute breathing exercise using 4-7-8 technique.
///
/// Features:
/// - Animated breathing visualization via BreathingTimerWidget
/// - Start/pause/resume/stop controls
/// - Timer countdown (5:00 to 0:00)
/// - Phase instructions (inhale/hold/exhale)
/// - Completion celebration
class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key});

  @override
  State<BreathingExerciseScreen> createState() =>
      _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen> {
  final _service = BreathingExerciseService.instance;

  @override
  void dispose() {
    // Reset service when leaving screen
    _service.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Ejercicio de Respiración'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: _service.stateStream,
          initialData: _service.currentState,
          builder: (context, snapshot) {
            final state = snapshot.data ?? _service.currentState;

            return Column(
              children: [
                const SizedBox(height: ZendfastSpacing.xl),

                // Instructions
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: ZendfastSpacing.l),
                  child: Text(
                    _getHeaderText(state.isCompleted, state.isRunning),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: ZendfastSpacing.m),

                // Subtitle
                if (!state.isCompleted)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: ZendfastSpacing.l),
                    child: Text(
                      'Técnica 4-7-8: Inhala 4s, Mantén 7s, Exhala 8s',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const Spacer(),

                // Breathing timer widget (animated circle)
                const BreathingTimerWidget(),

                const Spacer(),

                // Timer countdown
                if (!state.isCompleted)
                  Text(
                    state.formattedTime,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),

                const SizedBox(height: ZendfastSpacing.xl),

                // Control buttons
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: ZendfastSpacing.l),
                  child: _buildControlButtons(state, theme),
                ),

                const SizedBox(height: ZendfastSpacing.xl),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Returns header text based on state
  String _getHeaderText(bool isCompleted, bool isRunning) {
    if (isCompleted) {
      return '¡Excelente trabajo! 🎉';
    }
    if (isRunning) {
      return 'Sigue el ritmo de la respiración';
    }
    return 'Prepárate para comenzar';
  }

  /// Builds control buttons based on state
  Widget _buildControlButtons(dynamic state, ThemeData theme) {
    if (state.isCompleted) {
      // Completion state - show "Finalizar" button
      return SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: FilledButton.styleFrom(
            backgroundColor: ZendfastColors.secondaryGreen,
            padding:
                const EdgeInsets.symmetric(vertical: ZendfastSpacing.m + 4),
          ),
          child: const Text(
            'Finalizar',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    if (!state.isRunning) {
      // Idle or paused state
      return Column(
        children: [
          // Start or Resume button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                HapticFeedback.mediumImpact();
                if (state.remainingSeconds == 300) {
                  // Start from beginning
                  await _service.start();
                } else {
                  // Resume
                  await _service.resume();
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: ZendfastColors.secondaryGreen,
                padding:
                    const EdgeInsets.symmetric(vertical: ZendfastSpacing.m + 4),
              ),
              child: Text(
                state.remainingSeconds == 300 ? 'Comenzar' : 'Reanudar',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          // Stop button (only if paused)
          if (state.remainingSeconds < 300) ...[
            const SizedBox(height: ZendfastSpacing.m),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  HapticFeedback.mediumImpact();
                  final confirmed = await _showStopConfirmation();
                  if (confirmed == true && mounted) {
                    await _service.stop();
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: ZendfastColors.error,
                  side: const BorderSide(color: ZendfastColors.error),
                  padding: const EdgeInsets.symmetric(
                      vertical: ZendfastSpacing.m + 4),
                ),
                child: const Text(
                  'Detener',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ],
      );
    }

    // Running state - show pause and stop
    return Column(
      children: [
        // Pause button
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () async {
              HapticFeedback.mediumImpact();
              await _service.pause();
            },
            style: FilledButton.styleFrom(
              backgroundColor: ZendfastColors.panicOrange,
              padding:
                  const EdgeInsets.symmetric(vertical: ZendfastSpacing.m + 4),
            ),
            child: const Text(
              'Pausar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),

        const SizedBox(height: ZendfastSpacing.m),

        // Stop button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () async {
              HapticFeedback.mediumImpact();
              final confirmed = await _showStopConfirmation();
              if (confirmed == true && mounted) {
                await _service.stop();
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: ZendfastColors.error,
              side: const BorderSide(color: ZendfastColors.error),
              padding:
                  const EdgeInsets.symmetric(vertical: ZendfastSpacing.m + 4),
            ),
            child: const Text(
              'Detener',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  /// Shows confirmation dialog before stopping
  Future<bool?> _showStopConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Detener ejercicio?'),
        content: const Text(
          '¿Estás seguro que quieres detener el ejercicio de respiración?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: ZendfastColors.error,
            ),
            child: const Text('Detener'),
          ),
        ],
      ),
    );
  }
}
