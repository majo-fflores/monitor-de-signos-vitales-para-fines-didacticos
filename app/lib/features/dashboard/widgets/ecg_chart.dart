import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/vital_signs_provider.dart';

/// Widget de gráfico de ECG (AD8232) en tiempo real blando.
/// Implementación con fl_chart con cero delay de refresco para simulación de alta frecuencia.
class GraficoEcg extends ConsumerWidget {
  final bool esCompacto;
  final bool expandir;
  const GraficoEcg({super.key, this.esCompacto = false, this.expandir = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datos = ref.watch(notificadorSignosVitalesProvider.select((s) => s.ecgDatos));
    final ecgActivo = ref.watch(notificadorSignosVitalesProvider.select((s) => s.ecgActivo));
    // Convertimos los PuntoBiometrico a FlSpot de fl_chart usando el índice como X para evitar cruces diagonales
    final spots = datos.asMap().entries.map((entry) => FlSpot(entry.key.toDouble(), entry.value.y)).toList();

    final theme = Theme.of(context);
    final esOscuro = theme.brightness == Brightness.dark;

    final colorFondoHeader = esOscuro ? Colors.black : const Color(0xFFF3F4F6);
    final colorFondoGrafico = esOscuro ? const Color(0xFF0F0F12) : Colors.white;
    final colorRejilla = esOscuro ? const Color(0xFF222222) : const Color(0xFFE5E7EB);
    final colorLinea = esOscuro ? ColoresSensores.ecgVerde : const Color(0xFF16A34A);

    final chartWidget = Container(
      width: double.infinity,
      color: colorFondoGrafico,
      padding: EdgeInsets.all(esCompacto ? 6 : 12),
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
                color: esOscuro ? Colors.black87.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.9),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'SENSOR DESCONECTADO',
                          style: TextStyle(
                            fontSize: esCompacto ? 10 : 12,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AD8232 (Frecuencia Cardíaca - ECG)',
                style: TextStyle(
                  fontSize: esCompacto ? 10 : 12,
                  fontWeight: FontWeight.bold,
                  color: colorLinea,
                ),
              ),
              if (!esCompacto)
                Text(
                  '100mm/s',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: esOscuro ? const Color(0xFF717182) : Colors.grey.shade600,
                  ),
                ),
            ],
          ),
        ),
        
        // Área del gráfico
        expandir
            ? Expanded(child: chartWidget)
            : SizedBox(
                height: esCompacto ? 110 : 256,
                child: chartWidget,
              ),
      ],
    );
  }
}
