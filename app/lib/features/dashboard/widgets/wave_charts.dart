import 'package:flutter/material.dart';

import 'co2_chart.dart';
import 'ecg_chart.dart';
import 'spo2_chart.dart';

class WaveCharts extends StatelessWidget {
  final bool esCompacto;
  const WaveCharts({super.key, this.esCompacto = false});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final esAncho = constraints.maxWidth > 550;

        if (esCompacto && esAncho) {
          return GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.8,
            children: const [
              Card(
                clipBehavior: Clip.antiAlias,
                child: GraficoEcg(esCompacto: true, expandir: true),
              ),
              Card(
                clipBehavior: Clip.antiAlias,
                child: GraficoSpo2(esCompacto: true, expandir: true),
              ),
              Card(
                clipBehavior: Clip.antiAlias,
                child: GraficoCo2(esCompacto: true, expandir: true),
              ),
            ],
          );
        }

        return Column(
          children: [
            Card(
              clipBehavior: Clip.antiAlias,
              child: GraficoEcg(esCompacto: esCompacto, expandir: false),
            ),
            const SizedBox(height: 16),
            Card(
              clipBehavior: Clip.antiAlias,
              child: GraficoSpo2(esCompacto: esCompacto, expandir: false),
            ),
            const SizedBox(height: 16),
            Card(
              clipBehavior: Clip.antiAlias,
              child: GraficoCo2(esCompacto: esCompacto, expandir: false),
            ),
          ],
        );
      },
    );
  }
}
