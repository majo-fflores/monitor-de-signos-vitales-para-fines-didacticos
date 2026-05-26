import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/vital_signs_provider.dart';
import 'vital_kpi_card.dart';

class KpiPanels extends ConsumerWidget {
  final bool esMobile;
  const KpiPanels({super.key, required this.esMobile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final frecuenciaCardiaca = ref.watch(notificadorSignosVitalesProvider.select((s) => s.frecuenciaCardiaca));
    final nivelSpo2 = ref.watch(notificadorSignosVitalesProvider.select((s) => s.nivelSpo2));
    final nivelCo2 = ref.watch(notificadorSignosVitalesProvider.select((s) => s.nivelCo2));
    final amplitudAcustica = ref.watch(notificadorSignosVitalesProvider.select((s) => s.amplitudAcustica));

    final listaKpis = [
      TarjetaKpiVital(
        titulo: 'AD8232 (Frecuencia Cardíaca)',
        valor: '$frecuenciaCardiaca',
        unidad: 'LPM',
        colorAcento: ColoresSensores.ecgVerde,
      ),
      const SizedBox(height: 16),
      TarjetaKpiVital(
        titulo: 'MAX30100 (Saturación SpO2)',
        valor: '$nivelSpo2',
        unidad: '%',
        colorAcento: ColoresSensores.spo2Azul,
      ),
      const SizedBox(height: 16),
      TarjetaKpiVital(
        titulo: 'MQ-135 (Dióxido de Carbono)',
        valor: '$nivelCo2',
        unidad: 'ppm',
        colorAcento: ColoresSensores.co2Amarillo,
      ),
      const SizedBox(height: 16),
      TarjetaKpiVital(
        titulo: 'LM386 (Amplitud de Audio)',
        valor: '$amplitudAcustica',
        unidad: '%',
        colorAcento: Colors.cyanAccent.shade400,
      ),
    ];

    if (esMobile) {
      return Column(
        children: [
          listaKpis[0],
          const SizedBox(height: 12),
          listaKpis[2],
          const SizedBox(height: 12),
          listaKpis[4],
          const SizedBox(height: 12),
          listaKpis[6],
        ],
      );
    } else {
      return Column(
        children: listaKpis,
      );
    }
  }
}
