import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/onboarding_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../models/user_profile.dart';
import '../../theme/spacing.dart';

/// Detox recommendation screen - Fifth and final screen in onboarding flow
/// Shows 48-hour detox plan with opt-in option
class OnboardingDetoxRecommendationScreen extends ConsumerStatefulWidget {
  const OnboardingDetoxRecommendationScreen({super.key});

  @override
  ConsumerState<OnboardingDetoxRecommendationScreen> createState() =>
      _OnboardingDetoxRecommendationScreenState();
}

class _OnboardingDetoxRecommendationScreenState
    extends ConsumerState<OnboardingDetoxRecommendationScreen> {
  bool _isLoading = false;

  /// Handle user opting into the detox plan
  Future<void> _handleOptIn() async {
    ref.read(onboardingProvider.notifier).saveDetoxDecision(true);
    await _completeOnboarding();
  }

  /// Handle user skipping the detox plan
  Future<void> _handleSkip() async {
    ref.read(onboardingProvider.notifier).saveDetoxDecision(false);
    await _completeOnboarding();
  }

  /// Complete onboarding and save all data to database
  Future<void> _completeOnboarding() async {
    setState(() => _isLoading = true);

    try {
      // Get current user from auth provider
      final authState = ref.read(authNotifierProvider);
      final userId = authState.user?.id;

      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Get onboarding data from provider
      final onboardingState = ref.read(onboardingProvider);

      // Get or create user profile
      final db = DatabaseService.instance;
      UserProfile? profile = await db.getUserProfile(userId);

      if (profile == null) {
        // Create new profile
        profile = UserProfile(
          userId: userId,
          weightKg: onboardingState.weightKg,
          heightCm: onboardingState.heightCm,
          fastingExperienceLevel: onboardingState.fastingExperienceLevel,
          hasCompletedOnboarding: true,
          detoxPlanOptIn: onboardingState.detoxPlanOptIn,
        );
        await db.saveUserProfile(profile);
      } else {
        // Update existing profile
        profile.weightKg = onboardingState.weightKg ?? profile.weightKg;
        profile.heightCm = onboardingState.heightCm ?? profile.heightCm;
        profile.fastingExperienceLevel = onboardingState.fastingExperienceLevel ??
            profile.fastingExperienceLevel;
        profile.hasCompletedOnboarding = true;
        profile.detoxPlanOptIn = onboardingState.detoxPlanOptIn;
        profile.markUpdated();
        await db.saveUserProfile(profile);
      }

      // Clear onboarding state
      ref.read(onboardingProvider.notifier).reset();

      // Navigate to home
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            action: SnackBarAction(
              label: 'Reintentar',
              onPressed: _completeOnboarding,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(ZendfastSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // Icon
              Icon(
                Icons.spa_outlined,
                size: 80,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(height: ZendfastSpacing.xl),

              // Title
              Text(
                'Plan Detox de 48 Horas',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ZendfastSpacing.m),

              // Subtitle
              Text(
                'Reinicia tu sistema con nuestro plan diseñado especialmente para ti',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ZendfastSpacing.xxl),

              // Benefits container
              Container(
                padding: const EdgeInsets.all(ZendfastSpacing.l),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'Beneficios del Plan',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(height: ZendfastSpacing.m),
                    _DetoxBenefit(
                      icon: Icons.autorenew_outlined,
                      text: 'Resetea tu sistema digestivo',
                    ),
                    const SizedBox(height: ZendfastSpacing.s),
                    _DetoxBenefit(
                      icon: Icons.bolt_outlined,
                      text: 'Activa tu metabolismo',
                    ),
                    const SizedBox(height: ZendfastSpacing.s),
                    _DetoxBenefit(
                      icon: Icons.self_improvement_outlined,
                      text: 'Claridad mental mejorada',
                    ),
                    const SizedBox(height: ZendfastSpacing.s),
                    _DetoxBenefit(
                      icon: Icons.energy_savings_leaf_outlined,
                      text: 'Más energía y vitalidad',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: ZendfastSpacing.l),

              // Timeline preview
              Text(
                'Plan de 48 horas:',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: ZendfastSpacing.s),
              Text(
                '• Ayuno de 16 horas\n• Ventana de alimentación de 8 horas\n• Hidratación constante\n• Meditación guiada',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

              const Spacer(),

              // Opt-in button
              FilledButton(
                onPressed: _isLoading ? null : _handleOptIn,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: ZendfastSpacing.m,
                  ),
                  backgroundColor: theme.colorScheme.secondary,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Comenzar Plan Detox'),
              ),
              const SizedBox(height: ZendfastSpacing.s),

              // Skip button
              TextButton(
                onPressed: _isLoading ? null : _handleSkip,
                child: const Text('Tal vez después'),
              ),
              const SizedBox(height: ZendfastSpacing.m),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget showing a detox benefit item
class _DetoxBenefit extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetoxBenefit({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.onSecondaryContainer,
        ),
        const SizedBox(width: ZendfastSpacing.s),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}
