import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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

  String _fmtDur(int s) {
    if (s < 60) return '${s}s';
    final m = s ~/ 60;
    if (m < 60) return '${m}m';
    return '${m ~/ 60}h ${m % 60}m';
  }

  @override
  Widget build(BuildContext context) {
    final total = registros.length;
    double promFC = 0;
    double promSpo2 = 0;
    int durTotal = 0;

    if (total > 0) {
      double sFC = 0;
      double sSpo2 = 0;
      for (final r in registros) {
        sFC += r.frecuenciaCardiaca;
        sSpo2 += r.nivelSpo2;
        durTotal += r.duracionSegundos;
      }
      promFC = sFC / total;
      promSpo2 = sSpo2 / total;
    }

    return SizedBox(
      height: 76,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          KpiChip(
            titulo: 'Sesiones',
            valor: '$total',
            icono: LucideIcons.checkSquare,
            color: const Color(0xFF8B5CF6),
            theme: theme,
            esOscuro: esOscuro,
          ),
          const SizedBox(width: 12),
          KpiChip(
            titulo: 'Prom. FC',
            valor: '${promFC.round()} LPM',
            icono: LucideIcons.heart,
            color: const Color(0xFF10B981), // Color ECG verde equivalente
            theme: theme,
            esOscuro: esOscuro,
          ),
          const SizedBox(width: 12),
          KpiChip(
            titulo: 'Prom. SpO2',
            valor: '${promSpo2.round()}%',
            icono: LucideIcons.droplets,
            color: const Color(0xFF3B82F6), // Color SpO2 azul equivalente
            theme: theme,
            esOscuro: esOscuro,
          ),
          const SizedBox(width: 12),
          KpiChip(
            titulo: 'Tiempo Total',
            valor: _fmtDur(durTotal),
            icono: LucideIcons.clock,
            color: const Color(0xFFF59E0B),
            theme: theme,
            esOscuro: esOscuro,
          ),
        ],
      ),
    );
  }
}
