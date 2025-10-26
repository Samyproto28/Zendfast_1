import 'package:flutter/material.dart';
import '../../theme/spacing.dart';

/// Introduction screen - Second screen in onboarding flow
/// Shows key benefits of the app to new users
class OnboardingIntroScreen extends StatelessWidget {
  final VoidCallback onNext;

  const OnboardingIntroScreen({
    super.key,
    required this.onNext,
  });

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

              // Welcome title
              Text(
                'Bienvenido a Zendfast',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ZendfastSpacing.m),

              // Subtitle
              Text(
                'Descubre los beneficios del ayuno consciente',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ZendfastSpacing.xxl),

              // Benefits list
              _BenefitCard(
                icon: Icons.timer_outlined,
                title: 'Seguimiento de Progreso',
                description:
                    'Monitorea tus períodos de ayuno con precisión',
              ),
              const SizedBox(height: ZendfastSpacing.m),

              _BenefitCard(
                icon: Icons.psychology_outlined,
                title: 'Planes Personalizados',
                description: 'Rutinas adaptadas a tu nivel y objetivos',
              ),
              const SizedBox(height: ZendfastSpacing.m),

              _BenefitCard(
                icon: Icons.insights_outlined,
                title: 'Estadísticas de Salud',
                description: 'Visualiza tu progreso y mejora continua',
              ),
              const SizedBox(height: ZendfastSpacing.m),

              _BenefitCard(
                icon: Icons.groups_outlined,
                title: 'Comunidad de Apoyo',
                description: 'Comparte tu experiencia con otros usuarios',
              ),

              const Spacer(),

              // Next button
              FilledButton(
                onPressed: onNext,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: ZendfastSpacing.m,
                  ),
                ),
                child: const Text('Continuar'),
              ),
              const SizedBox(height: ZendfastSpacing.m),
            ],
          ),
        ),
      ),
    );
  }
}

/// Benefit card widget showing an icon, title, and description
class _BenefitCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _BenefitCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(ZendfastSpacing.m),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(ZendfastSpacing.s),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 32,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: ZendfastSpacing.m),

          // Text content
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
                const SizedBox(height: ZendfastSpacing.xs),
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
      ),
    );
  }
}
