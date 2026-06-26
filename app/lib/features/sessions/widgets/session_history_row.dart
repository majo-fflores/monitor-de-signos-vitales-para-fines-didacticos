import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/models/measurement_record.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/history_provider.dart';
import '../../../../shared/providers/session_provider.dart';
import '../../../../shared/providers/user_provider.dart';
import 'session_raw_data_table.dart';

class SessionHistoryRow extends ConsumerWidget {
  final MeasurementRecord record;
  final bool esMobile;
  final bool isExpanded;
  final VoidCallback onTap;

  const SessionHistoryRow({
    super.key,
    required this.record,
    required this.esMobile,
    required this.isExpanded,
    required this.onTap,
  });

  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    final sessionId = int.tryParse(record.id);
    if (sessionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'No se pudo identificar la sesión para exportar.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    try {
      final path = await ref
          .read(sessionApiServiceProvider)
          .exportSessionCsv(sessionId);
      if (path == null) return; // Se canceló la selección de archivo
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'CSV exportado: $path',
            style: const TextStyle(color: Colors.white),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al exportar CSV: $e',
            style: const TextStyle(color: Colors.white),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeUser = ref.watch(usersNotifierProvider).activeUser;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Fila principal (clickeable)
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                AnimatedRotation(
                  turns: isExpanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    LucideIcons.chevronRight,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                if (record.alertsTriggered > 0) ...[
                  const SizedBox(width: 6),
                  Tooltip(
                    message:
                        '${record.alertsTriggered} alertas registradas en esta sesión',
                    child: const Icon(
                      LucideIcons.alertTriangle,
                      size: 14,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Text(
                    record.formattedDate,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 17,
                    ),
                  ),
                ),
                if (!esMobile) ...[
                  Expanded(
                    flex: 2,
                    child: Text(
                      record.formattedDuration,
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 17),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Columna FC: MÍN / PROM / MÁX
                  Expanded(
                    flex: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: SensorColors.ecgGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${record.minHeartRate} | ${record.heartRate} | ${record.maxHeartRate}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'LPM',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? DarkColors.mutedForeground
                                : LightColors.mutedForeground,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Columna CO2: MÍN / PROM / MÁX
                  Expanded(
                    flex: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: SensorColors.co2Yellow,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${record.minCo2} | ${record.co2Level} | ${record.maxCo2}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ppm',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? DarkColors.mutedForeground
                                : LightColors.mutedForeground,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // Acciones
                SizedBox(
                  width: 72,
                  height: 32,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Tooltip(
                        message: 'Exportar CSV',
                        child: IconButton(
                          icon: const Icon(LucideIcons.download, size: 14),
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.75,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(
                            width: 32,
                            height: 32,
                          ),
                          onPressed: () => _exportCsv(context, ref),
                        ),
                      ),
                      Tooltip(
                        message: 'Eliminar sesión',
                        child: IconButton(
                          icon: const Icon(LucideIcons.trash2, size: 14),
                          color: theme.colorScheme.error.withValues(alpha: 0.6),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(
                            width: 32,
                            height: 32,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('¿Eliminar sesión?'),
                                content: const Text(
                                  'Se eliminará permanentemente esta medición.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Cancelar'),
                                  ),
                                  FilledButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      if (activeUser != null) {
                                        ref
                                            .read(
                                              historyNotifierProvider.notifier,
                                            )
                                            .deleteRecord(
                                              record.id,
                                              activeUser.id,
                                            );
                                      }
                                    },
                                    style: FilledButton.styleFrom(
                                      backgroundColor: theme.colorScheme.error,
                                      foregroundColor:
                                          theme.colorScheme.onError,
                                    ),
                                    child: const Text('Eliminar'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Panel expandido con detalles completos
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(44, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SessionRawDataTable(sessionId: int.parse(record.id)),
                if (record.clinicalNotes.isNotEmpty) ...[
                  const Gap(12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.02)
                          : Colors.black.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? DarkColors.border : LightColors.border,
                      ),
                    ),
                    child: Text(
                      record.clinicalNotes,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ],
            ),
          ),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
          sizeCurve: Curves.easeOut,
        ),
      ],
    );
  }
}
