import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/vital_signs_provider.dart';
import 'co2_compact_indicator.dart';
import 'co2_gauge.dart';
import 'co2_threshold_badge.dart';

/// Widget de monitoreo de Calidad de Aire (CO2) con MQ-135.
class GraficoCo2 extends ConsumerWidget {
  final bool expandir;
  const GraficoCo2({super.key, this.expandir = false});

  Color _getColorForCo2(double value, bool esOscuro) {
    if (value < 600) {
      return esOscuro ? ColoresSensores.excelenteOscuro : ColoresSensores.excelenteClaro;
    }
    if (value < 1000) {
      return esOscuro ? ColoresSensores.moderadoOscuro : ColoresSensores.moderadoClaro;
    }
    return esOscuro ? ColoresSensores.criticoOscuro : ColoresSensores.criticoClaro;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final esOscuro = theme.brightness == Brightness.dark;

    final nivelCo2 = ref
        .watch(notificadorSignosVitalesProvider.select((s) => s.nivelCo2))
        .toDouble();
    final co2Activo = ref
        .watch(notificadorSignosVitalesProvider.select((s) => s.co2Activo));
    final colorActual = _getColorForCo2(nivelCo2, esOscuro);

    final colorFondoHeader = esOscuro ? ColoresComponentes.graficoHeaderOscuro : ColoresComponentes.graficoHeaderClaro;
    final colorFondoCuerpo = esOscuro ? ColoresComponentes.graficoCuerpoOscuro : ColoresComponentes.graficoCuerpoClaro;

    return LayoutBuilder(
      builder: (context, parentConstraints) {
        final usarLayoutCompacto = parentConstraints.maxHeight.isFinite && parentConstraints.maxHeight < 320.0;

        if (usarLayoutCompacto) {
      final widgetCompacto = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: colorFondoHeader,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Dióxido de Carbono (CO2)',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      color: ColoresSensores.co2Amarillo,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: colorFondoCuerpo,
              child: Stack(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final double maxWidth = constraints.maxWidth;
                      final double maxHeight = constraints.maxHeight;
                      final bool esMovilEstrecho = maxWidth < 360;

                      // Ajusta el tamaño del gauge dinámicamente según la altura disponible del contenedor
                      double gaugeSize = (maxHeight - 4).clamp(80.0, 170.0);
                      if (esMovilEstrecho) {
                        gaugeSize = gaugeSize.clamp(80.0, 90.0);
                      }

                      // Multiplicador de escala para adaptar texto y márgenes de forma compacta
                      double fontSizeMultiplier = (gaugeSize / 110.0).clamp(
                        0.9,
                        1.0,
                      );
                      if (esMovilEstrecho) {
                        fontSizeMultiplier = 0.82;
                      }

                      final double gapBetweenItems = (esMovilEstrecho ? 5.0 : 10.0) * fontSizeMultiplier;
                      final double gapBetweenSections = esMovilEstrecho
                          ? 10.0
                          : (gaugeSize > 130 ? 28.0 : 18.0);

                      final esTarjetaAncha = maxWidth > 580;

                      if (esTarjetaAncha) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Co2Gauge(
                                value: nivelCo2,
                                accentColor: colorActual,
                                size: gaugeSize,
                                esOscuro: esOscuro,
                              ),
                              const Gap(32),
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Co2ThresholdBadge(
                                        label: 'EXCELENTE',
                                        value: '< 600 ppm',
                                        color: esOscuro
                                            ? ColoresSensores.excelenteOscuro
                                            : ColoresSensores.excelenteClaro,
                                        esOscuro: esOscuro,
                                      ),
                                    ),
                                    const Gap(12),
                                    Expanded(
                                      child: Co2ThresholdBadge(
                                        label: 'MODERADO',
                                        value: '600 - 1000 ppm',
                                        color: esOscuro
                                            ? ColoresSensores.moderadoOscuro
                                            : ColoresSensores.moderadoClaro,
                                        esOscuro: esOscuro,
                                      ),
                                    ),
                                    const Gap(12),
                                    Expanded(
                                      child: Co2ThresholdBadge(
                                        label: 'CRÍTICO',
                                        value: '> 1000 ppm',
                                        color: esOscuro
                                            ? ColoresSensores.criticoOscuro
                                            : ColoresSensores.criticoClaro,
                                        esOscuro: esOscuro,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Lado izquierdo: Gauge instrumental dinámico y centrado
                              Co2Gauge(
                                value: nivelCo2,
                                accentColor: colorActual,
                                size: gaugeSize,
                                esOscuro: esOscuro,
                              ),

                              Gap(gapBetweenSections),

                              // Lado derecho: Indicadores clínicos con fuente y espaciado dinámico
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Co2CompactIndicator(
                                    label: 'Excelente',
                                    range: '< 600 ppm',
                                    color: esOscuro
                                        ? ColoresSensores.excelenteOscuro
                                        : ColoresSensores.excelenteClaro,
                                    fontSizeMultiplier: fontSizeMultiplier,
                                  ),
                                  Gap(gapBetweenItems),
                                  Co2CompactIndicator(
                                    label: 'Moderado',
                                    range: '600 - 1000 ppm',
                                    color: esOscuro
                                        ? ColoresSensores.moderadoOscuro
                                        : ColoresSensores.moderadoClaro,
                                    fontSizeMultiplier: fontSizeMultiplier,
                                  ),
                                  Gap(gapBetweenItems),
                                  Co2CompactIndicator(
                                    label: 'Crítico',
                                    range: '> 1000 ppm',
                                    color: esOscuro
                                        ? ColoresSensores.criticoOscuro
                                        : ColoresSensores.criticoClaro,
                                    fontSizeMultiplier: fontSizeMultiplier,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  if (!co2Activo)
                    Positioned.fill(
                      child: Container(
                        color: esOscuro ? Colors.black87.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.9),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'SENSOR DESCONECTADO',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      );

      if (expandir) {
        return widgetCompacto;
      } else {
        return SizedBox(height: 180, child: widgetCompacto);
      }
    }

    final bodyStack = Stack(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final esAncho = constraints.maxWidth > 580;

            // Widget del Gauge
            final double dynamicGaugeSize = esAncho
                ? 220.0
                : (constraints.maxWidth - 16).clamp(150.0, 310.0);

            final widgetGauge = Co2Gauge(
              value: nivelCo2,
              accentColor: colorActual,
              size: dynamicGaugeSize,
              esOscuro: esOscuro,
            );

            // Widget de las explicaciones y recomendaciones sin cartel de estado actual
            final widgetExplicacion = Column(
              crossAxisAlignment: esAncho ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'RANGOS DE SEGURIDAD INTERIOR:',
                  textAlign: esAncho ? TextAlign.start : TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Co2ThresholdBadge(
                        label: 'EXCELENTE',
                        value: '< 600 ppm',
                        color: esOscuro ? ColoresSensores.excelenteOscuro : ColoresSensores.excelenteClaro,
                        esOscuro: esOscuro,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Co2ThresholdBadge(
                        label: 'MODERADO',
                        value: '600 - 1000 ppm',
                        color: esOscuro ? ColoresSensores.moderadoOscuro : ColoresSensores.moderadoClaro,
                        esOscuro: esOscuro,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Co2ThresholdBadge(
                        label: 'CRÍTICO',
                        value: '> 1000 ppm',
                        color: esOscuro ? ColoresSensores.criticoOscuro : ColoresSensores.criticoClaro,
                        esOscuro: esOscuro,
                      ),
                    ),
                  ],
                ),
              ],
            );

            if (esAncho) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  widgetGauge,
                  const SizedBox(width: 32),
                  Expanded(child: widgetExplicacion),
                ],
              );
            } else {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      widgetGauge,
                      const SizedBox(height: 24),
                      widgetExplicacion,
                    ],
                  ),
                ),
              );
            }
          },
        ),
        if (!co2Activo)
          Positioned.fill(
            child: Container(
              color: esOscuro ? Colors.black87.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.9),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'SENSOR DESCONECTADO',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Cabecera del panel MQ-135
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colorFondoHeader,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Monitoreo de Calidad de Aire (CO2)',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: ColoresSensores.co2Amarillo,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Cuerpo adaptativo
        expandir
            ? Expanded(
                child: Container(
                  color: colorFondoCuerpo,
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 0,
                    bottom: 20,
                  ),
                  child: bodyStack,
                ),
              )
            : Container(
                color: colorFondoCuerpo,
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 0,
                  bottom: 20,
                ),
                child: bodyStack,
              ),
      ],
    );
      },
    );
  }
}
