import 'package:flutter/material.dart';
import '../../models/fasting_plan.dart';
import '../../theme/spacing.dart';

/// Card para mostrar un plan de ayuno con diseño Material 3
/// Incluye estados de selección visual y animaciones suaves
class FastingPlanCard extends StatelessWidget {
  final FastingPlan plan;
  final bool isSelected;
  final VoidCallback onTap;

  const FastingPlanCard({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label: '${plan.title} - ${plan.description}',
      hint: isSelected
          ? 'Plan seleccionado. Toca para deseleccionar.'
          : 'Toca para seleccionar este plan',
      selected: isSelected,
      button: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ZendfastSpacing.m,
          vertical: ZendfastSpacing.s,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? colorScheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(ZendfastSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icono y título principal
                    Row(
                      children: [
                        Icon(
                          plan.icon,
                          size: 32,
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                        ),
                        const SizedBox(width: ZendfastSpacing.m),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plan.title,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: ZendfastSpacing.xs),
                              Text(
                                plan.durationText,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Badge de dificultad
                        _DifficultyBadge(
                          level: plan.difficultyLevelName,
                          color: plan.getDifficultyColor(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: ZendfastSpacing.m),

                    // Descripción del plan
                    Text(
                      plan.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: ZendfastSpacing.s),

                    // Recomendado para
                    Row(
                      children: [
                        Icon(
                          Icons.stars,
                          size: 16,
                          color: colorScheme.tertiary,
                        ),
                        const SizedBox(width: ZendfastSpacing.xs),
                        Text(
                          'Recomendado para: ${plan.recommendedForText}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.tertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: ZendfastSpacing.m),

                    // Beneficios principales (máximo 3)
                    ...plan.benefits.take(3).map(
                          (benefit) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: ZendfastSpacing.xs,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 16,
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.secondary,
                                ),
                                const SizedBox(width: ZendfastSpacing.s),
                                Expanded(
                                  child: Text(
                                    benefit,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Badge circular para mostrar el nivel de dificultad
class _DifficultyBadge extends StatelessWidget {
  final String level;
  final Color color;

  const _DifficultyBadge({
    required this.level,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ZendfastSpacing.m,
        vertical: ZendfastSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color,
          width: 1.5,
        ),
      ),
      child: Text(
        level,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
