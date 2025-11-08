import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../services/consent_manager.dart';
import '../../models/user_consent.dart';

/// Consent Management Screen - Granular consent controls for GDPR/CCPA
/// Allows users to control how their data is processed
class ConsentManagementScreen extends ConsumerStatefulWidget {
  const ConsentManagementScreen({super.key});

  @override
  ConsumerState<ConsentManagementScreen> createState() =>
      _ConsentManagementScreenState();
}

class _ConsentManagementScreenState
    extends ConsumerState<ConsentManagementScreen> {
  Map<ConsentType, bool> _consents = {};
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadConsents();
  }

  Future<void> _loadConsents() async {
    final userId = ref.read(authNotifierProvider).userId;
    if (userId == null) return;

    setState(() => _isLoading = true);

    final consents = await ConsentManager.instance.getAllConsents(userId);

    setState(() {
      _consents = consents;
      _isLoading = false;
    });
  }

  Future<void> _saveConsents() async {
    final userId = ref.read(authNotifierProvider).userId;
    if (userId == null) return;

    setState(() => _isSaving = true);

    try {
      // Update each consent
      for (final entry in _consents.entries) {
        await ConsentManager.instance.updateConsent(
          userId: userId,
          consentType: entry.key,
          granted: entry.value,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Consentimientos guardados correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Consentimientos'),
        elevation: 0,
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _isSaving ? null : _saveConsents,
              child: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Explanation
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Control de Privacidad',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Controla cómo procesamos tus datos. Puedes cambiar estos permisos en cualquier momento.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Consent toggles
                ...ConsentType.values.map((type) {
                  return Column(
                    children: [
                      _buildConsentToggle(type),
                      const SizedBox(height: 12),
                    ],
                  );
                }),
              ],
            ),
    );
  }

  Widget _buildConsentToggle(ConsentType type) {
    final consent = UserConsent(
      userId: '', // Dummy - just for display info
      consentType: type,
    );

    return Card(
      child: SwitchListTile(
        value: _consents[type] ?? false,
        onChanged: (value) {
          setState(() {
            _consents[type] = value;
          });
        },
        title: Text(
          consent.displayName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          consent.description,
          style: const TextStyle(fontSize: 12),
        ),
        secondary: Icon(
          _getIconForConsentType(type),
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  IconData _getIconForConsentType(ConsentType type) {
    switch (type) {
      case ConsentType.analyticsTracking:
        return Icons.analytics;
      case ConsentType.marketingCommunications:
        return Icons.email;
      case ConsentType.dataProcessing:
        return Icons.cloud_sync;
      case ConsentType.nonEssentialCookies:
        return Icons.cookie;
      case ConsentType.doNotSellData:
        return Icons.money_off;
      case ConsentType.privacyPolicy:
        return Icons.privacy_tip;
      case ConsentType.termsOfService:
        return Icons.gavel;
    }
  }
}
