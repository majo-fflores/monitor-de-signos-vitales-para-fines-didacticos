import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SaveSessionDialog extends StatefulWidget {
  final int segundosGrabacion;
  final int fcProm;
  final int ppgProm;
  final int co2Prom;
  final int? alertCount;
  final ValueChanged<String> onSave;
  final VoidCallback onCancel;

  const SaveSessionDialog({
    super.key,
    required this.segundosGrabacion,
    required this.fcProm,
    required this.ppgProm,
    required this.co2Prom,
    this.alertCount,
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
          Text('• Prom. CO2: ${widget.co2Prom} ppm'),
          if (widget.alertCount != null && widget.alertCount! > 0) ...[
            const Gap(4),
            Row(
              children: [
                const Icon(
                  LucideIcons.alertTriangle,
                  color: Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Alertas disparadas: ${widget.alertCount}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
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
