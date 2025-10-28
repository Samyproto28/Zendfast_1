import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/supabase_config.dart';
import '../../models/privacy_policy.dart';

/// Privacy Policy Screen - displays the current privacy policy
/// Loads dynamically from Supabase for easy updates
class PrivacyPolicyScreen extends ConsumerStatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  ConsumerState<PrivacyPolicyScreen> createState() =>
      _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends ConsumerState<PrivacyPolicyScreen> {
  bool _isLoading = true;
  PrivacyPolicy? _policy;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPrivacyPolicy();
  }

  Future<void> _loadPrivacyPolicy() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await SupabaseConfig.from('privacy_policy')
          .select()
          .eq('is_active', true)
          .eq('language', 'es')
          .maybeSingle();

      if (response != null) {
        final policy = PrivacyPolicy.fromJson(response);
        setState(() {
          _policy = policy;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'No se encontró la política de privacidad';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error al cargar la política de privacidad: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Política de Privacidad'),
        elevation: 0,
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
                          onPressed: _loadPrivacyPolicy,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                )
              : _policy == null
                  ? const Center(child: Text('No hay política disponible'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Version info
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Versión ${_policy!.version}',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'Vigente desde: ${_policy!.formattedEffectiveDate}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Policy content
                          Text(_policy!.content),

                          const SizedBox(height: 32),

                          // Footer actions
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.check),
                              label: const Text('He leído y entiendo'),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
    );
  }
}
