import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';
import '../../theme/spacing.dart';

/// Questionnaire screen - Third screen in onboarding flow
/// Collects user's weight, height, and fasting experience level
class OnboardingQuestionnaireScreen extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const OnboardingQuestionnaireScreen({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  @override
  ConsumerState<OnboardingQuestionnaireScreen> createState() =>
      _OnboardingQuestionnaireScreenState();
}

class _OnboardingQuestionnaireScreenState
    extends ConsumerState<OnboardingQuestionnaireScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  String? _experienceLevel;

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  /// Validate and save questionnaire data
  void _handleNext() {
    // Since this is skippable, we don't require validation
    // Just save whatever data is provided
    final weight = double.tryParse(_weightController.text.trim());
    final height = double.tryParse(_heightController.text.trim());

    // Save to provider
    ref.read(onboardingProvider.notifier).saveQuestionnaireData(
          weightKg: weight,
          heightCm: height,
          fastingExperienceLevel: _experienceLevel,
        );

    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(ZendfastSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: ZendfastSpacing.xl),

                // Title
                Text(
                  'Personaliza tu Experiencia',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: ZendfastSpacing.s),

                // Subtitle
                Text(
                  'Ayúdanos a crear un plan perfecto para ti',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: ZendfastSpacing.xxl),

                // Weight field
                TextField(
                  controller: _weightController,
                  decoration: InputDecoration(
                    labelText: 'Peso (kg)',
                    hintText: 'Ej: 70',
                    prefixIcon: const Icon(Icons.monitor_weight_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                ),
                const SizedBox(height: ZendfastSpacing.m),

                // Height field
                TextField(
                  controller: _heightController,
                  decoration: InputDecoration(
                    labelText: 'Altura (cm)',
                    hintText: 'Ej: 170',
                    prefixIcon: const Icon(Icons.height_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                ),
                const SizedBox(height: ZendfastSpacing.m),

                // Experience level
                Text(
                  'Nivel de Experiencia con Ayuno',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: ZendfastSpacing.s),

                // Experience level options
                _ExperienceLevelOption(
                  title: 'Principiante',
                  description: 'Nuevo en el ayuno intermitente',
                  value: 'beginner',
                  groupValue: _experienceLevel,
                  onChanged: (value) {
                    setState(() => _experienceLevel = value);
                  },
                ),
                const SizedBox(height: ZendfastSpacing.s),

                _ExperienceLevelOption(
                  title: 'Intermedio',
                  description: 'He practicado ayuno algunas veces',
                  value: 'intermediate',
                  groupValue: _experienceLevel,
                  onChanged: (value) {
                    setState(() => _experienceLevel = value);
                  },
                ),
                const SizedBox(height: ZendfastSpacing.s),

                _ExperienceLevelOption(
                  title: 'Avanzado',
                  description: 'Practico ayuno regularmente',
                  value: 'advanced',
                  groupValue: _experienceLevel,
                  onChanged: (value) {
                    setState(() => _experienceLevel = value);
                  },
                ),
                const SizedBox(height: ZendfastSpacing.xxl),

                // Next button
                FilledButton(
                  onPressed: _handleNext,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: ZendfastSpacing.m,
                    ),
                  ),
                  child: const Text('Continuar'),
                ),
                const SizedBox(height: ZendfastSpacing.s),

                // Skip button
                TextButton(
                  onPressed: widget.onSkip,
                  child: const Text('Completar después'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Radio option for experience level selection
class _ExperienceLevelOption extends StatelessWidget {
  final String title;
  final String description;
  final String value;
  final String? groupValue;
  final ValueChanged<String?> onChanged;

  const _ExperienceLevelOption({
    required this.title,
    required this.description,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(ZendfastSpacing.m),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
            ),
            const SizedBox(width: ZendfastSpacing.s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? theme.colorScheme.onPrimaryContainer
                          : null,
                    ),
                  ),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurfaceVariant,
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
}
