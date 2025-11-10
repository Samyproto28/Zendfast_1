import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/fasting_state.dart';
import '../../providers/timer_provider.dart';
import '../../theme/colors.dart';

/// Control buttons for fasting timer with state-dependent visibility
///
/// Shows different button combinations based on fasting state:
/// - Idle: "Iniciar Ayuno" (green filled button)
/// - Fasting: "Pausar" (orange), "Detener" (red outlined)
/// - Paused: "Reanudar" (green), "Detener" (red outlined)
///
/// All buttons include haptic feedback for better UX.
class FastingControlButtons extends ConsumerWidget {
  /// Callback when start button is pressed (requires plan selection)
  final VoidCallback? onStartPressed;

  const FastingControlButtons({
    super.key,
    this.onStartPressed,
  });

  /// Trigger haptic feedback
  void _triggerHaptic() {
    HapticFeedback.mediumImpact();
  }

  /// Handle start fast action
  void _handleStart(BuildContext context) {
    _triggerHaptic();
    if (onStartPressed != null) {
      onStartPressed!();
    } else {
      // Show snackbar if no callback provided
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona un plan de ayuno primero'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Handle pause action
  Future<void> _handlePause(WidgetRef ref, BuildContext context) async {
    _triggerHaptic();
    try {
      await ref.read(timerProvider.notifier).pauseFast();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al pausar: $e'),
            backgroundColor: ZendfastColors.error,
          ),
        );
      }
    }
  }

  /// Handle resume action
  Future<void> _handleResume(WidgetRef ref, BuildContext context) async {
    _triggerHaptic();
    try {
      await ref.read(timerProvider.notifier).resumeFast();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al reanudar: $e'),
            backgroundColor: ZendfastColors.error,
          ),
        );
      }
    }
  }

  /// Handle interrupt/stop action with confirmation
  Future<void> _handleInterrupt(WidgetRef ref, BuildContext context) async {
    _triggerHaptic();

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Detener ayuno?'),
        content: const Text(
          '¿Estás seguro de que quieres detener tu ayuno actual? '
          'Esta acción no se puede deshacer.',
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

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(timerProvider.notifier).interruptFast();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al detener: $e'),
              backgroundColor: ZendfastColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final fastingState = timerState?.state ?? FastingState.idle;

    return AnimatedSwitcher(
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
      child: _buildButtonsForState(context, ref, fastingState),
    );
  }

  /// Build appropriate buttons based on current state
  Widget _buildButtonsForState(
    BuildContext context,
    WidgetRef ref,
    FastingState state,
  ) {
    switch (state) {
      case FastingState.idle:
      case FastingState.completed:
        return _buildStartButton(context, key: const ValueKey('start'));

      case FastingState.fasting:
        return _buildFastingButtons(context, ref, key: const ValueKey('fasting'));

      case FastingState.paused:
        return _buildPausedButtons(context, ref, key: const ValueKey('paused'));
    }
  }

  /// Start button (idle state)
  Widget _buildStartButton(BuildContext context, {required Key key}) {
    return SizedBox(
      key: key,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: FilledButton(
          onPressed: () => _handleStart(context),
          style: FilledButton.styleFrom(
            backgroundColor: ZendfastColors.secondaryGreen,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Iniciar Ayuno',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  /// Pause and Stop buttons (fasting state)
  Widget _buildFastingButtons(
    BuildContext context,
    WidgetRef ref, {
    required Key key,
  }) {
    return Row(
      key: key,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pause button
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 32.0, right: 8.0),
            child: FilledButton(
              onPressed: () => _handlePause(ref, context),
              style: FilledButton.styleFrom(
                backgroundColor: ZendfastColors.panicOrange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Pausar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        // Stop button
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 32.0),
            child: OutlinedButton(
              onPressed: () => _handleInterrupt(ref, context),
              style: OutlinedButton.styleFrom(
                foregroundColor: ZendfastColors.error,
                side: const BorderSide(color: ZendfastColors.error, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Detener',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Resume and Stop buttons (paused state)
  Widget _buildPausedButtons(
    BuildContext context,
    WidgetRef ref, {
    required Key key,
  }) {
    return Row(
      key: key,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Resume button
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 32.0, right: 8.0),
            child: FilledButton(
              onPressed: () => _handleResume(ref, context),
              style: FilledButton.styleFrom(
                backgroundColor: ZendfastColors.secondaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Reanudar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        // Stop button
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 32.0),
            child: OutlinedButton(
              onPressed: () => _handleInterrupt(ref, context),
              style: OutlinedButton.styleFrom(
                foregroundColor: ZendfastColors.error,
                side: const BorderSide(color: ZendfastColors.error, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Detener',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
