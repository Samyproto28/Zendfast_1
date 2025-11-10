import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zendfast_1/providers/timer_provider.dart';
import 'package:zendfast_1/theme/colors.dart';
import 'package:zendfast_1/theme/spacing.dart';

/// Modal bottom sheet that provides emotional support during fasting.
///
/// This modal appears when the user taps the panic button and offers:
/// - Motivational phrases to encourage continuation
/// - Breathing meditation guide
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

  /// List of motivational phrases to display.
  static const List<Map<String, dynamic>> _motivationalPhrases = [
    {
      'icon': Icons.favorite,
      'title': 'Eres más fuerte de lo que crees',
      'subtitle': 'Este momento pasará y te sentirás orgulloso',
    },
    {
      'icon': Icons.water_drop,
      'title': 'Bebe agua lentamente',
      'subtitle': 'A veces la sed se confunde con hambre',
    },
    {
      'icon': Icons.self_improvement,
      'title': 'Toma 5 respiraciones profundas',
      'subtitle': 'Oxigena tu cuerpo y calma tu mente',
    },
    {
      'icon': Icons.wb_sunny,
      'title': 'Sal a caminar 5 minutos',
      'subtitle': 'Cambia de ambiente y despeja tu mente',
    },
    {
      'icon': Icons.phone,
      'title': 'Llama a un amigo',
      'subtitle': 'Comparte cómo te sientes, no estás solo',
    },
  ];

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

              // Motivational phrases
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _motivationalPhrases.length,
                itemBuilder: (context, index) {
                  final phrase = _motivationalPhrases[index];
                  return ListTile(
                    leading: Icon(
                      phrase['icon'] as IconData,
                      color: ZendfastColors.secondaryGreen,
                    ),
                    title: Text(
                      phrase['title'] as String,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      phrase['subtitle'] as String,
                      style: theme.textTheme.bodySmall,
                    ),
                    onTap: () {
                      // Close modal when phrase is selected
                      Navigator.of(context).pop();
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
