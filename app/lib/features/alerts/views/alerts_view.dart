import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/alarma_state.dart';
import '../../settings/widgets/biometric_thresholds_card.dart';
import '../widgets/alarm_history_card.dart';
import '../widgets/indicador_vital_widget.dart';

class AlertsView extends ConsumerWidget {
  const AlertsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleColor = isDark ? ColoresOscuros.foreground : ColoresClaros.foreground;
    final subtitleColor = isDark ? ColoresOscuros.mutedForeground : ColoresClaros.mutedForeground;
    final borderColor = isDark ? ColoresOscuros.border : ColoresClaros.border;

    // Solo observamos umbrales para pasarlos a la tarjeta (no el estado entero)
    ref.watch(notificadorAlarmaProvider.select((s) => s.umbrales));

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alertas de Monitoreo',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: titleColor,
            ),
          ),
          const Gap(4),
          Text(
            'Visualización de estado fisiológico crítico y configuración de umbrales médicos.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: subtitleColor,
            ),
          ),
          const Gap(24),



          // Indicadores adaptativos (Fila en desktop, columna en mobile)
          LayoutBuilder(
            builder: (context, constraints) {
              final esDesktop = constraints.maxWidth > 850;
              if (esDesktop) {
                return const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: IndicadorVitalWidget(tipo: TipoMetrica.frecuenciaCardiaca)),
                    Gap(16),
                    Expanded(child: IndicadorVitalWidget(tipo: TipoMetrica.saturacionOxigeno)),
                    Gap(16),
                    Expanded(child: IndicadorVitalWidget(tipo: TipoMetrica.dioxidoCarbono)),
                  ],
                );
              } else {
                return const Column(
                  children: [
                    IndicadorVitalWidget(tipo: TipoMetrica.frecuenciaCardiaca),
                    Gap(12),
                    IndicadorVitalWidget(tipo: TipoMetrica.saturacionOxigeno),
                    Gap(12),
                    IndicadorVitalWidget(tipo: TipoMetrica.dioxidoCarbono),
                  ],
                );
              }
            },
          ),

          const Gap(32),
          const Divider(height: 1, thickness: 1),
          const Gap(32),

          // Tarjeta de Umbrales reubicada aquí
          BiometricThresholdsCard(
            subtitleColor: subtitleColor,
            borderColor: borderColor,
            isDark: isDark,
          ),
          const Gap(32),
          const Divider(height: 1, thickness: 1),
          const Gap(32),

          // Historial de Alertas Críticas
          AlarmHistoryCard(
            subtitleColor: subtitleColor,
            borderColor: borderColor,
          ),
          const Gap(40),
        ],
      ),
    );
  }
}
