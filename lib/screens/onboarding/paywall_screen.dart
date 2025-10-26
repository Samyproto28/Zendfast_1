import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';
import '../../theme/spacing.dart';

/// Paywall screen - Fourth screen in onboarding flow
/// Integrates with Superwall to show subscription options
class OnboardingPaywallScreen extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const OnboardingPaywallScreen({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  @override
  ConsumerState<OnboardingPaywallScreen> createState() =>
      _OnboardingPaywallScreenState();
}

class _OnboardingPaywallScreenState
    extends ConsumerState<OnboardingPaywallScreen> {
  bool _isLoading = false;

  /// Handle user viewing subscription options
  /// Note: This is a simplified version. Full Superwall integration
  /// can be added later with proper event handling
  void _handleSubscribe() async {
    // For now, just show a dialog explaining premium features
    // In production, this would trigger Superwall paywall
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Planes Premium'),
        content: const Text(
          'Aquí se mostrarían los planes de suscripción mediante Superwall.\n\n'
          'Por ahora, selecciona una opción para continuar:',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continuar Gratis'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Suscribirse (Demo)'),
          ),
        ],
      ),
    );

    if (result != null) {
      // Save decision
      ref.read(onboardingProvider.notifier).savePaywallDecision(result);
      if (mounted) {
        widget.onNext();
      }
    }
  }

  /// Handle skip button - continue without subscribing
  void _handleSkip() {
    ref.read(onboardingProvider.notifier).savePaywallDecision(false);
    widget.onSkip();
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
                Icons.workspace_premium_outlined,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: ZendfastSpacing.xl),

              // Title
              Text(
                'Desbloquea Todo el Potencial',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ZendfastSpacing.m),

              // Subtitle
              Text(
                'Obtén acceso premium y transforma tu experiencia',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ZendfastSpacing.xxl),

              // Premium benefits
              _PremiumFeature(
                icon: Icons.lock_open_outlined,
                title: 'Planes Ilimitados',
                description: 'Acceso a todos los planes de ayuno',
              ),
              const SizedBox(height: ZendfastSpacing.m),

              _PremiumFeature(
                icon: Icons.analytics_outlined,
                title: 'Estadísticas Avanzadas',
                description: 'Análisis detallado de tu progreso',
              ),
              const SizedBox(height: ZendfastSpacing.m),

              _PremiumFeature(
                icon: Icons.notifications_active_outlined,
                title: 'Recordatorios Personalizados',
                description: 'Notificaciones adaptadas a tu rutina',
              ),
              const SizedBox(height: ZendfastSpacing.m),

              _PremiumFeature(
                icon: Icons.cloud_sync_outlined,
                title: 'Sincronización en la Nube',
                description: 'Accede a tus datos desde cualquier dispositivo',
              ),

              const Spacer(),

              // Subscribe button
              FilledButton(
                onPressed: _isLoading ? null : _handleSubscribe,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: ZendfastSpacing.m,
                  ),
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
                    : const Text('Ver Planes Premium'),
              ),
              const SizedBox(height: ZendfastSpacing.s),

              // Skip button
              TextButton(
                onPressed: _isLoading ? null : _handleSkip,
                child: const Text('Continuar gratis'),
              ),
              const SizedBox(height: ZendfastSpacing.m),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget showing a premium feature
class _PremiumFeature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _PremiumFeature({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 24,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: ZendfastSpacing.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
