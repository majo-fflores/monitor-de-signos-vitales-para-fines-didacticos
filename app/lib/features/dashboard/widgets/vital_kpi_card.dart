import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Tarjeta biométrica reutilizable mapeada a partir de los paneles de DashboardView.tsx.
/// Utiliza un borde lateral distintivo de color y tipografía tabular monoespaciada para evitar jittering.
class TarjetaKpiVital extends StatelessWidget {
  final String titulo;
  final String valor;
  final String unidad;
  final Color colorAcento;
  
  // Opciones para visualización dual (ej. SpO2 y Pulsaciones PPG en un mismo sensor)
  final String? valorSecundario;
  final String? unidadSecundaria;
  final String? tituloSecundario;

  const TarjetaKpiVital({
    super.key,
    required this.titulo,
    required this.valor,
    required this.unidad,
    required this.colorAcento,
    this.valorSecundario,
    this.unidadSecundaria,
    this.tituloSecundario,
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
                child: valorSecundario != null
                    ? Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  titulo.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: colorAcento,
                                    letterSpacing: 1.0,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      valor,
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        fontFeatures: [FontFeature.tabularFigures()], // Evita jitter numérico
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      unidad,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: esOscuro ? ColoresOscuros.mutedForeground : ColoresClaros.mutedForeground,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 48,
                            color: (esOscuro ? ColoresOscuros.border : ColoresClaros.border).withValues(alpha: 0.6),
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  (tituloSecundario ?? '').toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: colorAcento,
                                    letterSpacing: 1.0,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      valorSecundario!,
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        fontFeatures: [FontFeature.tabularFigures()],
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      unidadSecundaria ?? '',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: esOscuro ? ColoresOscuros.mutedForeground : ColoresClaros.mutedForeground,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
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
