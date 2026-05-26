import 'package:flutter/material.dart';
import 'ecg_chart.dart';
import 'spo2_chart.dart';
import 'pcg_chart.dart';
import 'co2_chart.dart';

class WaveCharts extends StatelessWidget {
  const WaveCharts({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Card(
          clipBehavior: Clip.antiAlias,
          child: GraficoEcg(),
        ),
        SizedBox(height: 16),
        Card(
          clipBehavior: Clip.antiAlias,
          child: GraficoSpo2(),
        ),
        SizedBox(height: 16),
        Card(
          clipBehavior: Clip.antiAlias,
          child: GraficoPcg(),
        ),
        SizedBox(height: 16),
        Card(
          clipBehavior: Clip.antiAlias,
          child: GraficoCo2(),
        ),
      ],
    );
  }
}
