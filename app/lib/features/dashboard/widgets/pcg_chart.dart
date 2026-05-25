import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/vital_signs_provider.dart';

class GraficoPcg extends ConsumerWidget {
  const GraficoPcg({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datos = ref.watch(notificadorSignosVitalesProvider.select((s) => s.pcgDatos));
    final theme = Theme.of(context);
    final esOscuro = theme.brightness == Brightness.dark;

    final colorFondo = esOscuro ? Colors.black : Colors.white;
    final colorLinea = Colors.cyanAccent.shade400;
    final colorTexto = esOscuro ? ColoresOscuros.mutedForeground : ColoresClaros.mutedForeground;
    final colorRejilla = esOscuro 
        ? Colors.white.withValues(alpha: 0.05) 
        : Colors.black.withValues(alpha: 0.05);

    // Mapeamos los datos simulados a FlSpot para fl_chart
    final spots = datos.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.y);
    }).toList();

    return Container(
      height: 140,
      padding: const EdgeInsets.only(top: 16, bottom: 8, right: 16, left: 16),
      color: colorFondo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'LM386 (Auscultación PCG)',
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorTexto,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colorLinea.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'PCG',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorLinea,
                    fontWeight: FontWeight.bold,
                    fontSize: 8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: RepaintBoundary(
              child: LineChart(
                LineChartData(
                  minY: -80,
                  maxY: 80,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 40,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: colorRejilla,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots.isEmpty ? [const FlSpot(0, 0)] : spots,
                      isCurved: true,
                      color: colorLinea,
                      barWidth: 1.5,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: colorLinea.withValues(alpha: 0.05),
                      ),
                    ),
                  ],
                ),
                duration: Duration.zero, // Cero retardo para rendering fluido
              ),
            ),
          ),
        ],
      ),
    );
  }
}
