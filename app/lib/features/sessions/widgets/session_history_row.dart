import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/models/registro_medicion.dart';
import '../../../../shared/providers/historial_provider.dart';
import '../../../../shared/providers/usuario_provider.dart';
import 'metrica_inline.dart';

class SessionHistoryRow extends ConsumerWidget {
  final RegistroMedicion registro;
  final bool esMobile;
  final bool expandida;
  final VoidCallback onTap;

  const SessionHistoryRow({
    super.key,
    required this.registro,
    required this.esMobile,
    required this.expandida,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final esOscuro = theme.brightness == Brightness.dark;
    final usuarioActivo = ref.watch(notificadorUsuariosProvider).usuarioActivo;

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
                  turns: expandida ? 0.25 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    LucideIcons.chevronRight,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Text(
                    registro.fechaFormateada,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (!esMobile) ...[
                  Expanded(
                    flex: 2,
                    child: Text(
                      registro.duracionFormateada,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: ColoresSensores.ecgVerde,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${registro.frecuenciaCardiaca} LPM',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: ColoresSensores.spo2Azul,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${registro.nivelSpo2}%',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
                // Botón eliminar
                SizedBox(
                  width: 32,
                  height: 32,
                  child: IconButton(
                    icon: const Icon(LucideIcons.trash2, size: 14),
                    color: theme.colorScheme.error.withValues(alpha: 0.6),
                    padding: EdgeInsets.zero,
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
                                if (usuarioActivo != null) {
                                  ref
                                      .read(notificadorHistorialProvider.notifier)
                                      .eliminarRegistro(
                                        registro.id,
                                        usuarioActivo.id,
                                      );
                                }
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: theme.colorScheme.error,
                                foregroundColor: theme.colorScheme.onError,
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
                // Grid compacto de métricas
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    MetricaInline(
                      label: 'Frecuencia Cardíaca (ECG)',
                      value: '${registro.frecuenciaCardiaca} LPM',
                      color: ColoresSensores.ecgVerde,
                      theme: theme,
                      esOscuro: esOscuro,
                    ),
                    MetricaInline(
                      label: 'Pulso (PPG)',
                      value: '${registro.ppgFrecuenciaCardiaca} LPM',
                      color: ColoresSensores.spo2Azul,
                      theme: theme,
                      esOscuro: esOscuro,
                    ),
                    MetricaInline(
                      label: 'SpO2',
                      value: '${registro.nivelSpo2}%',
                      color: ColoresSensores.spo2Azul,
                      theme: theme,
                      esOscuro: esOscuro,
                    ),
                    MetricaInline(
                      label: 'CO2',
                      value: '${registro.nivelCo2} ppm',
                      color: ColoresSensores.co2Amarillo,
                      theme: theme,
                      esOscuro: esOscuro,
                    ),
                    MetricaInline(
                      label: 'Duración',
                      value: registro.duracionFormateada,
                      color: const Color(0xFFF59E0B),
                      theme: theme,
                      esOscuro: esOscuro,
                    ),
                    if (registro.alertasDisparadas > 0)
                      MetricaInline(
                        label: 'Alertas',
                        value: '${registro.alertasDisparadas}',
                        color: theme.colorScheme.error,
                        theme: theme,
                        esOscuro: esOscuro,
                      ),
                  ],
                ),
                if (registro.notasClinicas.isNotEmpty) ...[
                  const Gap(12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: esOscuro
                          ? Colors.white.withValues(alpha: 0.02)
                          : Colors.black.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: esOscuro
                            ? ColoresOscuros.border
                            : ColoresClaros.border,
                      ),
                    ),
                    child: Text(
                      registro.notasClinicas,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ],
            ),
          ),
          crossFadeState:
              expandida ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
          sizeCurve: Curves.easeOut,
        ),
      ],
    );
  }
}
