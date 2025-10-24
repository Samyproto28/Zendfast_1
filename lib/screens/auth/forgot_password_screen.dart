import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/auth_button.dart';
import '../../theme/spacing.dart';

/// Forgot password screen
/// Allows users to request a password reset email
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Validate email format
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo electrónico es requerido';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Formato de correo electrónico inválido';
    }

    return null;
  }

  /// Handle send reset link button press
  Future<void> _handleSendResetLink() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ref.read(authNotifierProvider.notifier).resetPassword(
            email: _emailController.text.trim(),
          );

      if (mounted) {
        result.when(
          success: (_) {
            setState(() => _emailSent = true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Se ha enviado un enlace de restablecimiento a tu correo',
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 4),
              ),
            );
          },
          failure: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.message),
                backgroundColor: Theme.of(context).colorScheme.error,
                duration: const Duration(seconds: 4),
              ),
            );
          },
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isLoading ? null : () => context.go('/auth/login'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(ZendfastSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Icon
                    Icon(
                      _emailSent
                          ? Icons.mark_email_read_outlined
                          : Icons.lock_reset,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: ZendfastSpacing.l),

                    // Title
                    Text(
                      _emailSent
                          ? '¡Correo Enviado!'
                          : '¿Olvidaste tu contraseña?',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: ZendfastSpacing.s),

                    // Description
                    Text(
                      _emailSent
                          ? 'Hemos enviado instrucciones de restablecimiento a tu correo electrónico.'
                          : 'Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: ZendfastSpacing.xl),

                    if (!_emailSent) ...[
                      // Email field
                      AuthTextField(
                        controller: _emailController,
                        label: 'Correo electrónico',
                        hint: 'tu@email.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        validator: _validateEmail,
                        enabled: !_isLoading,
                        onSubmitted: (_) => _handleSendResetLink(),
                      ),
                      const SizedBox(height: ZendfastSpacing.xl),

                      // Send reset link button
                      AuthButton(
                        text: 'Enviar Enlace de Restablecimiento',
                        onPressed: _handleSendResetLink,
                        isLoading: _isLoading,
                        icon: Icons.send,
                      ),
                    ] else ...[
                      // Success message box
                      Container(
                        padding: const EdgeInsets.all(ZendfastSpacing.l),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.green.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Correo enviado a:',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: ZendfastSpacing.s),
                            Text(
                              _emailController.text.trim(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                            ),
                            const SizedBox(height: ZendfastSpacing.m),
                            const Text(
                              'Revisa tu bandeja de entrada y sigue las instrucciones para restablecer tu contraseña.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: ZendfastSpacing.l),

                      // Resend button
                      AuthButton(
                        text: 'Reenviar Correo',
                        onPressed: () {
                          setState(() => _emailSent = false);
                        },
                        isSecondary: true,
                        icon: Icons.refresh,
                      ),
                    ],

                    const SizedBox(height: ZendfastSpacing.l),

                    // Back to login button
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => context.go('/auth/login'),
                      child: const Text('Volver al Inicio de Sesión'),
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
