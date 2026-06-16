import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/services/servicio_audio.dart';
import '../../../../shared/providers/alarma_state.dart';

class AlarmMonitoringCard extends ConsumerWidget {
  final Color subtitleColor;
  final Color borderColor;

  const AlarmMonitoringCard({
    super.key,
    required this.subtitleColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final estadoAlarma = ref.watch(notificadorAlarmaProvider);
    final notifierAlarma = ref.read(notificadorAlarmaProvider.notifier);

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
              Icon(Icons.security, color: theme.colorScheme.primary),
              const Gap(10),
              Text(
                'Monitoreo del Paciente',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Gap(8),
          Text(
            'Habilite o deshabilite el sistema de alarmas de bioseñales y configure las alertas sonoras.',
            style: theme.textTheme.bodySmall?.copyWith(color: subtitleColor),
          ),
          const Gap(16),

          // Switch para alarmas globales
          Material(
            type: MaterialType.transparency,
            child: SwitchListTile(
              title: const Text('Alarmas de Bioseñales Activas'),
              subtitle: const Text(
                'Dispara alertas visuales ante anomalías fisiológicas',
              ),
              value: estadoAlarma.habilitada,
              onChanged: (val) {
                notifierAlarma.cambiarHabilitacion(val);
              },
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const Divider(height: 32),

          // Switch para el sonido
          Material(
            type: MaterialType.transparency,
            child: SwitchListTile(
              title: const Text('Alertas Sonoras'),
              subtitle: const Text(
                'Emite un tono audible cuando se dispara una alarma crítica',
              ),
              value: estadoAlarma.sonidoHabilitado,
              onChanged: estadoAlarma.habilitada
                  ? (val) {
                      notifierAlarma.cambiarHabilitacionSonido(val);
                    }
                  : null,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const Gap(16),

          // Selector de Sonido y Botón de Probar
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Tono de Alarma',
                    labelStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: subtitleColor,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: borderColor),
                    ),
                  ),
                  initialValue: estadoAlarma.sonidoSeleccionado,
                  onChanged:
                      (estadoAlarma.habilitada && estadoAlarma.sonidoHabilitado)
                      ? (val) {
                          if (val != null) {
                            notifierAlarma.cambiarSonidoSeleccionado(val);
                          }
                        }
                      : null,
                  items: const [
                    DropdownMenuItem(
                      value: 'alarma_clasica',
                      child: Text('Pitido Clásico'),
                    ),
                    DropdownMenuItem(
                      value: 'alarma_urgente',
                      child: Text('Alerta Médica (Rápido)'),
                    ),
                    DropdownMenuItem(
                      value: 'alarma_suave',
                      child: Text('Sirena Suave'),
                    ),
                  ],
                ),
              ),
              const Gap(12),
              SizedBox(
                height: 48,
                child: FilledButton.icon(
                  onPressed:
                      (estadoAlarma.habilitada && estadoAlarma.sonidoHabilitado)
                      ? () {
                          ServicioAudio.instancia.probarSonido(
                            estadoAlarma.sonidoSeleccionado,
                          );
                        }
                      : null,
                  icon: const Icon(LucideIcons.play, size: 16),
                  label: const Text('Probar'),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
