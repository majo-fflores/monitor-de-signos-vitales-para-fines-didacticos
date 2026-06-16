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
  final List<FlSpot> spots;
  final _EcgScale scale;

  const _EcgChartData({required this.spots, required this.scale});
}

double _mediana(List<double> valores) {
  final ordenados = List<double>.of(valores)..sort();
  final medio = ordenados.length ~/ 2;
  if (ordenados.length.isOdd) return ordenados[medio];
  return (ordenados[medio - 1] + ordenados[medio]) / 2;
}

_EcgScale _calcularEscalaNormalizada(List<FlSpot> spots) {
  const escalaNormalizada = _EcgScale(minY: -30, maxY: 100);
  if (spots.isEmpty) return escalaNormalizada;

  final valores = spots
      .map((spot) => spot.y)
      .where((value) => value.isFinite)
      .toList(growable: false);
  if (valores.isEmpty) return escalaNormalizada;

  var minVal = valores.first;
  var maxVal = valores.first;
  for (final value in valores.skip(1)) {
    if (value < minVal) minVal = value;
    if (value > maxVal) maxVal = value;
  }

  final minY = minVal < escalaNormalizada.minY
      ? minVal - 8
      : escalaNormalizada.minY;
  final maxY = maxVal > escalaNormalizada.maxY
      ? maxVal + 8
      : escalaNormalizada.maxY;

  return _EcgScale(minY: minY, maxY: maxY);
}

_EcgChartData _prepararDatosEcg(List<PuntoBiometrico> datos) {
  final primerDatoAdc = datos.indexWhere((punto) => punto.y.abs() > 200);
  final ecgCrudoAdc = primerDatoAdc >= 0;
  final datosGrafico = ecgCrudoAdc && primerDatoAdc > 0
      ? datos.sublist(primerDatoAdc)
      : datos;

  if (!ecgCrudoAdc) {
    final spots = datosGrafico
        .map((punto) => FlSpot(punto.x % 5000, punto.y))
        .toList();
    spots.sort((a, b) => a.x.compareTo(b.x));

    return _EcgChartData(
      spots: spots,
      scale: _calcularEscalaNormalizada(spots),
    );
  }

  final puntosValidos = datosGrafico
      .where((p) => p.y.isFinite)
      .toList(growable: false);
  if (puntosValidos.isEmpty) {
    return const _EcgChartData(
      spots: [],
      scale: _EcgScale(minY: -250, maxY: 250),
    );
  }

  final lineaBase = _mediana(
    puntosValidos.map((p) => p.y).toList(growable: false),
  );
  final spots = <FlSpot>[];
  var maxAbs = 0.0;

  for (final punto in puntosValidos) {
    final centrado = punto.y - lineaBase;
    if (centrado.abs() > maxAbs) maxAbs = centrado.abs();
    spots.add(FlSpot(punto.x % 5000, centrado));
  }

  final halfRange = (maxAbs * 1.15).clamp(250.0, 1800.0).toDouble();
  spots.sort((a, b) => a.x.compareTo(b.x));

  return _EcgChartData(
    spots: spots,
    scale: _EcgScale(minY: -halfRange, maxY: halfRange),
  );
}

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
    final chartData = _prepararDatosEcg(datos);

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
                minX: 0,
                maxX: 5000,
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
                  LineChartBarData(
                    spots: chartData.spots,
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
