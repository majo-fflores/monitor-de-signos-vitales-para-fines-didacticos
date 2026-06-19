import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/vital_signs_provider.dart';

class _Co2Scale {
  final double minY;
  final double maxY;

  const _Co2Scale({required this.minY, required this.maxY});
}

class _Co2ChartData {
  final List<FlSpot> spots;
  final _Co2Scale scale;

  const _Co2ChartData({required this.spots, required this.scale});
}

_Co2ChartData _prepareCo2Data(List<BiometricPoint> data) {
  if (data.isEmpty) {
    return const _Co2ChartData(
      spots: [],
      scale: _Co2Scale(minY: 900, maxY: 1300),
    );
  }

  final puntosValidos = data.where((p) => p.y.isFinite).toList(growable: false);

  if (puntosValidos.isEmpty) {
    return const _Co2ChartData(
      spots: [],
      scale: _Co2Scale(minY: 900, maxY: 1300),
    );
  }

  final spots = <FlSpot>[];
  var minVal = double.infinity;
  var maxVal = double.negativeInfinity;

  const int windowSize = 40; // Suavizado de 40 puntos (400ms de datos)

  for (int i = 0; i < puntosValidos.length; i++) {
    double sum = 0;
    int count = 0;

    // Promedio Móvil Simple (Simple Moving Average)
    int startIdx = i - windowSize + 1;
    if (startIdx < 0) startIdx = 0;

    for (int j = startIdx; j <= i; j++) {
      sum += puntosValidos[j].y;
      count++;
    }
    double avgY = sum / count;

    // El valor directo: 1200 es la base, y al soplar baja a ~950.
    // Lo invertimos para que el pico vaya hacia arriba (1250.0 - avgY)
    final finalY = 1250.0 - avgY;

    double pointTime = puntosValidos[i].x;
    double xMod = pointTime % 15000;

    if (finalY < minVal) minVal = finalY;
    if (finalY > maxVal) maxVal = finalY;

    spots.add(FlSpot(xMod, finalY));
  }

  // Añadir un margen al gráfico
  final minY = (minVal - 20).clamp(0.0, 5000.0);
  final maxY = (maxVal + 50).clamp(0.0, 5000.0);

  return _Co2ChartData(
    spots: spots,
    scale: _Co2Scale(minY: minY, maxY: maxY),
  );
}

/// Widget de gráfico de Dióxido de Carbono (CO2) en tiempo real.
class Co2Chart extends ConsumerWidget {
  final bool expand;
  const Co2Chart({super.key, this.expand = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(vitalSignsNotifierProvider.select((s) => s.co2Data));
    final co2Active = ref.watch(
      vitalSignsNotifierProvider.select((s) => s.isCo2Active),
    );
    final chartData = _prepareCo2Data(data);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final colorFondoHeader = isDark
        ? ComponentColors.chartHeaderDark
        : ComponentColors.chartHeaderLight;
    final colorFondoGrafico = isDark
        ? ComponentColors.chartBodyDark
        : ComponentColors.chartBodyLight;
    final colorRejilla = isDark
        ? ComponentColors.chartGridDark
        : ComponentColors.chartGridLight;
    final colorLinea = SensorColors.co2Yellow;

    final chartWidget = Container(
      width: double.infinity,
      color: colorFondoGrafico,
      padding: const EdgeInsets.all(6),
      child: Stack(
        children: [
          RepaintBoundary(
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 15000,
                minY: chartData.scale.minY,
                maxY: chartData.scale.maxY,
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
                  if (chartData.spots.isNotEmpty)
                    LineChartBarData(
                      spots: chartData.spots,
                      isCurved: true, // Línea suave y redondeada
                      color: colorLinea,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      aboveBarData: BarAreaData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: colorLinea.withValues(
                          alpha: 0.4,
                        ), // Relleno hacia abajo
                      ),
                    ),
                ],
              ),
              duration: Duration.zero,
            ),
          ),
          if (!co2Active)
            Positioned.fill(
              child: Container(
                color: isDark
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
                  'Respiración del Paciente (CO2)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: colorLinea,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Área del gráfico
        expand
            ? Expanded(child: chartWidget)
            : SizedBox(height: 110, child: chartWidget),
      ],
    );
  }
}
