import 'package:flutter/material.dart';

import '../../../../core/constants/breakpoints.dart';
import 'co2_chart.dart';
import 'ecg_chart.dart';
import 'spo2_chart.dart';

class WaveCharts extends StatelessWidget {
  static const bool mostrarMax30100 = false;

  const WaveCharts({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final esAncho =
            constraints.maxWidth >= 1050.0; // 1050px para consola ancha

        if (esAncho) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Columna izquierda: ECG y opcionalmente SpO₂ en formato vertical
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    SizedBox(
                      height: mostrarMax30100 ? 280 : 576,
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: const GraficoEcg(expandir: true),
                      ),
                    ),
                    if (mostrarMax30100) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 280,
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: const GraficoSpo2(expandir: true),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Columna derecha: MQ-135 CO₂ con alto completo
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 576, // 280 + 16 + 280
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: const GraficoCo2(expandir: true),
                  ),
                ),
              ),
            ],
          );
        }

        // Diseño en columna vertical para tablet y mobile
        final double alturaGrafico = constraints.maxWidth < Breakpoints.mobile
            ? 150.0
            : 220.0;
        final double alturaCo2 = constraints.maxWidth < Breakpoints.mobile
            ? 180.0
            : 190.0;

        return Column(
          children: [
            SizedBox(
              height: mostrarMax30100
                  ? alturaGrafico
                  : (alturaGrafico * 2 + 16),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: const GraficoEcg(expandir: true),
              ),
            ),
            if (mostrarMax30100) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: alturaGrafico,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: const GraficoSpo2(expandir: true),
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              height: alturaCo2,
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: const GraficoCo2(expandir: true),
              ),
            ),
          ],
        );
      },
    );
  }
}
