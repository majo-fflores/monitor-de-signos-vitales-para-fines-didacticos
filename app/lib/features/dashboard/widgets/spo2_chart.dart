import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/vital_signs_provider.dart';

/// Widget de gráfico de SpO2 Oximetría (MAX30100) en tiempo real.
/// Implementación con fl_chart que incluye gradiente vertical suave en el área inferior de la curva.
class GraficoSpo2 extends StatelessWidget {
  final List<PuntoBiometrico> datos;

  const GraficoSpo2({super.key, required this.datos});

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
          child: const Row(
            children: [
              Text(
                'MAX30100 (Saturación de Oxígeno - SpO2)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: ColoresSensores.spo2Azul,
                ),
              ),
            ],
          ),
        ),
        
        // Área del gráfico
        Container(
          height: 160,
          width: double.infinity,
          color: Colors.black,
          padding: const EdgeInsets.all(12),
          child: LineChart(
            LineChartData(
              minY: 0,
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
                  color: ColoresSensores.spo2Azul,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        ColoresSensores.spo2Azul.withValues(alpha: 0.4),
                        ColoresSensores.spo2Azul.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            duration: Duration.zero, // Cero latencia
          ),
        ),
      ],
    );
  }
}
