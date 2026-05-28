import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/vital_signs_provider.dart';
import 'co2_gauge.dart';
import 'co2_threshold_badge.dart';
import 'co2_compact_indicator.dart';

/// Widget premium de calidad de aire (MQ-135) adaptado a un diseño ancho y componentizado.
/// Distribuye el Gauge a la izquierda y un panel clínico explicativo legible a la derecha.
class GraficoCo2 extends ConsumerWidget {
  final bool esCompacto;
  final bool expandir;
  const GraficoCo2({super.key, this.esCompacto = false, this.expandir = false});

  Color _getColorForCo2(double value, bool esOscuro) {
    if (value < 600) {
      return esOscuro ? Colors.greenAccent.shade400 : const Color(0xFF16A34A);
    }
    if (value < 1000) {
      return esOscuro ? ColoresSensores.co2Amarillo : const Color(0xFFD97706);
    }
    return esOscuro ? Colors.redAccent.shade400 : const Color(0xFFDC2626);
  }

  String _getLabelForCo2(double value) {
    if (value < 600) {
      return 'Excelente (Seguro)';
    }
    if (value < 1000) {
      return 'Moderado (Ventilar)';
    }
    return 'Crítico (Alerta)';
  }

  String _getRecomendacionCo2(double value) {
    if (value < 600) {
      return 'El aire en la sala está limpio y bien oxigenado. No se requiere ventilación adicional en este momento.';
    } else if (value < 1000) {
      return 'Concentración moderada de CO₂. Se recomienda abrir ventanas o activar la ventilación mecánica pronto.';
    } else {
      return 'Nivel crítico. Riesgo de somnolencia, cefalea y disminución de la concentración. ¡Abra puertas y ventanas de inmediato!';
    }
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
    final estadoTexto = _getLabelForCo2(nivelCo2);
    final recomendacion = _getRecomendacionCo2(nivelCo2);

    if (esCompacto) {
      final widgetCompacto = Container(
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: esOscuro ? ColoresOscuros.border : ColoresClaros.border,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: esOscuro
                    ? const Color(0xFF1E1E1E)
                    : const Color(0xFFF3F4F6),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'MQ-135 (Dióxido de Carbono - CO2)',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: colorActual,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final double maxHeight = constraints.maxHeight;
                      // Ajusta el tamaño del gauge dinámicamente según la altura disponible del contenedor (margen optimizado para maximizar el tamaño)
                      final double gaugeSize = (maxHeight - 4).clamp(80.0, 170.0);

                      // Multiplicador de escala para adaptar texto y márgenes de forma totalmente fluida y simétrica
                      final double fontSizeMultiplier = (gaugeSize / 110.0).clamp(
                        0.9,
                        1.25,
                      );
                      final double gapBetweenItems = 10.0 * fontSizeMultiplier;
                      final double gapBetweenSections = gaugeSize > 130
                          ? 28.0
                          : 18.0;

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
                                esCompacto: true,
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
                                        ? Colors.greenAccent.shade400
                                        : const Color(0xFF16A34A),
                                    fontSizeMultiplier: fontSizeMultiplier,
                                  ),
                                  Gap(gapBetweenItems),
                                  Co2CompactIndicator(
                                    label: 'Moderado',
                                    range: '600 - 1000 ppm',
                                    color: esOscuro
                                        ? ColoresSensores.co2Amarillo
                                        : const Color(0xFFD97706),
                                    fontSizeMultiplier: fontSizeMultiplier,
                                  ),
                                  Gap(gapBetweenItems),
                                  Co2CompactIndicator(
                                    label: 'Crítico',
                                    range: '> 1000 ppm',
                                    color: esOscuro
                                        ? Colors.redAccent.shade400
                                        : const Color(0xFFDC2626),
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 16),
                                const SizedBox(width: 8),
                                const Text(
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
          ],
        ),
      );

      if (expandir) {
        return widgetCompacto;
      } else {
        return SizedBox(height: 160, child: widgetCompacto);
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: esOscuro ? ColoresOscuros.border : ColoresClaros.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cabecera del panel MQ-135
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: esOscuro
                  ? const Color(0xFF1E1E1E)
                  : const Color(0xFFF3F4F6),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: const Row(
              children: [
                Text(
                  'MQ-135 (MONITOREO DE CALIDAD DE AIRE EN SALA)',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),

          // Cuerpo adaptativo
          Padding(
            padding: const EdgeInsets.all(20),
            child: Stack(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final esAncho = constraints.maxWidth > 580;

                    // Widget del Gauge
                    final widgetGauge = Co2Gauge(
                      value: nivelCo2,
                      accentColor: colorActual,
                      size: 220,
                      esOscuro: esOscuro,
                      esCompacto: false,
                    );

                    // Widget de las explicaciones y recomendaciones
                    final widgetExplicacion = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Estado actual en grande
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: colorActual,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: colorActual.withValues(alpha: 0.4),
                                    blurRadius: 6,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              estadoTexto.toUpperCase(),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: colorActual,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Recomendación clínica / técnica
                        Text(
                          recomendacion,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: esOscuro
                                ? Colors.grey.shade300
                                : Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Tabla / Fila de Umbrales más legible y grande
                        const Text(
                          'RANGOS DE SEGURIDAD INTERIOR:',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            Co2ThresholdBadge(
                              label: 'EXCELENTE',
                              value: '< 600 ppm',
                              color: Colors.greenAccent.shade400,
                              esOscuro: esOscuro,
                            ),
                            Co2ThresholdBadge(
                              label: 'MODERADO',
                              value: '600 - 1000 ppm',
                              color: ColoresSensores.co2Amarillo,
                              esOscuro: esOscuro,
                            ),
                            Co2ThresholdBadge(
                              label: 'CRÍTICO',
                              value: '> 1000 ppm',
                              color: Colors.redAccent.shade400,
                              esOscuro: esOscuro,
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
                      return Column(
                        children: [
                          widgetGauge,
                          const SizedBox(height: 24),
                          widgetExplicacion,
                        ],
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
            ),
          ),
        ],
      ),
    );
  }
}
