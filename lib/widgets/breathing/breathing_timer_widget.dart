import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zendfast_1/models/breathing_state.dart';
import 'package:zendfast_1/services/breathing_exercise_service.dart';
import 'package:zendfast_1/theme/colors.dart';

/// Animated breathing timer widget that visualizes breathing cycles.
///
/// Features:
/// - Animated circle that grows/shrinks with breathing phases
/// - Color transitions between phases
/// - Text instructions overlay
/// - Haptic feedback on phase changes
///
/// The circle size changes:
/// - Inhale: grows from 1.0x to 1.5x
/// - Hold: stays at 1.5x
/// - Exhale: shrinks from 1.5x to 1.0x
class BreathingTimerWidget extends StatefulWidget {
  const BreathingTimerWidget({super.key});

  @override
  State<BreathingTimerWidget> createState() => _BreathingTimerWidgetState();
}

class _BreathingTimerWidgetState extends State<BreathingTimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  BreathingPhase? _lastPhase;

  @override
  void initState() {
    super.initState();

    // Initialize scale animation controller
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  /// Updates animation based on breathing phase
  void _updateAnimation(BreathingPhase phase) {
    // Trigger haptic feedback on phase change
    if (_lastPhase != phase && _lastPhase != null) {
      HapticFeedback.mediumImpact();
    }
    _lastPhase = phase;

    // Update scale animation target based on phase
    final targetScale = _getTargetScale(phase);

    _scaleAnimation = Tween<double>(
      begin: _scaleAnimation.value,
      end: targetScale,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _scaleController
      ..reset()
      ..forward();
  }

  /// Gets target scale for each breathing phase
  double _getTargetScale(BreathingPhase phase) {
    switch (phase) {
      case BreathingPhase.inhale:
        return 1.5; // Grow
      case BreathingPhase.hold:
        return 1.5; // Stay large
      case BreathingPhase.exhale:
        return 1.0; // Shrink
    }
  }

  /// Gets color for each breathing phase
  Color _getPhaseColor(BreathingPhase phase, ColorScheme colorScheme) {
    switch (phase) {
      case BreathingPhase.inhale:
        return ZendfastColors.primaryTeal;
      case BreathingPhase.hold:
        return ZendfastColors.secondaryGreen;
      case BreathingPhase.exhale:
        return ZendfastColors.primaryTealDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return StreamBuilder<BreathingState>(
      stream: BreathingExerciseService.instance.stateStream,
      initialData: BreathingExerciseService.instance.currentState,
      builder: (context, snapshot) {
        final state = snapshot.data ?? BreathingState.initial();

        // Update animation when phase changes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateAnimation(state.phase);
        });

        return Center(
          child: SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Animated breathing circle
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getPhaseColor(state.phase, colorScheme)
                              .withOpacity(0.3),
                          border: Border.all(
                            color: _getPhaseColor(state.phase, colorScheme),
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _getPhaseColor(state.phase, colorScheme)
                                  .withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Instruction text overlay
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                        state.instructionText,
                        key: ValueKey(state.phase),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getPhaseColor(state.phase, colorScheme),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        '${state.phase.durationSeconds}s',
                        key: ValueKey('${state.phase}_duration'),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
