import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/historial_alarmas_provider.dart';

class AlarmHistoryCard extends ConsumerWidget {
  final Color subtitleColor;
  final Color borderColor;

  const AlarmHistoryCard({
    super.key,
    required this.subtitleColor,
    required this.borderColor,
  });

  String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);

    final horaMin =
        '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}:${fecha.second.toString().padLeft(2, '0')}';

    if (diferencia.inSeconds < 10) {
      return 'Ahora mismo ($horaMin)';
    } else if (diferencia.inSeconds < 60) {
      return 'Hace ${diferencia.inSeconds} seg ($horaMin)';
    } else if (diferencia.inMinutes < 60) {
      return 'Hace ${diferencia.inMinutes} min ($horaMin)';
    } else if (diferencia.inHours < 24) {
      return 'Hoy a las $horaMin';
    } else {
      final dia = fecha.day.toString().padLeft(2, '0');
      final mes = fecha.month.toString().padLeft(2, '0');
      return '$dia/$mes $horaMin';
    }
  }

  IconData _obtenerIconoMetrica(String metrica) {
    if (metrica.toLowerCase().contains('frecuencia') ||
        metrica.toLowerCase().contains('cardíaca')) {
      return LucideIcons.heart;
    } else if (metrica.toLowerCase().contains('saturación') ||
        metrica.toLowerCase().contains('oxígeno')) {
      return LucideIcons.droplets;
    } else if (metrica.toLowerCase().contains('dióxido') ||
        metrica.toLowerCase().contains('carbono') ||
        metrica.toLowerCase().contains('co2')) {
      return LucideIcons.wind;
    }
    return LucideIcons.alertTriangle;
  }

  Color _obtenerColorMetrica(String metrica) {
    if (metrica.toLowerCase().contains('frecuencia') ||
        metrica.toLowerCase().contains('cardíaca')) {
      return ColoresSensores.ecgVerde;
    } else if (metrica.toLowerCase().contains('saturación') ||
        metrica.toLowerCase().contains('oxígeno')) {
      return ColoresSensores.spo2Azul;
    } else if (metrica.toLowerCase().contains('dióxido') ||
        metrica.toLowerCase().contains('carbono') ||
        metrica.toLowerCase().contains('co2')) {
      return ColoresSensores.co2Amarillo;
    }
    return Colors.red;
  }

  String _obtenerUnidadMetrica(String metrica) {
    if (metrica.toLowerCase().contains('frecuencia') ||
        metrica.toLowerCase().contains('cardíaca')) {
      return 'LPM';
    } else if (metrica.toLowerCase().contains('saturación') ||
        metrica.toLowerCase().contains('oxígeno')) {
      return '%';
    } else if (metrica.toLowerCase().contains('dióxido') ||
        metrica.toLowerCase().contains('carbono') ||
        metrica.toLowerCase().contains('co2')) {
      return 'PPM';
    }
    return '';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final historial = ref.watch(historialAlarmasProvider);

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
                if (historial.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      ref
                          .read(historialAlarmasProvider.notifier)
                          .limpiarHistorial();
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
          if (historial.isEmpty)
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
                        color: ColoresSensores.statusConectado.withValues(
                          alpha: 0.1,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.shieldCheck,
                        size: 36,
                        color: ColoresSensores.statusConectado,
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
              itemCount: historial.length > 5 ? 5 : historial.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final registro = historial[index];
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
                            _formatearFecha(registro.fecha),
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
                        children: registro.valores.entries.map((entry) {
                          final colorMetrica = _obtenerColorMetrica(entry.key);
                          final iconoMetrica = _obtenerIconoMetrica(entry.key);
                          final unidad = _obtenerUnidadMetrica(entry.key);

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

          if (historial.length > 5) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'Mostrando las últimas 5 de ${historial.length} alertas',
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
