import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/vital_signs_provider.dart';

/// Widget de gráfico de SpO2 Oximetría (MAX30100) en tiempo real.
/// Implementación con fl_chart que incluye gradiente vertical suave en el área inferior de la curva.
class GraficoSpo2 extends ConsumerWidget {
  final bool esCompacto;
  final bool expandir;
  const GraficoSpo2({super.key, this.esCompacto = false, this.expandir = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datos = ref.watch(notificadorSignosVitalesProvider.select((s) => s.spo2Datos));
    // Convertimos los PuntoBiometrico a FlSpot de fl_chart
    final spots = datos.map((d) => FlSpot(d.x, d.y)).toList();

    final theme = Theme.of(context);
    final esOscuro = theme.brightness == Brightness.dark;

    final colorFondoHeader = esOscuro ? Colors.black : const Color(0xFFF3F4F6);
    final colorFondoGrafico = esOscuro ? const Color(0xFF0F0F12) : Colors.white;
    final colorRejilla = esOscuro ? const Color(0xFF222222) : const Color(0xFFE5E7EB);
    final colorLinea = esOscuro ? ColoresSensores.spo2Azul : const Color(0xFF2563EB);

    final chartWidget = Container(
      width: double.infinity,
      color: colorFondoGrafico,
      padding: EdgeInsets.all(esCompacto ? 6 : 12),
      child: RepaintBoundary(
        child: LineChart(
          LineChartData(
            minY: 0,
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
                isCurved: true,
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
                      colorLinea.withValues(alpha: 0.3),
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
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabecera idéntica al original
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: esCompacto ? 6 : 10),
          decoration: BoxDecoration(
            color: colorFondoHeader,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            children: [
              Text(
                'MAX30100 (Saturación de Oxígeno - SpO2)',
                style: TextStyle(
                  fontSize: esCompacto ? 10 : 12,
                  fontWeight: FontWeight.bold,
                  color: colorLinea,
                ),
              ),
            ],
          ),
        ),
        
        // Área del gráfico
        expandir
            ? Expanded(child: chartWidget)
            : SizedBox(
                height: esCompacto ? 110 : 160,
                child: chartWidget,
              ),
      ],
    );
  }
}
