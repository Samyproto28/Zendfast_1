import 'package:flutter/material.dart';
import '../../theme/spacing.dart';

/// Splash screen - First screen in onboarding flow
/// Shows app logo with loading animation, auto-advances after 2 seconds
class OnboardingSplashScreen extends StatelessWidget {
  final VoidCallback onComplete;

  const OnboardingSplashScreen({
    super.key,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Auto-advance after 2 seconds
    Future.delayed(const Duration(seconds: 2), onComplete);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo/icon
              Icon(
                Icons.self_improvement_outlined,
                size: 120,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: ZendfastSpacing.xl),

              // App name
              Text(
                'Zendfast',
                style: theme.textTheme.displayMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: ZendfastSpacing.s),

              // Tagline
              Text(
                'Tu compañero de ayuno consciente',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ZendfastSpacing.xxl),

              // Loading indicator
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
