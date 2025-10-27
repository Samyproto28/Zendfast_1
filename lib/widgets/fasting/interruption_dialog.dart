import 'package:flutter/material.dart';
import '../../theme/spacing.dart';

/// Dialog shown when user interrupts a fasting session
/// Allows user to select a reason or provide custom text
class InterruptionDialog extends StatefulWidget {
  const InterruptionDialog({super.key});

  @override
  State<InterruptionDialog> createState() => _InterruptionDialogState();
}

class _InterruptionDialogState extends State<InterruptionDialog> {
  String? _selectedReason;
  final _customReasonController = TextEditingController();
  bool _showCustomTextField = false;

  // Predefined interruption reasons
  static const List<String> _predefinedReasons = [
    'Me sentí con hambre',
    'No me sentía bien',
    'Evento social',
    'Emergencia',
    'Falta de energía',
    'Problemas de sueño',
    'Estrés/ansiedad',
    'Tentación',
  ];

  @override
  void dispose() {
    _customReasonController.dispose();
    super.dispose();
  }

  void _handleReasonSelect(String reason) {
    setState(() {
      _selectedReason = reason;
      _showCustomTextField = false;
      _customReasonController.clear();
    });
  }

  void _handleCustomReasonSelect() {
    setState(() {
      _selectedReason = null;
      _showCustomTextField = true;
    });
  }

  void _handleConfirm() {
    String? finalReason;

    if (_showCustomTextField && _customReasonController.text.trim().isNotEmpty) {
      finalReason = _customReasonController.text.trim();
    } else if (_selectedReason != null) {
      finalReason = _selectedReason;
    }

    Navigator.of(context).pop(finalReason);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canConfirm = _selectedReason != null ||
        (_showCustomTextField && _customReasonController.text.trim().isNotEmpty);

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.pause_circle_outline,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: ZendfastSpacing.s),
          const Expanded(
            child: Text('¿Por qué interrumpes tu ayuno?'),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecciona una razón (opcional):',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: ZendfastSpacing.m),

            // Predefined reason chips
            Wrap(
              spacing: ZendfastSpacing.s,
              runSpacing: ZendfastSpacing.s,
              children: [
                // Predefined reasons
                ..._predefinedReasons.map(
                  (reason) => FilterChip(
                    label: Text(reason),
                    selected: _selectedReason == reason,
                    onSelected: (_) => _handleReasonSelect(reason),
                    showCheckmark: false,
                  ),
                ),

                // "Otro" chip for custom reason
                FilterChip(
                  label: const Text('Otro'),
                  selected: _showCustomTextField,
                  onSelected: (_) => _handleCustomReasonSelect(),
                  showCheckmark: false,
                ),
              ],
            ),

            // Custom reason text field (shown when "Otro" is selected)
            if (_showCustomTextField) ...[
              const SizedBox(height: ZendfastSpacing.m),
              TextField(
                controller: _customReasonController,
                decoration: const InputDecoration(
                  hintText: 'Escribe tu razón...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                autofocus: true,
                onChanged: (_) => setState(() {}),
              ),
            ],

            const SizedBox(height: ZendfastSpacing.m),

            // Info text
            Container(
              padding: const EdgeInsets.all(ZendfastSpacing.s),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: ZendfastSpacing.s),
                  Expanded(
                    child: Text(
                      'Esta información nos ayuda a mejorar tu experiencia.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: canConfirm ? _handleConfirm : null,
          child: const Text('Confirmar'),
        ),
      ],
    );
  }

}
