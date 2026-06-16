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

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool esPequeno = constraints.maxWidth < 220;

        final double cardHeight = esPequeno ? 84.0 : 110.0;
        final double titleFontSize = esPequeno ? 9.0 : 11.0;
        final double valueFontSize = esPequeno ? 24.0 : 34.0;
        final double unitFontSize = esPequeno ? 10.0 : 12.0;
        final double paddingLeftRight = esPequeno ? 8.0 : 16.0;
        final double paddingTop = esPequeno ? 8.0 : 10.0;
        final double paddingBottom = esPequeno ? 6.0 : 8.0;
        final double verticalGap = esPequeno ? 2.0 : 4.0;

        return Container(
          height: cardHeight,
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
                    padding: EdgeInsets.only(
                      left: paddingLeftRight,
                      right: paddingLeftRight,
                      top: paddingTop,
                      bottom: paddingBottom,
                    ),
                    child: valorSecundario != null
                        ? Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      titulo.toUpperCase(),
                                      textScaler: TextScaler.noScaling,
                                      style: TextStyle(
                                        fontSize: esPequeno ? 9.0 : 10.0,
                                        fontWeight: FontWeight.w700,
                                        color: colorAcento,
                                        letterSpacing: 1.0,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          valor,
                                          textScaler: TextScaler.noScaling,
                                          style: TextStyle(
                                            fontSize: esPequeno ? 22.0 : 32.0,
                                            fontWeight: FontWeight.w800,
                                            fontFeatures: const [
                                              FontFeature.tabularFigures(),
                                            ], // Evita jitter numérico
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          unidad,
                                          textScaler: TextScaler.noScaling,
                                          style: TextStyle(
                                            fontSize: esPequeno ? 10.0 : 12.0,
                                            fontWeight: FontWeight.w600,
                                            color: esOscuro
                                                ? ColoresOscuros.mutedForeground
                                                : ColoresClaros.mutedForeground,
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
                                color:
                                    (esOscuro
                                            ? ColoresOscuros.border
                                            : ColoresClaros.border)
                                        .withValues(alpha: 0.6),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      (tituloSecundario ?? '').toUpperCase(),
                                      textScaler: TextScaler.noScaling,
                                      style: TextStyle(
                                        fontSize: esPequeno ? 9.0 : 10.0,
                                        fontWeight: FontWeight.w700,
                                        color: colorAcento,
                                        letterSpacing: 1.0,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          valorSecundario!,
                                          textScaler: TextScaler.noScaling,
                                          style: TextStyle(
                                            fontSize: esPequeno ? 22.0 : 32.0,
                                            fontWeight: FontWeight.w800,
                                            fontFeatures: const [
                                              FontFeature.tabularFigures(),
                                            ],
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          unidadSecundaria ?? '',
                                          textScaler: TextScaler.noScaling,
                                          style: TextStyle(
                                            fontSize: esPequeno ? 10.0 : 12.0,
                                            fontWeight: FontWeight.w600,
                                            color: esOscuro
                                                ? ColoresOscuros.mutedForeground
                                                : ColoresClaros.mutedForeground,
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                titulo.toUpperCase(),
                                textScaler: TextScaler.noScaling,
                                style: TextStyle(
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.w700,
                                  color: colorAcento,
                                  letterSpacing: esPequeno ? 0.8 : 1.1,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: esPequeno ? 1 : 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: verticalGap),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    valor,
                                    textScaler: TextScaler.noScaling,
                                    style: TextStyle(
                                      fontSize: valueFontSize,
                                      fontWeight: FontWeight.w800,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ], // Evita jitter numérico
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    unidad,
                                    textScaler: TextScaler.noScaling,
                                    style: TextStyle(
                                      fontSize: unitFontSize,
                                      fontWeight: FontWeight.w600,
                                      color: esOscuro
                                          ? ColoresOscuros.mutedForeground
                                          : ColoresClaros.mutedForeground,
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
      },
    );
  }
}
