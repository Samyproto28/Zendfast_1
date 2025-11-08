import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/supabase_config.dart';
import '../../models/terms_of_service.dart';

/// Terms of Service Screen - displays the current terms and conditions
/// Loads dynamically from Supabase for easy updates
/// Supports Spanish and English with language switcher
class TermsOfServiceScreen extends ConsumerStatefulWidget {
  const TermsOfServiceScreen({super.key});

  @override
  ConsumerState<TermsOfServiceScreen> createState() =>
      _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends ConsumerState<TermsOfServiceScreen> {
  bool _isLoading = true;
  TermsOfService? _terms;
  String? _error;
  String _currentLanguage = 'es'; // Default to Spanish

  @override
  void initState() {
    super.initState();
    _loadTermsOfService();
  }

  Future<void> _loadTermsOfService() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await SupabaseConfig.from('terms_of_service')
          .select()
          .eq('is_active', true)
          .eq('language', _currentLanguage)
          .maybeSingle();

      if (response != null) {
        final terms = TermsOfService.fromJson(response);
        setState(() {
          _terms = terms;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = _currentLanguage == 'es'
              ? 'No se encontraron los términos y condiciones'
              : 'Terms of Service not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = _currentLanguage == 'es'
            ? 'Error al cargar los términos y condiciones: $e'
            : 'Error loading Terms of Service: $e';
        _isLoading = false;
      });
    }
  }

  void _switchLanguage(String newLanguage) {
    if (newLanguage != _currentLanguage) {
      setState(() {
        _currentLanguage = newLanguage;
      });
      _loadTermsOfService();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentLanguage == 'es'
            ? 'Términos y Condiciones'
            : 'Terms and Conditions'),
        elevation: 0,
        actions: [
          // Language switcher
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            tooltip: _currentLanguage == 'es'
                ? 'Cambiar idioma'
                : 'Change language',
            onSelected: _switchLanguage,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'es',
                child: Row(
                  children: [
                    Icon(
                      _currentLanguage == 'es'
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('Español'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'en',
                child: Row(
                  children: [
                    Icon(
                      _currentLanguage == 'en'
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('English'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadTermsOfService,
                          child: Text(_currentLanguage == 'es'
                              ? 'Reintentar'
                              : 'Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _terms == null
                  ? Center(
                      child: Text(_currentLanguage == 'es'
                          ? 'No hay términos disponibles'
                          : 'No terms available'),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Version info card
                          Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.gavel,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _currentLanguage == 'es'
                                              ? 'Versión ${_terms!.version}'
                                              : 'Version ${_terms!.version}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          _currentLanguage == 'es'
                                              ? 'Vigente desde: ${_terms!.formattedEffectiveDate}'
                                              : 'Effective from: ${_terms!.formattedEffectiveDate}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Important notice
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.error.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: theme.colorScheme.error,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _currentLanguage == 'es'
                                        ? 'IMPORTANTE: Zendfast NO proporciona asesoramiento médico. Consulta con un profesional de la salud antes de comenzar cualquier programa de ayuno.'
                                        : 'IMPORTANT: Zendfast DOES NOT provide medical advice. Consult with a healthcare professional before starting any fasting program.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: theme.colorScheme.onErrorContainer,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Terms content
                          SelectableText(
                            _terms!.content,
                            style: const TextStyle(
                              height: 1.6,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Footer actions
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.check),
                              label: Text(_currentLanguage == 'es'
                                  ? 'He leído y entiendo'
                                  : 'I have read and understand'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
    );
  }
}
