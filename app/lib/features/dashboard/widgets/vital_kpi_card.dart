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
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: esOscuro ? ColoresOscuros.border : ColoresClaros.border,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // Barra decorativa vertical de acento a la izquierda (Sensor color indicator)
            Container(
              width: 5,
              height: double.infinity,
              color: colorAcento,
            ),
            
            // Contenido del KPI
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      titulo.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: colorAcento,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          valor,
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            fontFeatures: [FontFeature.tabularFigures()], // Evita jitter numérico
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          unidad,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: esOscuro ? ColoresOscuros.mutedForeground : ColoresClaros.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
