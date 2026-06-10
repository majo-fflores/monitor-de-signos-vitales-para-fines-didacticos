import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../core/models/registro_medicion.dart';
import 'kpi_chip.dart';

class HistoryStatisticsSummary extends StatelessWidget {
  final List<RegistroMedicion> registros;
  final ThemeData theme;
  final bool esOscuro;

  const HistoryStatisticsSummary({
    super.key,
    required this.registros,
    required this.theme,
    required this.esOscuro,
  });



  @override
  Widget build(BuildContext context) {
    final total = registros.length;
    double promFC = 0;
    double promCO2 = 0;
    double promPPG = 0;

    if (total > 0) {
      double sFC = 0;
      double sCO2 = 0;
      double sPPG = 0;
      for (final r in registros) {
        sFC += r.frecuenciaCardiaca;
        sCO2 += r.nivelCo2;
        sPPG += r.ppgFrecuenciaCardiaca;
      }
      promFC = sFC / total;
      promCO2 = sCO2 / total;
      promPPG = sPPG / total;
    }

    final chips = [
      _KpiData(
        titulo: 'Sesiones',
        valor: '$total',
        icono: LucideIcons.checkSquare,
        color: const Color(0xFF8B5CF6),
      ),
      _KpiData(
        titulo: 'Prom. FC',
        valor: '${promFC.round()} LPM',
        icono: LucideIcons.heart,
        color: const Color(0xFF10B981),
      ),
      _KpiData(
        titulo: 'Prom. CO2',
        valor: '${promCO2.round()} ppm',
        icono: LucideIcons.cloud,
        color: const Color(0xFFF59E0B),
      ),
      _KpiData(
        titulo: 'Prom. Pulso (PPG)',
        valor: '${promPPG.round()} LPM',
        icono: LucideIcons.activity,
        color: const Color(0xFF3B82F6),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final esMobile = constraints.maxWidth < Breakpoints.tablet;

        if (esMobile) {
          // Mobile: grilla 2x2
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: chips.map((c) {
              return SizedBox(
                width: (constraints.maxWidth - 12) / 2,
                child: KpiChip(
                  titulo: c.titulo,
                  valor: c.valor,
                  icono: c.icono,
                  color: c.color,
                  theme: theme,
                  esOscuro: esOscuro,
                  expanded: true,
                ),
              );
            }).toList(),
          );
        }

        // Desktop/Tablet: fila que ocupa todo el ancho
        return Row(
          children: [
            for (int i = 0; i < chips.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(
                child: KpiChip(
                  titulo: chips[i].titulo,
                  valor: chips[i].valor,
                  icono: chips[i].icono,
                  color: chips[i].color,
                  theme: theme,
                  esOscuro: esOscuro,
                  expanded: true,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _KpiData {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;

  const _KpiData({
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.color,
  });
}
