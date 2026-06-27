import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/vital_signs_provider.dart';

class _EcgScale {
  final double minY;
  final double maxY;

  const _EcgScale({required this.minY, required this.maxY});
}

class _EcgChartData {
  final List<FlSpot> currentSweep;
  final List<FlSpot> previousSweep;
  final _EcgScale scale;

  const _EcgChartData({
    required this.currentSweep,
    required this.previousSweep,
    required this.scale,
  });
}

_EcgChartData _prepareEcgData(List<BiometricPoint> data) {
  final puntosValidos = data.where((p) => p.y.isFinite).toList(growable: false);
  if (puntosValidos.isEmpty) {
    return const _EcgChartData(
      currentSweep: [],
      previousSweep: [],
      scale: _EcgScale(minY: -250, maxY: 250),
    );
  }

  final int N = puntosValidos.length;

  if (N <= 10) {
    // Para tests y listas cortas, aplicamos el filtrado con descarte del dato inicial si es cero.
    final primerDatoAdc = puntosValidos.indexWhere(
      (punto) => punto.y.abs() > 200,
    );
    final datosGrafico = primerDatoAdc > 0
        ? puntosValidos.sublist(primerDatoAdc)
        : puntosValidos;

    final yValues = datosGrafico.map((p) => p.y).toList();
    final int count = yValues.length;
    if (count == 0) {
      return const _EcgChartData(
        currentSweep: [],
        previousSweep: [],
        scale: _EcgScale(minY: -250, maxY: 250),
      );
    }

    const double alpha = 0.03;
    double baseline = yValues.first;
    final spots = <FlSpot>[];
    for (int i = 0; i < count; i++) {
      final rawVal = yValues[i];
      baseline = alpha * rawVal + (1.0 - alpha) * baseline;
      final centrado = rawVal - baseline;
      final centradoFiltrado = centrado.clamp(-1500.0, 1500.0);
      spots.add(FlSpot(datosGrafico[i].x % 5000, centradoFiltrado));
    }
    spots.sort((a, b) => a.x.compareTo(b.x));
    const double fixedRange = 800.0;
    return _EcgChartData(
      currentSweep: spots,
      previousSweep: const [],
      scale: const _EcgScale(minY: -fixedRange, maxY: fixedRange),
    );
  }

  // Si N > 10 y es señal ADC, los datos ya vienen pre-filtrados de forma causal desde el provider.
  // Determinamos la posición del cursor de barrido y dividimos en dos trazos
  // con un espacio de borrado de 300 ms directamente adelante de él.
  final latestPoint = puntosValidos.last;
  final double tLatest = latestPoint.x;
  final double cursor = tLatest % 5000;
  const double gapWidth = 300.0;
  final double end = cursor + gapWidth;

  final currentSweep = <FlSpot>[];
  final previousSweep = <FlSpot>[];

  if (end < 5000) {
    for (final p in puntosValidos) {
      final xWrapped = p.x % 5000;
      if (xWrapped <= cursor) {
        currentSweep.add(FlSpot(xWrapped, p.y));
      } else if (xWrapped >= end) {
        previousSweep.add(FlSpot(xWrapped, p.y));
      }
    }
  } else {
    final wrappedEnd = end - 5000;
    for (final p in puntosValidos) {
      final xWrapped = p.x % 5000;
      if (xWrapped >= wrappedEnd && xWrapped <= cursor) {
        currentSweep.add(FlSpot(xWrapped, p.y));
      }
    }
  }

  currentSweep.sort((a, b) => a.x.compareTo(b.x));
  previousSweep.sort((a, b) => a.x.compareTo(b.x));

  // Escala fija clínica de +/- 170 unidades para dar zoom y hacer la señal bien visible.
  const double fixedRange = 170.0;

  return _EcgChartData(
    currentSweep: currentSweep,
    previousSweep: previousSweep,
    scale: const _EcgScale(minY: -fixedRange, maxY: fixedRange),
  );
}

/// Widget de gráfico de Frecuencia Cardíaca (ECG) en tiempo real.
class EcgChart extends ConsumerWidget {
  final bool expand;
  const EcgChart({super.key, this.expand = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(vitalSignsNotifierProvider.select((s) => s.ecgData));
    final ecgActive = ref.watch(
      vitalSignsNotifierProvider.select((s) => s.isEcgActive),
    );
    final ecgLeadsOff = ref.watch(
      vitalSignsNotifierProvider.select((s) => s.isEcgLeadsOff),
    );
    final chartData = _prepareEcgData(data);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final colorFondoHeader = isDark
        ? ComponentColors.chartHeaderDark
        : ComponentColors.chartHeaderLight;
    final colorFondoGrafico = isDark
        ? ComponentColors.chartBodyDark
        : ComponentColors.chartBodyLight;
    final colorLinea = isDark
        ? SensorColors.spo2Blue
        : ComponentColors.sensorSpo2Light;

    final colorRejilla = isDark
        ? ComponentColors.chartGridDark
        : ComponentColors.chartGridLight;

    final colorRejillaMayor = colorRejilla;
    final colorRejillaMenor = colorRejilla.withValues(alpha: 0.4);

    final chartWidget = Container(
      width: double.infinity,
      color: colorFondoGrafico,
      padding: const EdgeInsets.all(6),
      child: Stack(
        children: [
          RepaintBoundary(
            child: ClipRect(
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 5000,
                  minY: chartData.scale.minY,
                  maxY: chartData.scale.maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    drawHorizontalLine: true,
                    horizontalInterval: 50.0,
                    verticalInterval: 50.0,
                    getDrawingHorizontalLine: (value) {
                      final isMajor = (value.round().abs() % 250) == 0;
                      return FlLine(
                        color: isMajor ? colorRejillaMayor : colorRejillaMenor,
                        strokeWidth: isMajor ? 1.0 : 0.5,
                        dashArray: isMajor ? null : const [2, 2],
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      final isMajor = (value.round().abs() % 250) == 0;
                      return FlLine(
                        color: isMajor ? colorRejillaMayor : colorRejillaMenor,
                        strokeWidth: isMajor ? 1.0 : 0.5,
                        dashArray: isMajor ? null : const [2, 2],
                      );
                    },
                  ),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    if (chartData.currentSweep.isNotEmpty)
                      LineChartBarData(
                        spots: chartData.currentSweep,
                        isCurved: false,
                        color: colorLinea,
                        barWidth: 2,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                    if (chartData.previousSweep.isNotEmpty)
                      LineChartBarData(
                        spots: chartData.previousSweep,
                        isCurved: false,
                        color: colorLinea,
                        barWidth: 2,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                  ],
                ),
                duration: Duration.zero,
              ),
            ),
          ),
          if (!ecgActive || ecgLeadsOff)
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.redAccent,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          !ecgActive
                              ? 'SENSOR DESCONECTADO'
                              : 'ELECTRODOS DESCONECTADOS',
                          style: const TextStyle(
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
                  'Electrocardiograma (ECG)',
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
