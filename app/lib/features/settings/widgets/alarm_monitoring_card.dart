import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
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
              Icon(
                Icons.security,
                color: theme.colorScheme.primary,
              ),
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
            'Habilite o deshabilite el sistema de alarmas de bioseñales de forma global.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: subtitleColor,
            ),
          ),
          const Gap(16),
          // Envoltura con Material transparente para evitar la excepción de DecoratedBox de Flutter
          Material(
            type: MaterialType.transparency,
            child: SwitchListTile(
              title: const Text('Alarmas de Bioseñales Activas'),
              subtitle: const Text('Dispara alertas visuales ante anomalías fisiológicas'),
              value: ref.watch(notificadorAlarmaProvider.select((s) => s.habilitada)),
              onChanged: (val) {
                ref.read(notificadorAlarmaProvider.notifier).cambiarHabilitacion(val);
              },
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
