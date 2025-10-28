import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_saver/file_saver.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../services/data_privacy_service.dart';
import '../../services/account_deletion_service.dart';
import '../../models/account_deletion_request.dart';

/// Data Rights Screen - GDPR/CCPA user rights hub
/// Provides access to data export, account deletion, and consent management
class DataRightsScreen extends ConsumerStatefulWidget {
  const DataRightsScreen({super.key});

  @override
  ConsumerState<DataRightsScreen> createState() => _DataRightsScreenState();
}

class _DataRightsScreenState extends ConsumerState<DataRightsScreen> {
  AccountDeletionRequest? _deletionRequest;
  bool _isLoadingDeletionStatus = true;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _checkDeletionStatus();
  }

  Future<void> _checkDeletionStatus() async {
    final userId = ref.read(authNotifierProvider).userId;
    if (userId == null) return;

    final request =
        await AccountDeletionService.instance.checkDeletionStatus(userId);
    setState(() {
      _deletionRequest = request;
      _isLoadingDeletionStatus = false;
    });
  }

  Future<void> _handleExportData() async {
    final userId = ref.read(authNotifierProvider).userId;
    if (userId == null) return;

    setState(() => _isExporting = true);

    try {
      final result =
          await DataPrivacyService.instance.exportUserData(userId);

      if (!mounted) return;

      result.when(
        success: (exportResult) async {
          // Save file
          await FileSaver.instance.saveFile(
            name: exportResult.fileName,
            bytes: await exportResult.file.readAsBytes(),
            mimeType: MimeType.zip,
          );

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Datos exportados: ${exportResult.formattedFileSize}'),
              backgroundColor: Colors.green,
            ),
          );
        },
        failure: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${error.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _handleDeleteAccount() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar Cuenta?'),
        content: const Text(
          'Esta acción iniciará el proceso de eliminación de cuenta. '
          'Tendrás 30 días para cancelar antes de que se elimine permanentemente.\n\n'
          '¿Estás seguro?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Request password
    final password = await _showPasswordDialog();
    if (password == null) return;

    final userId = ref.read(authNotifierProvider).userId;
    if (userId == null) return;

    // Request deletion
    final result = await AccountDeletionService.instance.requestAccountDeletion(
      userId: userId,
      password: password,
    );

    if (!mounted) return;

    result.when(
      success: (request) {
        setState(() => _deletionRequest = request);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cuenta programada para eliminación: ${request.formattedScheduledDate}',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      },
      failure: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  Future<String?> _showPasswordDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verificar Contraseña'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Contraseña',
            hintText: 'Ingresa tu contraseña',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _handleCancelDeletion() async {
    final userId = ref.read(authNotifierProvider).userId;
    if (userId == null) return;

    final result =
        await AccountDeletionService.instance.cancelDeletionRequest(userId);

    if (!mounted) return;

    result.when(
      success: (_) {
        setState(() => _deletionRequest = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitud de eliminación cancelada'),
            backgroundColor: Colors.green,
          ),
        );
      },
      failure: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Derechos de Privacidad'),
        elevation: 0,
      ),
      body: _isLoadingDeletionStatus
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Pending deletion warning
                if (_deletionRequest != null) ...[
                  Card(
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning, color: Colors.orange.shade700),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Eliminación Programada',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tu cuenta será eliminada el ${_deletionRequest!.formattedScheduledDate}',
                          ),
                          Text(
                            'Días restantes: ${_deletionRequest!.daysUntilDeletion}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _handleCancelDeletion,
                            icon: const Icon(Icons.cancel),
                            label: const Text('Cancelar Eliminación'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Export Data
                _buildOptionCard(
                  icon: Icons.download,
                  title: 'Exportar Mis Datos',
                  description:
                      'Descarga todos tus datos en formato ZIP (JSON + CSV)',
                  onTap: _isExporting ? null : _handleExportData,
                  loading: _isExporting,
                ),
                const SizedBox(height: 12),

                // Manage Consents
                _buildOptionCard(
                  icon: Icons.privacy_tip,
                  title: 'Gestionar Consentimientos',
                  description:
                      'Controla cómo se usan tus datos (Analytics, Marketing, etc.)',
                  onTap: () => context.push('/consent-management'),
                ),
                const SizedBox(height: 12),

                // Delete Account
                if (_deletionRequest == null)
                  _buildOptionCard(
                    icon: Icons.delete_forever,
                    title: 'Eliminar Cuenta Permanentemente',
                    description:
                        'Elimina tu cuenta y todos tus datos (período de gracia de 30 días)',
                    onTap: _handleDeleteAccount,
                    isDestructive: true,
                  ),
                const SizedBox(height: 12),

                // Privacy Policy
                _buildOptionCard(
                  icon: Icons.policy,
                  title: 'Política de Privacidad',
                  description: 'Lee nuestra política de privacidad actualizada',
                  onTap: () => context.push('/privacy-policy'),
                ),
              ],
            ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String description,
    VoidCallback? onTap,
    bool isDestructive = false,
    bool loading = false,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 40,
                color: isDestructive ? Colors.red : Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDestructive ? Colors.red : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (loading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
