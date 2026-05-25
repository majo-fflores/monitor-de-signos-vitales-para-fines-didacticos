import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Tarjeta biométrica reutilizable mapeada a partir de los paneles de DashboardView.tsx.
/// Utiliza un borde lateral distintivo de color y tipografía tabular monoespaciada para evitar jittering.
class TarjetaKpiVital extends StatelessWidget {
  final String titulo;
  final String valor;
  final String unidad;
  final Color colorAcento;

  const TarjetaKpiVital({
    super.key,
    required this.titulo,
    required this.valor,
    required this.unidad,
    required this.colorAcento,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final esOscuro = theme.brightness == Brightness.dark;

    return Container(
      height: 128,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: colorAcento, width: 4), // Borde distintivo
          top: BorderSide(color: esOscuro ? ColoresOscuros.border : ColoresClaros.border),
          right: BorderSide(color: esOscuro ? ColoresOscuros.border : ColoresClaros.border),
          bottom: BorderSide(color: esOscuro ? ColoresOscuros.border : ColoresClaros.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            titulo.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: colorAcento,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  fontFeatures: [FontFeature.tabularFigures()], // Evita jitter numérico
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: 6),
              Text(
                unidad,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: esOscuro ? ColoresOscuros.mutedForeground : ColoresClaros.mutedForeground,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
