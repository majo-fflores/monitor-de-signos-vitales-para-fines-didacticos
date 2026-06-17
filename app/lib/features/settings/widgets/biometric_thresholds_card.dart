import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/alarma_state.dart';
import 'threshold_range_slider.dart';
import 'threshold_single_slider.dart';

class BiometricThresholdsCard extends ConsumerWidget {
  final Color subtitleColor;
  final Color borderColor;
  final bool isDark;

  const BiometricThresholdsCard({
    super.key,
    required this.subtitleColor,
    required this.borderColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final umbrales = ref.watch(
      notificadorAlarmaProvider.select((s) => s.umbrales),
    );

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
          Text(
            'Umbrales de Alerta Crítica',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(8),
          Text(
            'Configura los límites fuera de los cuales se activará el ciclo de alarma de 30 segundos.',
            style: theme.textTheme.bodySmall?.copyWith(color: subtitleColor),
          ),
          const Gap(24),

          // 1. FRECUENCIA CARDÍACA (BPM)
          const ThresholdRangeSlider(
            titulo: 'Frecuencia Cardíaca',
            unidad: 'BPM',
            icono: Icons.favorite,
            colorAcento: ColoresSensores.ecgVerde,
            min: 40.0,
            max: 180.0,
          ),
          const Gap(16),
          // 2. DIÓXIDO DE CARBONO (ppm)
          ThresholdSingleSlider(
            titulo: 'Dióxido de Carbono',
            unidad: 'ppm',
            icono: Icons.air,
            colorAcento: ColoresSensores.co2Amarillo,
            min: 0.0,
            max: 2000.0,
            valorInicial: umbrales.co2Max.toDouble(),
            onChanged: (val) {
              ref
                  .read(notificadorAlarmaProvider.notifier)
                  .actualizarUmbralesMemoria(co2Max: val.round());
            },
            onChangeEnd: (_) {
              ref
                  .read(notificadorAlarmaProvider.notifier)
                  .guardarUmbralesEnDisco();
            },
          ),
        ],
      ),
    );
  }
}
