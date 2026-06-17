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

_Co2ChartData _prepararDatosCo2(List<PuntoBiometrico> datos) {
  if (datos.isEmpty) {
    return const _Co2ChartData(
      spots: [],
      scale: _Co2Scale(minY: 900, maxY: 1300),
    );
  }

  final puntosValidos = datos
      .where((p) => p.y.isFinite)
      .toList(growable: false);

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
    final finalY = avgY;

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
class GraficoCo2 extends ConsumerWidget {
  final bool expandir;
  const GraficoCo2({super.key, this.expandir = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datos = ref.watch(
      notificadorSignosVitalesProvider.select((s) => s.co2Datos),
    );
    final co2Activo = ref.watch(
      notificadorSignosVitalesProvider.select((s) => s.co2Activo),
    );
    final chartData = _prepararDatosCo2(datos);

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
    final colorLinea = ColoresSensores.co2Amarillo;

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
                      aboveBarData: BarAreaData(
                        show: true,
                        color: colorLinea.withValues(
                          alpha: 0.4,
                        ), // Relleno hacia arriba
                      ),
                      belowBarData: BarAreaData(show: false),
                    ),
                ],
              ),
              duration: Duration.zero,
            ),
          ),
          if (!co2Activo)
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
                  'Dióxido de Carbono (CO2)',
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
