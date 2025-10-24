import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/auth_computed_providers.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/auth_button.dart';
import '../../theme/spacing.dart';

/// Login screen with email and password authentication
/// Includes validation, loading states, and navigation to register/forgot password
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true; // Supabase handles session persistence by default
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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

  /// Validate password
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }

    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }

    return null;
  }

  /// Handle login button press
  Future<void> _handleLogin() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authNotifierProvider.notifier).signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      // Check if login was successful by watching auth state
      final authState = ref.read(authNotifierProvider);

      if (mounted) {
        if (authState.isAuthenticated) {
          // Navigation is handled by GoRouter redirect
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inicio de sesión exitoso'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else if (authState.errorMessage != null) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authState.errorMessage!),
              backgroundColor: Theme.of(context).colorScheme.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state for automatic navigation
    ref.listen(isAuthenticatedProvider, (previous, next) {
      if (next && mounted) {
        // User is now authenticated, GoRouter will handle navigation
      }
    });

    return Scaffold(
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
                    // App logo or title
                    Icon(
                      Icons.self_improvement,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: ZendfastSpacing.l),

                    // Welcome text
                    Text(
                      'Bienvenido a Zendfast',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: ZendfastSpacing.s),
                    Text(
                      'Inicia sesión para continuar',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: ZendfastSpacing.xl),

                    // Email field
                    AuthTextField(
                      controller: _emailController,
                      label: 'Correo electrónico',
                      hint: 'tu@email.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: _validateEmail,
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: ZendfastSpacing.m),

                    // Password field
                    AuthTextField(
                      controller: _passwordController,
                      label: 'Contraseña',
                      hint: 'Tu contraseña',
                      prefixIcon: Icons.lock_outlined,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      validator: _validatePassword,
                      enabled: !_isLoading,
                      onSubmitted: (_) => _handleLogin(),
                    ),
                    const SizedBox(height: ZendfastSpacing.m),

                    // Remember me checkbox and forgot password link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: _isLoading
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _rememberMe = value ?? true;
                                      });
                                    },
                            ),
                            Text(
                              'Recordarme',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () => context.go('/auth/forgot-password'),
                          child: const Text('¿Olvidaste tu contraseña?'),
                        ),
                      ],
                    ),
                    const SizedBox(height: ZendfastSpacing.l),

                    // Login button
                    AuthButton(
                      text: 'Iniciar Sesión',
                      onPressed: _handleLogin,
                      isLoading: _isLoading,
                      icon: Icons.login,
                    ),
                    const SizedBox(height: ZendfastSpacing.m),

                    // Divider
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: ZendfastSpacing.m,
                          ),
                          child: Text(
                            'o',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: ZendfastSpacing.m),

                    // Register button
                    AuthButton(
                      text: 'Crear Cuenta Nueva',
                      onPressed: _isLoading
                          ? null
                          : () => context.go('/auth/register'),
                      isSecondary: true,
                      icon: Icons.person_add_outlined,
                    ),
                    const SizedBox(height: ZendfastSpacing.l),

                    // Info text about remember me
                    if (_rememberMe)
                      Text(
                        'Tu sesión se mantendrá activa en este dispositivo',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                        textAlign: TextAlign.center,
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
