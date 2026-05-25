import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/alarma_state.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Obtenemos el estado de la alarma y los umbrales
    final estadoAlarma = ref.watch(notificadorAlarmaProvider);
    final umbrales = estadoAlarma.umbrales;

    final titleColor = isDark ? ColoresOscuros.foreground : ColoresClaros.foreground;
    final subtitleColor = isDark ? ColoresOscuros.mutedForeground : ColoresClaros.mutedForeground;
    final borderColor = isDark ? ColoresOscuros.border : ColoresClaros.border;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configuración de Sistema',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: titleColor,
            ),
          ),
          const Gap(4),
          Text(
            'Ajustes de umbrales médicos, configuración de puertos y calibración de sensores.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: subtitleColor,
            ),
          ),
          const Gap(24),

          // TARJETA DE UMBRALES BIOMÉTRICOS
          Container(
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
                      Icons.ring_volume,
                      color: isDark ? Colors.redAccent : Colors.red,
                    ),
                    const Gap(10),
                    Text(
                      'Umbrales de Alerta Crítica',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                Text(
                  'Configura los límites fuera de los cuales se activará el ciclo de alarma de 30 segundos.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: subtitleColor,
                  ),
                ),
                const Gap(24),

                // 1. FRECUENCIA CARDÍACA (BPM)
                _buildSliderRango(
                  context: context,
                  titulo: 'Frecuencia Cardíaca',
                  unidad: 'BPM',
                  icono: Icons.favorite,
                  colorAcento: ColoresSensores.ecgVerde,
                  min: 40.0,
                  max: 180.0,
                  rangoActual: RangeValues(umbrales.fcMin.toDouble(), umbrales.fcMax.toDouble()),
                  onChanged: (values) {
                    ref.read(notificadorAlarmaProvider.notifier).actualizarUmbrales(
                      fcMin: values.start.round(),
                      fcMax: values.end.round(),
                    );
                  },
                ),
                const Divider(height: 32, thickness: 1),

                // 2. SATURACIÓN DE OXÍGENO (SpO2)
                _buildSliderUnico(
                  context: context,
                  titulo: 'Saturación de Oxígeno (Mínimo)',
                  unidad: '%',
                  icono: Icons.opacity,
                  colorAcento: ColoresSensores.spo2Azul,
                  min: 80.0,
                  max: 100.0,
                  valorActual: umbrales.spo2Min.toDouble(),
                  onChanged: (value) {
                    ref.read(notificadorAlarmaProvider.notifier).actualizarUmbrales(
                      spo2Min: value.round(),
                    );
                  },
                ),
                const Divider(height: 32, thickness: 1),

                // 3. DIÓXIDO DE CARBONO (CO2)
                _buildSliderUnico(
                  context: context,
                  titulo: 'Dióxido de Carbono (Máximo)',
                  unidad: 'ppm',
                  icono: Icons.cloud,
                  colorAcento: ColoresSensores.co2Amarillo,
                  min: 300.0,
                  max: 1200.0,
                  valorActual: umbrales.co2Max.toDouble(),
                  onChanged: (value) {
                    ref.read(notificadorAlarmaProvider.notifier).actualizarUmbrales(
                      co2Max: value.round(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRango({
    required BuildContext context,
    required String titulo,
    required String unidad,
    required IconData icono,
    required Color colorAcento,
    required double min,
    required double max,
    required RangeValues rangoActual,
    required ValueChanged<RangeValues> onChanged,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(icono, color: colorAcento, size: 20),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      titulo,
                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(16),
            Text(
              '${rangoActual.start.round()} - ${rangoActual.end.round()} $unidad',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorAcento,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const Gap(8),
        RangeSlider(
          values: rangoActual,
          min: min,
          max: max,
          activeColor: colorAcento,
          inactiveColor: colorAcento.withValues(alpha: 0.2),
          labels: RangeLabels('${rangoActual.start.round()}', '${rangoActual.end.round()}'),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSliderUnico({
    required BuildContext context,
    required String titulo,
    required String unidad,
    required IconData icono,
    required Color colorAcento,
    required double min,
    required double max,
    required double valorActual,
    required ValueChanged<double> onChanged,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(icono, color: colorAcento, size: 20),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      titulo,
                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(16),
            Text(
              '${valorActual.round()} $unidad',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorAcento,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const Gap(8),
        Slider(
          value: valorActual,
          min: min,
          max: max,
          activeColor: colorAcento,
          inactiveColor: colorAcento.withValues(alpha: 0.2),
          label: '${valorActual.round()}',
          onChanged: onChanged,
        ),
      ],
    );
  }
}
