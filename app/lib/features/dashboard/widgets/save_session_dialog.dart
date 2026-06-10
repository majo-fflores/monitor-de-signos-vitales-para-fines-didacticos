import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SaveSessionDialog extends StatefulWidget {
  final int segundosGrabacion;
  final int fcProm;
  final int ppgProm;
  final int spo2Prom;
  final int co2Prom;
  final ValueChanged<String> onSave;
  final VoidCallback onCancel;

  const SaveSessionDialog({
    super.key,
    required this.segundosGrabacion,
    required this.fcProm,
    required this.ppgProm,
    required this.spo2Prom,
    required this.co2Prom,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<SaveSessionDialog> createState() => _SaveSessionDialogState();
}

class _SaveSessionDialogState extends State<SaveSessionDialog> {
  late TextEditingController _notasController;

  @override
  void initState() {
    super.initState();
    _notasController = TextEditingController();
  }

  @override
  void dispose() {
    _notasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Icon(LucideIcons.save, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Guardar Medición'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen de la sesión:',
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Gap(8),
          Text('• Duración: ${widget.segundosGrabacion} segundos'),
          Text('• Prom. Cardíaco (ECG): ${widget.fcProm} LPM'),
          Text('• Prom. Pulso (PPG): ${widget.ppgProm} LPM'),
          // Text('• Prom. SpO2: ${widget.spo2Prom}%'),
          Text('• Prom. CO2: ${widget.co2Prom} ppm'),
          const Gap(16),
          TextField(
            controller: _notasController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Notas y Observaciones Clínicas',
              hintText: 'Ej. Paciente estable durante la prueba...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: const Text('Descartar'),
        ),
        FilledButton(
          onPressed: () {
            widget.onSave(_notasController.text.trim());
          },
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
