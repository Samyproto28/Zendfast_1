import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zendfast_1/models/motivational_phrase.dart';
import 'package:zendfast_1/providers/timer_provider.dart';
import 'package:zendfast_1/repositories/motivational_phrases_repository.dart';
import 'package:zendfast_1/services/analytics_service.dart';
import 'package:zendfast_1/theme/colors.dart';
import 'package:zendfast_1/theme/spacing.dart';

/// Modal bottom sheet that provides emotional support during fasting.
///
/// This modal appears when the user taps the panic button and offers:
/// - Dynamic motivational phrases from repository
/// - Breathing meditation guide (navigates to breathing screen)
/// - Option to stop the fast if truly needed
///
/// The modal uses warm, supportive language and provides multiple
/// options to help the user overcome a difficult moment.
class PanicButtonModal extends ConsumerWidget {
  const PanicButtonModal._();

  /// Shows the panic button modal as a bottom sheet.
  static Future<void> show({required BuildContext context}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PanicButtonModal._(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: ZendfastSpacing.m),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: ZendfastSpacing.l),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: ZendfastSpacing.l),
                child: Text(
                  'Apoyo Emocional',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ZendfastColors.panicOrange,
                  ),
                ),
              ),

              const SizedBox(height: ZendfastSpacing.s),

              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: ZendfastSpacing.l),
                child: Text(
                  'Este es un momento difícil, pero puedes superarlo',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: ZendfastSpacing.l),

              // Motivational phrases (loaded from repository)
              FutureBuilder<List<MotivationalPhrase>>(
                future: MotivationalPhrasesRepository.instance.getMotivationalPhrases(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(ZendfastSpacing.l),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final phrases = snapshot.data ?? [];

                  if (phrases.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(ZendfastSpacing.l),
                      child: Text(
                        'No hay frases disponibles en este momento',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: phrases.length,
                    itemBuilder: (context, index) {
                      final phrase = phrases[index];
                      return ListTile(
                        leading: Icon(
                          _getIconFromName(phrase.iconName),
                          color: ZendfastColors.secondaryGreen,
                        ),
                        title: Text(
                          phrase.text,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: phrase.subtitle != null
                            ? Text(
                                phrase.subtitle!,
                                style: theme.textTheme.bodySmall,
                              )
                            : null,
                        onTap: () => _handlePhraseTap(context, ref, phrase),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: ZendfastSpacing.m),

              // Divider
              Divider(
                height: 1,
                color: colorScheme.outlineVariant,
                indent: ZendfastSpacing.l,
                endIndent: ZendfastSpacing.l,
              ),

              const SizedBox(height: ZendfastSpacing.m),

              // "No puedo continuar" button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: ZendfastSpacing.l),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showStopConfirmation(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ZendfastColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: ZendfastSpacing.m,
                      ),
                    ),
                    child: const Text('No puedo continuar'),
                  ),
                ),
              ),

              const SizedBox(height: ZendfastSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  /// Handles phrase tap - navigates to breathing screen or closes modal
  void _handlePhraseTap(
    BuildContext context,
    WidgetRef ref,
    MotivationalPhrase phrase,
  ) {
    // Track analytics
    AnalyticsService.instance.logEvent(
      'phrase_tapped',
      parameters: {
        'phrase_id': phrase.id,
        'phrase_text': phrase.text,
        'category': phrase.category ?? 'unknown',
        'action': phrase.text.contains('Medita') ? 'navigate_breathing' : 'close_modal',
      },
    );

    // Special handling for meditation phrase
    if (phrase.text.contains('Medita')) {
      // Close modal
      Navigator.of(context).pop();
      // Navigate to breathing screen
      context.go('/breathing-exercise');
    } else {
      // Just close modal for other phrases
      Navigator.of(context).pop();
    }
  }

  /// Maps icon name string to IconData
  IconData _getIconFromName(String iconName) {
    // Map common Material icon names to IconData
    switch (iconName.toLowerCase()) {
      case 'favorite':
        return Icons.favorite;
      case 'water_drop':
        return Icons.water_drop;
      case 'air':
        return Icons.air;
      case 'directions_walk':
        return Icons.directions_walk;
      case 'phone':
        return Icons.phone;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'spa':
        return Icons.spa;
      case 'block':
        return Icons.block;
      case 'check':
        return Icons.check;
      default:
        return Icons.help_outline;
    }
  }

  /// Shows confirmation dialog before stopping the fast.
  Future<void> _showStopConfirmation(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Detener ayuno?'),
        content: const Text(
          '¿Estás seguro que quieres detener tu ayuno? '
          'Podrás comenzar uno nuevo cuando estés listo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: ZendfastColors.error,
            ),
            child: const Text('Detener'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        // Interrupt the fast
        await ref.read(timerProvider.notifier).interruptFast();

        // Close the modal
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        // Show error if something goes wrong
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al detener ayuno: $e'),
              backgroundColor: ZendfastColors.error,
            ),
          );
        }
      }
    }
  }
}
