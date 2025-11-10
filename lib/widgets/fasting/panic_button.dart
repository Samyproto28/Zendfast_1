import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zendfast_1/models/fasting_state.dart';
import 'package:zendfast_1/providers/timer_provider.dart';
import 'package:zendfast_1/services/analytics_service.dart';
import 'package:zendfast_1/theme/colors.dart';
import 'package:zendfast_1/widgets/fasting/panic_button_modal.dart';

/// Panic button that appears as a FloatingActionButton during active fasting.
///
/// This button provides emotional support for users experiencing cravings
/// or difficulty during their fast. It's only visible when a fasting session
/// is active (fasting or paused states).
///
/// Features:
/// - Orange color (#FFB366) for warmth and urgency
/// - Heart icon for emotional support
/// - Subtle pulse animation (scale 1.0 to 1.1)
/// - Haptic feedback on tap
/// - Shows support modal when tapped
class PanicButton extends ConsumerStatefulWidget {
  const PanicButton({super.key});

  @override
  ConsumerState<PanicButton> createState() => _PanicButtonState();
}

class _PanicButtonState extends ConsumerState<PanicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Create animation controller with 1500ms duration
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Create tween animation from 1.0 to 1.1 scale
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start repeating animation
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider);

    // Only show button when fasting session is active
    final isActive = timerState?.state.isActive ?? false;

    if (!isActive) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: FloatingActionButton(
        onPressed: () {
          // Trigger haptic feedback for tactile response
          HapticFeedback.mediumImpact();

          // Track analytics event
          final timerState = ref.read(timerProvider);
          AnalyticsService.instance.logEvent(
            'panic_button_used',
            parameters: {
              'timestamp': DateTime.now().toIso8601String(),
              'fasting_duration_minutes': timerState?.durationMinutes,
              'plan_type': timerState?.planType,
              'elapsed_minutes': (timerState?.elapsedMilliseconds ?? 0) ~/ 60000,
            },
          );

          // Show panic button modal with emotional support
          PanicButtonModal.show(context: context);
        },
        backgroundColor: ZendfastColors.panicOrange,
        elevation: 6.0,
        tooltip: 'Apoyo emocional',
        child: const Icon(
          Icons.favorite,
          color: Colors.white,
        ),
      ),
    );
  }
}
