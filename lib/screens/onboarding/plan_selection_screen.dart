import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/fasting_plan.dart';
import '../../providers/onboarding_provider.dart';
import '../../theme/spacing.dart';
import '../../widgets/fasting/fasting_plan_card.dart';

/// Pantalla para seleccionar un plan de ayuno durante el onboarding
/// Permite elegir entre planes predefinidos (12/12, 14/10, 16/8, 18/6, 24h, 48h)
class PlanSelectionScreen extends ConsumerStatefulWidget {
  final VoidCallback? onContinue;
  final VoidCallback? onSkip;

  const PlanSelectionScreen({
    super.key,
    this.onContinue,
    this.onSkip,
  });

  @override
  ConsumerState<PlanSelectionScreen> createState() =>
      _PlanSelectionScreenState();
}

class _PlanSelectionScreenState extends ConsumerState<PlanSelectionScreen> {
  FastingPlan? _selectedPlan;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final allPlans = FastingPlan.getAllPlans();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Contenido principal con scroll
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(ZendfastSpacing.l),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título principal
                    Text(
                      'Elige tu Plan de Ayuno',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: ZendfastSpacing.m),

                    // Subtítulo descriptivo
                    Text(
                      'Selecciona el plan que mejor se adapte a tu nivel de experiencia y objetivos de salud.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: ZendfastSpacing.xl),

                    // Lista de planes de ayuno
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: allPlans.length,
                      itemBuilder: (context, index) {
                        final plan = allPlans[index];
                        final isSelected = _selectedPlan == plan;

                        return FastingPlanCard(
                          plan: plan,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedPlan = plan;
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: ZendfastSpacing.xl),
                  ],
                ),
              ),
            ),

            // Botones de acción fijos en la parte inferior
            Container(
              padding: const EdgeInsets.all(ZendfastSpacing.l),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botón Continuar
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _selectedPlan == null || _isLoading
                          ? null
                          : _handleContinue,
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : const Text('Continuar'),
                    ),
                  ),
                  const SizedBox(height: ZendfastSpacing.m),

                  // Botón Omitir
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _isLoading ? null : _handleSkip,
                      child: const Text('Omitir por ahora'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Maneja la acción de continuar con el plan seleccionado
  Future<void> _handleContinue() async {
    if (_selectedPlan == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Guardar la selección en el provider de onboarding
      ref.read(onboardingProvider.notifier).saveFastingPlan(
            _selectedPlan!.type.name,
          );

      // Llamar al callback si existe
      widget.onContinue?.call();
    } catch (e) {
      // Mostrar error si algo falla
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar el plan: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Maneja la acción de omitir la selección de plan
  void _handleSkip() {
    // No guardar nada, solo continuar
    widget.onSkip?.call();
  }
}
