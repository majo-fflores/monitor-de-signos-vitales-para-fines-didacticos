import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/vital_signs_provider.dart';

/// Widget de gráfico de ECG (AD8232) en tiempo real blando.
/// Implementación con fl_chart con cero delay de refresco para simulación de alta frecuencia.
class GraficoEcg extends StatelessWidget {
  final List<PuntoBiometrico> datos;

  const GraficoEcg({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    // Convertimos los PuntoBiometrico a FlSpot de fl_chart
    final spots = datos.map((d) => FlSpot(d.x, d.y)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabecera idéntica al original
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'AD8232 (Frecuencia Cardíaca - ECG)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: ColoresSensores.ecgVerde,
                ),
              ),
              Text(
                '100mm/s',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF717182),
                ),
              ),
            ],
          ),
        ),
        
        // Área del gráfico
        Container(
          height: 256,
          width: double.infinity,
          color: Colors.black,
          padding: const EdgeInsets.all(12),
          child: LineChart(
            LineChartData(
              minY: -30,
              maxY: 100,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                drawHorizontalLine: true,
                getDrawingHorizontalLine: (value) => const FlLine(
                  color: Color(0xFF222222),
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),
                getDrawingVerticalLine: (value) => const FlLine(
                  color: Color(0xFF222222),
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),
              ),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: ColoresSensores.ecgVerde,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
            duration: Duration.zero, // Renderizado a alta frecuencia inmediato
          ),
        ),
      ],
    );
  }
}
