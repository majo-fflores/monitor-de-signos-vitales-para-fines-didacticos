import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/vital_signs_provider.dart';

/// Widget de gráfico de Frecuencia Cardíaca (ECG) en tiempo real.
class GraficoEcg extends ConsumerWidget {
  final bool expandir;
  const GraficoEcg({super.key, this.expandir = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datos = ref.watch(
      notificadorSignosVitalesProvider.select((s) => s.ecgDatos),
    );
    final ecgActivo = ref.watch(
      notificadorSignosVitalesProvider.select((s) => s.ecgActivo),
    );
    // Convertimos los PuntoBiometrico a FlSpot de fl_chart usando el índice como X para evitar cruces diagonales
    final spots = datos
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.y))
        .toList();

    final theme = Theme.of(context);
    final esOscuro = theme.brightness == Brightness.dark;

    final colorFondoHeader = esOscuro
        ? ColoresComponentes.graficoHeaderOscuro
        : ColoresComponentes.graficoHeaderClaro;
    final colorFondoGrafico = esOscuro
        ? ColoresComponentes.graficoCuerpoOscuro
        : ColoresComponentes.graficoCuerpoClaro;
    final colorRejilla = esOscuro
        ? ColoresComponentes.graficoRejillaOscuro
        : ColoresComponentes.graficoRejillaClaro;
    final colorLinea = esOscuro
        ? ColoresSensores.ecgVerde
        : ColoresComponentes.sensorEcgClaro;

    final chartWidget = Container(
      width: double.infinity,
      color: colorFondoGrafico,
      padding: const EdgeInsets.all(6),
      child: Stack(
        children: [
          RepaintBoundary(
            child: LineChart(
              LineChartData(
                minY: -30,
                maxY: 100,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  drawHorizontalLine: true,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: colorRejilla,
                    strokeWidth: 1,
                    dashArray: const [4, 4],
                  ),
                  getDrawingVerticalLine: (value) => FlLine(
                    color: colorRejilla,
                    strokeWidth: 1,
                    dashArray: const [4, 4],
                  ),
                ),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: false,
                    color: colorLinea,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colorLinea.withValues(alpha: 0.35),
                          colorLinea.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              duration: Duration.zero,
            ),
          ),
          if (!ecgActivo)
            Positioned.fill(
              child: Container(
                color: esOscuro
                    ? Colors.black87.withValues(alpha: 0.8)
                    : Colors.white.withValues(alpha: 0.9),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.redAccent.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.redAccent,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'SENSOR DESCONECTADO',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: colorFondoHeader,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Frecuencia Cardíaca (ECG)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: colorLinea,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Área del gráfico
        expandir
            ? Expanded(child: chartWidget)
            : SizedBox(height: 110, child: chartWidget),
      ],
    );
  }
}
