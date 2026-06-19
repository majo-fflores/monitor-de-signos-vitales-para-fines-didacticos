import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/alarm_history_provider.dart';

class AlarmHistoryCard extends ConsumerWidget {
  final Color subtitleColor;
  final Color borderColor;

  const AlarmHistoryCard({
    super.key,
    required this.subtitleColor,
    required this.borderColor,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    final timeStr =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';

    if (difference.inSeconds < 10) {
      return 'Ahora mismo ($timeStr)';
    } else if (difference.inSeconds < 60) {
      return 'Hace ${difference.inSeconds} seg ($timeStr)';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min ($timeStr)';
    } else if (difference.inHours < 24) {
      return 'Hoy a las $timeStr';
    } else {
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      return '$day/$month $timeStr';
    }
  }

  IconData _getMetricIcon(String metric) {
    if (metric.toLowerCase().contains('frecuencia') ||
        metric.toLowerCase().contains('cardíaca')) {
      return LucideIcons.heart;
    } else if (metric.toLowerCase().contains('saturación') ||
        metric.toLowerCase().contains('oxígeno')) {
      return LucideIcons.droplets;
    } else if (metric.toLowerCase().contains('dióxido') ||
        metric.toLowerCase().contains('carbono') ||
        metric.toLowerCase().contains('co2')) {
      return LucideIcons.wind;
    }
    return LucideIcons.alertTriangle;
  }

  Color _getMetricColor(String metric) {
    if (metric.toLowerCase().contains('frecuencia') ||
        metric.toLowerCase().contains('cardíaca')) {
      return SensorColors.ecgGreen;
    } else if (metric.toLowerCase().contains('saturación') ||
        metric.toLowerCase().contains('oxígeno')) {
      return SensorColors.spo2Blue;
    } else if (metric.toLowerCase().contains('dióxido') ||
        metric.toLowerCase().contains('carbono') ||
        metric.toLowerCase().contains('co2')) {
      return SensorColors.co2Yellow;
    }
    return Colors.red;
  }

  String _getMetricUnit(String metric) {
    if (metric.toLowerCase().contains('frecuencia') ||
        metric.toLowerCase().contains('cardíaca')) {
      return 'LPM';
    } else if (metric.toLowerCase().contains('saturación') ||
        metric.toLowerCase().contains('oxígeno')) {
      return '%';
    } else if (metric.toLowerCase().contains('dióxido') ||
        metric.toLowerCase().contains('carbono') ||
        metric.toLowerCase().contains('co2')) {
      return 'PPM';
    }
    return '';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final history = ref.watch(alarmHistoryProvider);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera de la Tarjeta
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              children: [
                Icon(LucideIcons.history, color: theme.colorScheme.primary),
                const Gap(10),
                Text(
                  'Historial de Alarmas Recientes',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (history.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      ref.read(alarmHistoryProvider.notifier).clearHistory();
                    },
                    icon: const Icon(LucideIcons.trash2, size: 18),
                    tooltip: 'Limpiar Historial',
                    style: IconButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Cuerpo de la tarjeta
          if (history.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 48,
                  horizontal: 24,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: SensorColors.statusConnected.withValues(
                          alpha: 0.1,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.shieldCheck,
                        size: 36,
                        color: SensorColors.statusConnected,
                      ),
                    ),
                    const Gap(16),
                    Text(
                      'Monitoreo Estable',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(6),
                    Text(
                      'No se han disparado alertas críticas en esta sesión.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: subtitleColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.length > 5 ? 5 : history.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final record = history[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                LucideIcons.bell,
                                size: 14,
                                color: Colors.redAccent,
                              ),
                              const Gap(8),
                              Text(
                                'Alerta Crítica Detectada',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.red[200]
                                      : Colors.red[900],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            _formatDate(record.timestamp),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                      const Gap(10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: record.values.entries.map((entry) {
                          final colorMetrica = _getMetricColor(entry.key);
                          final iconoMetrica = _getMetricIcon(entry.key);
                          final unidad = _getMetricUnit(entry.key);

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: colorMetrica.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: colorMetrica.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  iconoMetrica,
                                  size: 14,
                                  color: colorMetrica,
                                ),
                                const Gap(6),
                                Text(
                                  '${entry.key}: ',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                ),
                                Text(
                                  '${entry.value} $unidad',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorMetrica,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              },
            ),

          if (history.length > 5) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'Mostrando las últimas 5 de ${history.length} alertas',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: subtitleColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
