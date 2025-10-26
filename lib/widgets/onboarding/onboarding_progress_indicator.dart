import 'package:flutter/material.dart';
import '../../theme/spacing.dart';

/// Progress indicator showing current step in onboarding flow
/// Displays as 5 dots with the current step highlighted
class OnboardingProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const OnboardingProgressIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 5,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalSteps,
        (index) {
          final isActive = index == currentStep;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: ZendfastSpacing.xs),
            width: isActive ? 24.0 : 8.0,
            height: 8.0,
            decoration: BoxDecoration(
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4.0),
            ),
          );
        },
      ),
    );
  }
}
