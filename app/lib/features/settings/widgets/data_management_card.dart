import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../shared/providers/historial_alarmas_provider.dart';

class DataManagementCard extends ConsumerWidget {
  final Color subtitleColor;
  final Color borderColor;

  const DataManagementCard({
    super.key,
    required this.subtitleColor,
    required this.borderColor,
  });

  Future<void> _exportarDatos(
    BuildContext context,
    List<RegistroAlarma> historial,
  ) async {
    try {
      final jsonStr = jsonEncode(historial.map((r) => r.toJson()).toList());

      // Intentamos escribir en la carpeta de Descargas del usuario
      final homeDir = Platform.environment['HOME'] ?? '/home/lk';
      final descargasDir = Directory('$homeDir/Downloads');

      String rutaArchivo;
      if (await descargasDir.exists()) {
        rutaArchivo = '${descargasDir.path}/datavital_alarm_history.json';
      } else {
        // Fallback al directorio temporal del sistema o al workspace
        rutaArchivo = './datavital_alarm_history.json';
      }

      final archivo = File(rutaArchivo);
      await archivo.writeAsString(jsonStr);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Historial exportado con éxito a: $rutaArchivo',
              style: const TextStyle(color: Colors.white),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al exportar: $e',
              style: const TextStyle(color: Colors.white),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _confirmarLimpieza(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          title: Row(
            children: [
              Icon(LucideIcons.alertTriangle, color: theme.colorScheme.error),
              const Gap(10),
              const Text('Confirmar Eliminación'),
            ],
          ),
          content: const Text(
            '¿Está seguro de que desea eliminar todo el historial de alarmas? Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(historialAlarmasProvider.notifier).limpiarHistorial();
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Historial de alarmas eliminado.',
                      style: TextStyle(color: Colors.white),
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              child: const Text('Eliminar Todo'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final historial = ref.watch(historialAlarmasProvider);
    final totalAlarmas = historial.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.database, color: theme.colorScheme.primary),
              const Gap(10),
              Text(
                'Gestión de Datos',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Gap(8),
          Text(
            'Administre los registros históricos de alarmas, exporte los eventos a formato JSON o limpie la base de datos.',
            style: theme.textTheme.bodySmall?.copyWith(color: subtitleColor),
          ),
          const Gap(24),

          // Información del espacio / tamaño
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alarmas Registradas',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: subtitleColor,
                    ),
                  ),
                  Text(
                    '$totalAlarmas eventos',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Espacio Utilizado',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: subtitleColor,
                    ),
                  ),
                  Text(
                    '~${(totalAlarmas * 0.15).toStringAsFixed(2)} KB',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Gap(20),
          const Divider(),
          const Gap(16),

          // Acciones
          LayoutBuilder(
            builder: (context, constraints) {
              final useVertical = constraints.maxWidth < 450;
              final buttons = [
                Expanded(
                  flex: useVertical ? 0 : 1,
                  child: ElevatedButton.icon(
                    onPressed: totalAlarmas > 0
                        ? () => _exportarDatos(context, historial)
                        : null,
                    icon: const Icon(LucideIcons.download, size: 16),
                    label: const Text('Exportar JSON'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                Gap(useVertical ? 10 : 16),
                Expanded(
                  flex: useVertical ? 0 : 1,
                  child: OutlinedButton.icon(
                    onPressed: totalAlarmas > 0
                        ? () => _confirmarLimpieza(context, ref)
                        : null,
                    icon: const Icon(LucideIcons.trash2, size: 16),
                    label: const Text('Limpiar Historial'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(
                        color: totalAlarmas > 0
                            ? theme.colorScheme.error
                            : borderColor,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ];

              return useVertical
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: buttons
                          .map((w) => w is Expanded ? w.child : w)
                          .toList(),
                    )
                  : Row(children: buttons);
            },
          ),
        ],
      ),
    );
  }
}
