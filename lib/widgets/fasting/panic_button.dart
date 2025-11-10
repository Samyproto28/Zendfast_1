import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zendfast_1/models/fasting_state.dart';
import 'package:zendfast_1/providers/timer_provider.dart';
import 'package:zendfast_1/theme/colors.dart';

/// Panic button that appears as a FloatingActionButton during active fasting.
///
/// This button provides emotional support for users experiencing cravings
/// or difficulty during their fast. It's only visible when a fasting session
/// is active (fasting or paused states).
///
/// Features:
/// - Orange color (#FFB366) for warmth and urgency
/// - Heart icon for emotional support
/// - Haptic feedback on tap
/// - Shows support modal when tapped
class PanicButton extends ConsumerWidget {
  const PanicButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);

    // Only show button when fasting session is active
    final isActive = timerState?.state.isActive ?? false;

    if (!isActive) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton(
      onPressed: () {
        // Trigger haptic feedback for tactile response
        HapticFeedback.mediumImpact();

        // TODO: Show panic button modal
        // Will be implemented in next phase
      },
      backgroundColor: ZendfastColors.panicOrange,
      elevation: 6.0,
      tooltip: 'Apoyo emocional',
      child: const Icon(
        Icons.favorite,
        color: Colors.white,
      ),
    );
  }
}
