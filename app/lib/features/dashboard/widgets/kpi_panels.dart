import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/vital_signs_provider.dart';
import 'vital_kpi_card.dart';

class KpiPanels extends ConsumerWidget {
  final bool esMobile;
  const KpiPanels({super.key, required this.esMobile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final frecuenciaCardiaca = ref.watch(notificadorSignosVitalesProvider.select((s) => s.frecuenciaCardiaca));
    final ppgFrecuenciaCardiaca = ref.watch(notificadorSignosVitalesProvider.select((s) => s.ppgFrecuenciaCardiaca));
    // Comentado temporalmente por migración de sensor MAX30100 a HW-827 (que no lee SpO2)
    // final nivelSpo2 = ref.watch(notificadorSignosVitalesProvider.select((s) => s.nivelSpo2));
    final nivelCo2 = ref.watch(notificadorSignosVitalesProvider.select((s) => s.nivelCo2));

    final listaKpis = [
      TarjetaKpiVital(
        titulo: 'Frecuencia Cardíaca',
        valor: '$frecuenciaCardiaca',
        unidad: 'LPM',
        colorAcento: ColoresSensores.ecgVerde,
      ),
      // Comentado temporalmente por migración de sensor MAX30100 a HW-827 (que no lee SpO2)
      // TarjetaKpiVital(
      //   titulo: 'Saturación de Oxígeno',
      //   valor: '$nivelSpo2',
      //   unidad: '%',
      //   colorAcento: ColoresSensores.spo2Azul,
      // ),
      TarjetaKpiVital(
        titulo: 'Pulsaciones (PPG)',
        valor: '$ppgFrecuenciaCardiaca',
        unidad: 'LPM',
        colorAcento: ColoresSensores.spo2Azul,
      ),
      TarjetaKpiVital(
        titulo: 'Dióxido de Carbono',
        valor: '$nivelCo2',
        unidad: 'ppm',
        colorAcento: ColoresSensores.co2Amarillo,
      ),
    ];

    final anchoPantalla = MediaQuery.of(context).size.width;
    final usarCuadricula = anchoPantalla < Breakpoints.tablet;

    if (usarCuadricula) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: listaKpis[0]),
              const SizedBox(width: 12),
              Expanded(child: listaKpis[1]),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: listaKpis[2]),
            ],
          ),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: listaKpis[0]),
          const SizedBox(width: 16),
          Expanded(child: listaKpis[1]),
          const SizedBox(width: 16),
          Expanded(child: listaKpis[2]),
        ],
      );
    }
  }
}
