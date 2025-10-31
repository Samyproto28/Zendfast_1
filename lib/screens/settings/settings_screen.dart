import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';

/// Settings Screen - Main app settings and preferences
/// Provides access to account, privacy, notifications, and app preferences
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isLoggingOut = false;

  Future<void> _handleLogout() async {
    // Confirm logout
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoggingOut = true);

    try {
      await AuthService.instance.signOut();
      if (!mounted) return;
      context.go('/auth/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cerrar sesión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).user;
    final userEmail = user?.email ?? 'Sin email';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // User Info Section
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    userEmail.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cuenta',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userEmail,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Account Section
          _buildSectionHeader('Cuenta'),
          _buildSettingsTile(
            icon: Icons.person,
            title: 'Perfil de Usuario',
            subtitle: 'Edita tu información personal',
            onTap: () {
              // TODO: Navigate to profile edit screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Próximamente: Editar perfil')),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.lock,
            title: 'Cambiar Contraseña',
            subtitle: 'Actualiza tu contraseña',
            onTap: () {
              // TODO: Navigate to change password screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Próximamente: Cambiar contraseña'),
                ),
              );
            },
          ),

          const Divider(height: 32),

          // Privacy & Security Section
          _buildSectionHeader('Privacidad y Seguridad'),
          _buildSettingsTile(
            icon: Icons.privacy_tip,
            title: 'Mis Derechos de Privacidad',
            subtitle: 'GDPR/CCPA: Exportar datos, eliminar cuenta, consentimientos',
            onTap: () => context.push('/data-rights'),
            highlighted: true,
          ),
          _buildSettingsTile(
            icon: Icons.policy,
            title: 'Política de Privacidad',
            subtitle: 'Lee nuestra política de privacidad',
            onTap: () => context.push('/privacy-policy'),
          ),
          _buildSettingsTile(
            icon: Icons.shield,
            title: 'Términos y Condiciones',
            subtitle: 'Términos de uso de la aplicación',
            onTap: () {
              // TODO: Navigate to terms screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Próximamente: Términos y Condiciones'),
                ),
              );
            },
          ),

          const Divider(height: 32),

          // Notifications Section
          _buildSectionHeader('Notificaciones'),
          _buildSettingsTile(
            icon: Icons.notifications,
            title: 'Notificaciones Push',
            subtitle: 'Configura alertas y recordatorios',
            onTap: () {
              // TODO: Navigate to notifications settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Próximamente: Configurar notificaciones'),
                ),
              );
            },
          ),

          const Divider(height: 32),

          // App Preferences Section
          _buildSectionHeader('Preferencias'),
          _buildSettingsTile(
            icon: Icons.language,
            title: 'Idioma',
            subtitle: 'Español',
            onTap: () {
              // TODO: Language selector
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Próximamente: Selector de idioma')),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.dark_mode,
            title: 'Tema',
            subtitle: 'Claro, Oscuro, Sistema',
            onTap: () {
              // TODO: Theme selector
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Próximamente: Selector de tema')),
              );
            },
          ),

          const Divider(height: 32),

          // About Section
          _buildSectionHeader('Acerca de'),
          _buildSettingsTile(
            icon: Icons.info,
            title: 'Acerca de Zendfast',
            subtitle: 'Versión 1.0.0',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Zendfast',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.spa, size: 48),
                children: [
                  const Text(
                    'Aplicación de ayuno intermitente para mejorar tu salud y bienestar.',
                  ),
                ],
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.help,
            title: 'Ayuda y Soporte',
            subtitle: 'Centro de ayuda y FAQ',
            onTap: () {
              // TODO: Navigate to help center
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Próximamente: Centro de ayuda')),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.bug_report,
            title: 'Reportar un Problema',
            subtitle: 'Ayúdanos a mejorar',
            onTap: () {
              // TODO: Navigate to bug report screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Próximamente: Reportar problema'),
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: _isLoggingOut ? null : _handleLogout,
              icon: _isLoggingOut
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.logout),
              label: Text(_isLoggingOut ? 'Cerrando sesión...' : 'Cerrar Sesión'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Footer
          Center(
            child: Text(
              'Zendfast © 2025',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool highlighted = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: highlighted
              ? Theme.of(context).primaryColor.withOpacity(0.2)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: highlighted ? Theme.of(context).primaryColor : Colors.grey[700],
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: highlighted ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
