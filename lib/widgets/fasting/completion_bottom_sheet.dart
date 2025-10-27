import 'package:flutter/material.dart';
import '../../models/fasting_session.dart';
import '../../theme/spacing.dart';

/// Bottom sheet displayed when a fasting session is completed
/// Shows congratulatory message and session statistics
class CompletionBottomSheet extends StatelessWidget {
  final FastingSession session;
  final VoidCallback onDismiss;

  const CompletionBottomSheet({
    super.key,
    required this.session,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final durationHours = (session.durationMinutes ?? 0) / 60;

    return Container(
      padding: const EdgeInsets.all(ZendfastSpacing.xl),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: ZendfastSpacing.xl),

            // Celebration icon
            Icon(
              Icons.celebration,
              size: 80,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: ZendfastSpacing.l),

            // Congratulations title
            Text(
              '¡Felicidades!',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: ZendfastSpacing.s),

            // Completion message
            Text(
              'Has completado tu ayuno',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: ZendfastSpacing.xl),

            // Statistics card
            Container(
              padding: const EdgeInsets.all(ZendfastSpacing.l),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Duration
                  _StatRow(
                    icon: Icons.timer_outlined,
                    label: 'Duración',
                    value: _formatDuration(durationHours),
                  ),
                  const SizedBox(height: ZendfastSpacing.m),

                  // Plan type
                  _StatRow(
                    icon: Icons.schedule,
                    label: 'Plan',
                    value: session.planType,
                  ),
                  const SizedBox(height: ZendfastSpacing.m),

                  // Calories burned estimate (rough calculation)
                  _StatRow(
                    icon: Icons.local_fire_department,
                    label: 'Calorías quemadas (est.)',
                    value: '~${_estimateCaloriesBurned(durationHours)} kcal',
                  ),
                ],
              ),
            ),
            const SizedBox(height: ZendfastSpacing.xl),

            // Motivational message
            Container(
              padding: const EdgeInsets.all(ZendfastSpacing.m),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: theme.colorScheme.tertiary,
                    size: 24,
                  ),
                  const SizedBox(width: ZendfastSpacing.s),
                  Expanded(
                    child: Text(
                      '¡Excelente trabajo! Cada ayuno te acerca más a tus objetivos.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: ZendfastSpacing.xl),

            // Continue button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onDismiss,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: ZendfastSpacing.m,
                  ),
                ),
                child: const Text('Continuar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Format duration as hours and minutes
  String _formatDuration(double hours) {
    final h = hours.floor();
    final m = ((hours - h) * 60).round();

    if (h > 0 && m > 0) {
      return '$h h $m min';
    } else if (h > 0) {
      return '$h horas';
    } else {
      return '$m minutos';
    }
  }

  /// Rough estimate of calories burned during fasting
  /// Based on typical metabolic rate during fasting
  int _estimateCaloriesBurned(double hours) {
    // Rough estimate: ~50-70 calories per hour during fasting
    // Using 60 as average
    return (hours * 60).round();
  }

  /// Show the completion bottom sheet
  static Future<void> show({
    required BuildContext context,
    required FastingSession session,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CompletionBottomSheet(
        session: session,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }
}

/// Stat row widget for displaying session statistics
class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: ZendfastSpacing.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
