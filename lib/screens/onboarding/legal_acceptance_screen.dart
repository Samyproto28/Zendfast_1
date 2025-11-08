import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/spacing.dart';
import '../../router/route_constants.dart';
import '../../providers/onboarding_provider.dart';

/// Onboarding screen for accepting Privacy Policy and Terms of Service
/// Users must accept both documents before continuing
class OnboardingLegalAcceptanceScreen extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const OnboardingLegalAcceptanceScreen({
    super.key,
    required this.onNext,
  });

  @override
  ConsumerState<OnboardingLegalAcceptanceScreen> createState() =>
      _OnboardingLegalAcceptanceScreenState();
}

class _OnboardingLegalAcceptanceScreenState
    extends ConsumerState<OnboardingLegalAcceptanceScreen> {
  bool _privacyPolicyAccepted = false;
  bool _termsAccepted = false;

  bool get _canContinue => _privacyPolicyAccepted && _termsAccepted;

  void _handleContinue() {
    if (_canContinue) {
      // Save legal acceptance to onboarding state
      // Will be persisted to database when user account is created
      ref.read(onboardingProvider.notifier).saveLegalAcceptance(
            privacyPolicy: _privacyPolicyAccepted,
            termsOfService: _termsAccepted,
          );

      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(ZendfastSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Skip spacing for progress indicator
              const SizedBox(height: ZendfastSpacing.xl * 2),

              // Title
              Text(
                'Términos Legales',
                style: theme.textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: ZendfastSpacing.m),

              // Subtitle
              Text(
                'Antes de continuar, por favor acepta nuestros términos legales',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: ZendfastSpacing.xl),

              // Legal acceptance cards
              Expanded(
                child: ListView(
                  children: [
                    // Privacy Policy Card
                    _buildLegalCard(
                      context: context,
                      title: 'Política de Privacidad',
                      icon: Icons.privacy_tip_outlined,
                      description:
                          'Describe cómo recopilamos, usamos y protegemos tus datos personales',
                      isAccepted: _privacyPolicyAccepted,
                      onChanged: (value) {
                        setState(() {
                          _privacyPolicyAccepted = value ?? false;
                        });
                      },
                      onReadMore: () {
                        context.push(Routes.privacyPolicy);
                      },
                    ),

                    const SizedBox(height: ZendfastSpacing.m),

                    // Terms of Service Card
                    _buildLegalCard(
                      context: context,
                      title: 'Términos y Condiciones',
                      icon: Icons.gavel_outlined,
                      description:
                          'Incluye disclaimers médicos, términos de suscripción y responsabilidades',
                      isAccepted: _termsAccepted,
                      onChanged: (value) {
                        setState(() {
                          _termsAccepted = value ?? false;
                        });
                      },
                      onReadMore: () {
                        context.push(Routes.termsOfService);
                      },
                    ),

                    const SizedBox(height: ZendfastSpacing.m),

                    // Medical Disclaimer Warning
                    Container(
                      padding: const EdgeInsets.all(ZendfastSpacing.m),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: colorScheme.onErrorContainer,
                            size: 24,
                          ),
                          const SizedBox(width: ZendfastSpacing.m),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Disclaimer Médico',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onErrorContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: ZendfastSpacing.xs),
                                Text(
                                  'Zendfast NO proporciona asesoramiento médico. Consulta con un profesional de la salud antes de comenzar cualquier programa de ayuno.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onErrorContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: ZendfastSpacing.l),

              // Continue button
              FilledButton(
                onPressed: _canContinue ? _handleContinue : null,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: ZendfastSpacing.m,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Aceptar y Continuar',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: _canContinue
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ),
              ),

              const SizedBox(height: ZendfastSpacing.m),

              // Required notice
              Text(
                'Debes aceptar ambos documentos para usar Zendfast',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegalCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String description,
    required bool isAccepted,
    required ValueChanged<bool?> onChanged,
    required VoidCallback onReadMore,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(ZendfastSpacing.m),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAccepted
              ? colorScheme.primary
              : colorScheme.outline.withValues(alpha: 0.2),
          width: isAccepted ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and Title
          Row(
            children: [
              Icon(
                icon,
                color: colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: ZendfastSpacing.s),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: ZendfastSpacing.s),

          // Description
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),

          const SizedBox(height: ZendfastSpacing.m),

          // Acceptance checkbox
          Row(
            children: [
              Checkbox(
                value: isAccepted,
                onChanged: onChanged,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodyMedium,
                    children: [
                      const TextSpan(
                        text: 'He leído y acepto ',
                      ),
                      TextSpan(
                        text: 'los $title',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = onReadMore,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
