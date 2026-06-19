import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../core/models/measurement_record.dart';
import 'kpi_chip.dart';

class HistoryStatisticsSummary extends StatelessWidget {
  final List<MeasurementRecord> records;
  final ThemeData theme;
  final bool isDark;

  const HistoryStatisticsSummary({
    super.key,
    required this.records,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final total = records.length;
    double avgHeartRate = 0;
    double avgCo2 = 0;

    if (total > 0) {
      double sFC = 0;
      double sCO2 = 0;
      for (final r in records) {
        sFC += r.heartRate;
        sCO2 += r.co2Level;
      }
      avgHeartRate = sFC / total;
      avgCo2 = sCO2 / total;
    }

    final chips = [
      _KpiData(
        title: 'Sesiones',
        value: '$total',
        icon: LucideIcons.checkSquare,
        color: const Color(0xFF8B5CF6),
      ),
      _KpiData(
        title: 'Prom. FC',
        value: '${avgHeartRate.round()} LPM',
        icon: LucideIcons.heart,
        color: const Color(0xFF10B981),
      ),
      _KpiData(
        title: 'Prom. CO2',
        value: '${avgCo2.round()} ppm',
        icon: LucideIcons.cloud,
        color: const Color(0xFFF59E0B),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final esMobile = constraints.maxWidth < Breakpoints.tablet;

        if (esMobile) {
          // Mobile: grilla 2x2
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: chips.map((c) {
              return SizedBox(
                width: (constraints.maxWidth - 12) / 2,
                child: KpiChip(
                  title: c.title,
                  value: c.value,
                  icon: c.icon,
                  color: c.color,
                  theme: theme,
                  isDark: isDark,
                  expanded: true,
                ),
              );
            }).toList(),
          );
        }

        // Desktop/Tablet: fila que ocupa todo el ancho
        return Row(
          children: [
            for (int i = 0; i < chips.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(
                child: KpiChip(
                  title: chips[i].title,
                  value: chips[i].value,
                  icon: chips[i].icon,
                  color: chips[i].color,
                  theme: theme,
                  isDark: isDark,
                  expanded: true,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _KpiData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}
