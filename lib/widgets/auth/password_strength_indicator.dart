import 'package:flutter/material.dart';
import '../../theme/spacing.dart';

/// Password strength levels
enum PasswordStrength {
  weak,
  medium,
  strong,
}

/// Visual indicator for password strength
/// Shows color-coded bars and text feedback
class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  /// Calculate password strength
  PasswordStrength _getPasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.weak;

    int score = 0;

    // Length check
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    // Contains lowercase
    if (password.contains(RegExp(r'[a-z]'))) score++;

    // Contains uppercase
    if (password.contains(RegExp(r'[A-Z]'))) score++;

    // Contains number
    if (password.contains(RegExp(r'[0-9]'))) score++;

    // Contains special character
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    // Determine strength
    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    final strength = _getPasswordStrength(password);
    final colorScheme = Theme.of(context).colorScheme;

    Color getColor() {
      switch (strength) {
        case PasswordStrength.weak:
          return colorScheme.error;
        case PasswordStrength.medium:
          return Colors.orange;
        case PasswordStrength.strong:
          return Colors.green;
      }
    }

    String getText() {
      switch (strength) {
        case PasswordStrength.weak:
          return 'Contraseña débil';
        case PasswordStrength.medium:
          return 'Contraseña media';
        case PasswordStrength.strong:
          return 'Contraseña fuerte';
      }
    }

    double getProgress() {
      switch (strength) {
        case PasswordStrength.weak:
          return 0.33;
        case PasswordStrength.medium:
          return 0.66;
        case PasswordStrength.strong:
          return 1.0;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: ZendfastSpacing.s),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: getProgress(),
                backgroundColor: colorScheme.surfaceContainerHighest,
                color: getColor(),
                minHeight: 4,
              ),
            ),
            const SizedBox(width: ZendfastSpacing.s),
            Text(
              getText(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: getColor(),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
