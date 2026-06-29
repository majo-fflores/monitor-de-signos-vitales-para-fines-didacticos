import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/alarm_state.dart';
import '../../../shared/providers/vital_signs_provider.dart';

/// Tipos de métrica soportados por el indicador.
enum MetricType { heartRate, co2 }

/// Widget aislado para una sola métrica vital.
/// Cada instancia hace su propio `ref.watch` selectivo para evitar
/// rebuilds innecesarios cuando cambia otra métrica.
class VitalIndicatorWidget extends ConsumerWidget {
  final MetricType type;

  const VitalIndicatorWidget({super.key, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final thresholds = ref.watch(
      alarmNotifierProvider.select((s) => s.thresholds),
    );

    // Cada tipo solo observa su propio dato
    late final int value;
    late final bool isActive;
    late final String metricName;
    late final String formattedValue;
    late final IconData icon;
    late final Color baseColor;
    late final bool isOutOfRange;

    switch (type) {
      case MetricType.heartRate:
        value = ref.watch(
          vitalSignsNotifierProvider.select((s) => s.heartRate),
        );
        isActive = ref.watch(
          vitalSignsNotifierProvider.select((s) => s.isEcgActive),
        );
        metricName = 'Frecuencia Cardíaca';
        formattedValue = value == 0 ? '-' : '$value BPM';
        icon = LucideIcons.heart;
        baseColor = SensorColors.ecgGreen;
        isOutOfRange =
            (value != 0 &&
                (value < thresholds.bpmMin || value > thresholds.bpmMax)) &&
            isActive;
      case MetricType.co2:
        value = ref.watch(vitalSignsNotifierProvider.select((s) => s.co2Level));
        isActive = ref.watch(
          vitalSignsNotifierProvider.select((s) => s.isCo2Active),
        );
        metricName = 'Dióxido de Carbono';
        formattedValue = value == 0 ? '-' : '$value ppm';
        icon = LucideIcons.wind;
        baseColor = SensorColors.co2Yellow;
        isOutOfRange = (value != 0 && (value > thresholds.co2Max)) && isActive;
    }

    final color = isOutOfRange ? theme.colorScheme.error : baseColor;

    final isDark = theme.brightness == Brightness.dark;

    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOutOfRange
                ? theme.colorScheme.error.withValues(alpha: 0.5)
                : (isDark ? DarkColors.border : LightColors.border),
            width: isOutOfRange ? 1.5 : 1.0,
          ),
          boxShadow: isOutOfRange
              ? [
                  BoxShadow(
                    color: theme.colorScheme.error.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Gap(12),
                Text(
                  metricName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const Gap(12),
            Container(
              height: 1,
              color: isDark ? DarkColors.border : LightColors.border,
            ),
            const Gap(12),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          formattedValue,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: color,
                            fontFeatures: const [FontFeature.tabularFigures()],
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                  ),
                  VerticalDivider(
                    width: 24,
                    thickness: 1,
                    color: isDark ? DarkColors.border : LightColors.border,
                  ),
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          !isActive
                              ? 'DESCONECTADO'
                              : (isOutOfRange ? 'CRÍTICO' : 'NORMAL'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: !isActive
                                ? Colors.grey
                                : (isOutOfRange
                                    ? theme.colorScheme.error
                                    : SensorColors.statusConnected),
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
