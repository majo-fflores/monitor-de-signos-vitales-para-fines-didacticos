import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/alarm_state.dart';
import '../../settings/widgets/biometric_thresholds_card.dart';
import '../widgets/alarm_history_card.dart';
import '../widgets/vital_indicator_widget.dart';

class AlertsView extends ConsumerWidget {
  const AlertsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleColor = isDark ? DarkColors.foreground : LightColors.foreground;
    final subtitleColor = isDark
        ? DarkColors.mutedForeground
        : LightColors.mutedForeground;
    final borderColor = isDark ? DarkColors.border : LightColors.border;

    // Solo observamos umbrales para pasarlos a la tarjeta (no el estado entero)
    ref.watch(alarmNotifierProvider.select((s) => s.thresholds));

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
            style: theme.textTheme.bodyMedium?.copyWith(color: subtitleColor),
          ),
          const Gap(24),

          // Layout adaptativo para Umbrales y KPI (Fila en desktop, columna en mobile)
          LayoutBuilder(
            builder: (context, constraints) {
              final esDesktop = constraints.maxWidth > 850;
              if (esDesktop) {
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 7,
                        child: BiometricThresholdsCard(
                          subtitleColor: subtitleColor,
                          borderColor: borderColor,
                          isDark: isDark,
                        ),
                      ),
                      const Gap(24),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            VitalIndicatorWidget(type: MetricType.heartRate),
                            VitalIndicatorWidget(type: MetricType.co2),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Column(
                  children: [
                    const VitalIndicatorWidget(type: MetricType.heartRate),
                    const Gap(16),
                    const VitalIndicatorWidget(type: MetricType.co2),
                    const Gap(24),
                    BiometricThresholdsCard(
                      subtitleColor: subtitleColor,
                      borderColor: borderColor,
                      isDark: isDark,
                    ),
                  ],
                );
              }
            },
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
