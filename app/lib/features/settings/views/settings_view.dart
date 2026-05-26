import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/alarma_state.dart';
import '../widgets/threshold_range_slider.dart';
import '../widgets/threshold_single_slider.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Obtenemos los umbrales actuales (usando select para evitar rebuilds si cambian otros campos del estado)
    final umbrales = ref.watch(notificadorAlarmaProvider.select((s) => s.umbrales));

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
          // TARJETA DE ACTIVACIÓN DE ALARMA
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
                SwitchListTile(
                  title: const Text('Alarmas de Bioseñales Activas'),
                  subtitle: const Text('Dispara alertas visuales ante anomalías fisiológicas'),
                  value: ref.watch(notificadorAlarmaProvider.select((s) => s.habilitada)),
                  onChanged: (val) {
                    ref.read(notificadorAlarmaProvider.notifier).cambiarHabilitacion(val);
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ],
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
                const ThresholdRangeSlider(
                  titulo: 'Frecuencia Cardíaca',
                  unidad: 'BPM',
                  icono: Icons.favorite,
                  colorAcento: ColoresSensores.ecgVerde,
                  min: 40.0,
                  max: 180.0,
                ),
                const Divider(height: 32, thickness: 1),

                // 2. SATURACIÓN DE OXÍGENO (SpO2)
                ThresholdSingleSlider(
                  titulo: 'Saturación de Oxígeno (Mínimo)',
                  unidad: '%',
                  icono: Icons.opacity,
                  colorAcento: ColoresSensores.spo2Azul,
                  min: 80.0,
                  max: 100.0,
                  valorInicial: umbrales.spo2Min.toDouble(),
                  onChanged: (value) {
                    ref.read(notificadorAlarmaProvider.notifier).actualizarUmbralesMemoria(
                      spo2Min: value.round(),
                    );
                  },
                  onChangeEnd: (_) {
                    ref.read(notificadorAlarmaProvider.notifier).guardarUmbralesEnDisco();
                  },
                ),
                const Divider(height: 32, thickness: 1),

                // 3. DIÓXIDO DE CARBONO (CO2)
                ThresholdSingleSlider(
                  titulo: 'Dióxido de Carbono (Máximo)',
                  unidad: 'ppm',
                  icono: Icons.cloud,
                  colorAcento: ColoresSensores.co2Amarillo,
                  min: 300.0,
                  max: 1200.0,
                  valorInicial: umbrales.co2Max.toDouble(),
                  onChanged: (value) {
                    ref.read(notificadorAlarmaProvider.notifier).actualizarUmbralesMemoria(
                      co2Max: value.round(),
                    );
                  },
                  onChangeEnd: (_) {
                    ref.read(notificadorAlarmaProvider.notifier).guardarUmbralesEnDisco();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
