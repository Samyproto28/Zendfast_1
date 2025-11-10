import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/fasting_plan.dart';
import '../../models/fasting_state.dart';
import '../../providers/auth_computed_providers.dart';
import '../../providers/timer_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../widgets/fasting/circular_progress_ring.dart';
import '../../widgets/fasting/fasting_context_info.dart';
import '../../widgets/fasting/fasting_control_buttons.dart';

/// Main fasting home screen with timer, progress, and controls
///
/// Shows:
/// - Large central timer with progress ring
/// - Contextual information (phase, milestones)
/// - Control buttons (start/pause/resume/stop)
/// - Smooth animations for state transitions
class FastingHomeScreen extends ConsumerWidget {
  const FastingHomeScreen({super.key});

  /// Show plan selector bottom sheet
  Future<FastingPlan?> _showPlanSelector(BuildContext context) async {
    return showModalBottomSheet<FastingPlan>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _PlanSelectorSheet(),
    );
  }

  /// Handle start fast with plan selection
  Future<void> _handleStartFast(
    BuildContext context,
    WidgetRef ref,
  ) async {
    // Get user ID
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes iniciar sesión para comenzar un ayuno'),
            backgroundColor: ZendfastColors.error,
          ),
        );
      }
      return;
    }

    // Show plan selector
    final selectedPlan = await _showPlanSelector(context);
    if (selectedPlan == null || !context.mounted) return;

    // Start the fast
    try {
      await ref.read(timerProvider.notifier).startFast(
            userId: userId,
            durationMinutes: selectedPlan.fastingHours * 60,
            planType: selectedPlan.type.name,
          );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Ayuno de ${selectedPlan.title} iniciado!'),
            backgroundColor: ZendfastColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al iniciar ayuno: $e'),
            backgroundColor: ZendfastColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final fastingState = timerState?.state ?? FastingState.idle;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Mi Ayuno'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: _getBackgroundGradient(fastingState, colorScheme),
          ),
          child: Column(
            children: [
              const SizedBox(height: ZendfastSpacing.l),

              // Contextual information at top
              const FastingContextInfo(),

              // Spacer to push progress ring to center
              const Spacer(flex: 2),

              // Central progress ring with timer
              const CircularProgressRing(),

              // Spacer before buttons
              const Spacer(flex: 3),

              // Control buttons at bottom
              FastingControlButtons(
                onStartPressed: () => _handleStartFast(context, ref),
              ),

              const SizedBox(height: ZendfastSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  /// Get background gradient based on fasting state
  LinearGradient _getBackgroundGradient(
    FastingState state,
    ColorScheme colorScheme,
  ) {
    switch (state) {
      case FastingState.fasting:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ZendfastColors.secondaryGreen.withValues(alpha: 0.05),
            colorScheme.surface,
          ],
        );
      case FastingState.paused:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ZendfastColors.panicOrange.withValues(alpha: 0.05),
            colorScheme.surface,
          ],
        );
      case FastingState.completed:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.primary.withValues(alpha: 0.05),
            colorScheme.surface,
          ],
        );
      case FastingState.idle:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.surface,
            colorScheme.surface,
          ],
        );
    }
  }
}

/// Plan selector bottom sheet
class _PlanSelectorSheet extends StatefulWidget {
  const _PlanSelectorSheet();

  @override
  State<_PlanSelectorSheet> createState() => _PlanSelectorSheetState();
}

class _PlanSelectorSheetState extends State<_PlanSelectorSheet> {
  FastingPlan? _selectedPlan;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final allPlans = FastingPlan.getAllPlans();

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(ZendfastSpacing.l),
            child: Text(
              'Selecciona tu Plan',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Plan list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: ZendfastSpacing.l),
              itemCount: allPlans.length,
              itemBuilder: (context, index) {
                final plan = allPlans[index];
                final isSelected = _selectedPlan == plan;

                return _PlanOption(
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
          ),

          // Confirm button
          Padding(
            padding: const EdgeInsets.all(ZendfastSpacing.l),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _selectedPlan == null
                    ? null
                    : () => Navigator.of(context).pop(_selectedPlan),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Confirmar'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Plan option widget for bottom sheet
class _PlanOption extends StatelessWidget {
  final FastingPlan plan;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanOption({
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  String _getDifficultyLabel(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner:
        return 'Principiante';
      case DifficultyLevel.intermediate:
        return 'Intermedio';
      case DifficultyLevel.advanced:
        return 'Avanzado';
    }
  }

  Color _getDifficultyColor(DifficultyLevel level, ColorScheme colorScheme) {
    switch (level) {
      case DifficultyLevel.beginner:
        return ZendfastColors.success;
      case DifficultyLevel.intermediate:
        return ZendfastColors.warning;
      case DifficultyLevel.advanced:
        return ZendfastColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: ZendfastSpacing.m),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(ZendfastSpacing.m),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outline.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.05)
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    plan.icon,
                    color: colorScheme.onPrimaryContainer,
                    size: 24,
                  ),
                ),

                const SizedBox(width: ZendfastSpacing.m),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plan.title,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(
                                plan.difficultyLevel,
                                colorScheme,
                              ).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getDifficultyLabel(plan.difficultyLevel),
                              style: textTheme.labelSmall?.copyWith(
                                color: _getDifficultyColor(
                                  plan.difficultyLevel,
                                  colorScheme,
                                ),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plan.description,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Checkmark
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: colorScheme.primary,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
