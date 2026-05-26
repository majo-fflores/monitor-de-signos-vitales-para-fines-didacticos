import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/vital_signs_provider.dart';

/// Widget premium de calidad de aire (MQ-135) adaptado a un diseño ancho.
/// Distribuye el Gauge a la izquierda y un panel clínico explicativo legible a la derecha.
class GraficoCo2 extends ConsumerWidget {
  const GraficoCo2({super.key});

  Color _getColorForCo2(double value) {
    if (value < 600) return Colors.greenAccent.shade400;
    if (value < 1000) return ColoresSensores.co2Amarillo;
    return Colors.redAccent.shade400;
  }

  String _getLabelForCo2(double value) {
    if (value < 600) return 'Excelente (Seguro)';
    if (value < 1000) return 'Moderado (Ventilar)';
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
    final nivelCo2 = ref.watch(notificadorSignosVitalesProvider.select((s) => s.nivelCo2)).toDouble();
    final colorActual = _getColorForCo2(nivelCo2);
    final estadoTexto = _getLabelForCo2(nivelCo2);
    final recomendacion = _getRecomendacionCo2(nivelCo2);

    final theme = Theme.of(context);
    final esOscuro = theme.brightness == Brightness.dark;

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
              color: esOscuro ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6),
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final esAncho = constraints.maxWidth > 580;

                // Widget del Gauge
                final widgetGauge = SizedBox(
                  width: 200,
                  height: 160,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(180, 180),
                        painter: _PremiumGaugePainter(
                          value: nivelCo2,
                          minValue: 300.0,
                          maxValue: 1500.0,
                          accentColor: colorActual,
                          esOscuro: esOscuro,
                        ),
                      ),
                      Positioned(
                        top: 40,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${nivelCo2.toInt()}',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'monospace',
                                color: esOscuro ? Colors.white : Colors.black87,
                                shadows: [
                                  Shadow(
                                    color: colorActual.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'ppm CO₂',
                              style: TextStyle(
                                fontSize: 12,
                                color: esOscuro ? Colors.grey.shade400 : Colors.grey.shade600,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
                              BoxShadow(color: colorActual.withValues(alpha: 0.4), blurRadius: 6, spreadRadius: 2),
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
                        color: esOscuro ? Colors.grey.shade300 : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Tabla / Fila de Umbrales más legible y grande
                    const Text(
                      'RANGOS DE SEGURIDAD INTERIOR:',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.8),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        _buildThresholdBadge('EXCELENTE', '< 600 ppm', Colors.greenAccent.shade400, esOscuro),
                        _buildThresholdBadge('MODERADO', '600 - 1000 ppm', ColoresSensores.co2Amarillo, esOscuro),
                        _buildThresholdBadge('CRÍTICO', '> 1000 ppm', Colors.redAccent.shade400, esOscuro),
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
          ),
        ],
      ),
    );
  }

  Widget _buildThresholdBadge(String label, String value, Color color, bool esOscuro) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: esOscuro ? const Color(0xFF1E1E26) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: esOscuro ? Colors.grey.shade800 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
              color: esOscuro ? Colors.grey.shade300 : Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

/// Painter de Gauge Instrumental con Ticks (Marcas) y efecto de brillo
class _PremiumGaugePainter extends CustomPainter {
  final double value;
  final double minValue;
  final double maxValue;
  final Color accentColor;
  final bool esOscuro;

  _PremiumGaugePainter({
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.accentColor,
    required this.esOscuro,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 16;
    
    // Ángulos del arco: de 145 grados a 35 grados (escala invertida para Flutter)
    const double startAngle = math.pi * 0.8; // ~144°
    const double sweepAngle = math.pi * 1.4; // ~252°
    const double endAngle = startAngle + sweepAngle;

    // 1. Dibujar el arco de base (Track)
    final trackPaint = Paint()
      ..color = esOscuro ? const Color(0xFF1E1E26) : const Color(0xFFE5E7EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // Calcular progreso
    final double pct = ((value - minValue) / (maxValue - minValue)).clamp(0.0, 1.0);
    final double currentSweep = sweepAngle * pct;
    final double activeEndAngle = startAngle + currentSweep;

    // 2. Dibujar el arco de progreso activo con un sutil efecto de glow externo
    if (pct > 0.0) {
      final glowPaint = Paint()
        ..color = accentColor.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        currentSweep,
        false,
        glowPaint,
      );

      final activePaint = Paint()
        ..color = accentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        currentSweep,
        false,
        activePaint,
      );
    }

    // 3. Dibujar marcas de escala clínicas (Ticks)
    const int numTicks = 21;
    final tickColor = esOscuro ? Colors.grey.shade800 : Colors.grey.shade300;
    final activeTickColor = accentColor.withValues(alpha: 0.8);
    
    for (int i = 0; i < numTicks; i++) {
      final double tickAngle = startAngle + (sweepAngle * (i / (numTicks - 1)));
      final bool isTickActive = tickAngle <= activeEndAngle;
      
      // Los ticks principales son un poco más largos
      final bool isMajor = i % 5 == 0;
      final double tickLength = isMajor ? 8.0 : 4.0;
      final double strokeWidth = isMajor ? 1.5 : 1.0;

      final double startRadius = radius + 8;
      final double endRadius = startRadius + tickLength;

      final Offset startOffset = Offset(
        center.dx + startRadius * math.cos(tickAngle),
        center.dy + startRadius * math.sin(tickAngle),
      );
      final Offset endOffset = Offset(
        center.dx + endRadius * math.cos(tickAngle),
        center.dy + endRadius * math.sin(tickAngle),
      );

      final paintTick = Paint()
        ..color = isTickActive ? activeTickColor : tickColor
        ..strokeWidth = strokeWidth;

      canvas.drawLine(startOffset, endOffset, paintTick);
    }

    // 4. Dibujar etiquetas de los extremos (300 y 1500)
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    void drawLabel(String text, double angle, Offset alignment) {
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 10.0,
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
          color: esOscuro ? Colors.grey.shade500 : Colors.grey.shade700,
        ),
      );
      textPainter.layout();
      final double labelRadius = radius + 22;
      final Offset labelCenter = Offset(
        center.dx + labelRadius * math.cos(angle) - (textPainter.width * alignment.dx),
        center.dy + labelRadius * math.sin(angle) - (textPainter.height * alignment.dy),
      );
      textPainter.paint(canvas, labelCenter);
    }

    drawLabel('300', startAngle, const Offset(0.3, 0.5));
    drawLabel('1500', endAngle, const Offset(0.7, 0.5));

    // 5. Dibujar punto dinámico en el extremo del progreso (Indicator needle dot)
    if (pct > 0.0) {
      final double dotX = center.dx + radius * math.cos(activeEndAngle);
      final double dotY = center.dy + radius * math.sin(activeEndAngle);
      
      // Glow circular
      final pointGlow = Paint()
        ..color = accentColor.withValues(alpha: 0.6)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(dotX, dotY), 7.0, pointGlow);

      // Centro blanco/brillante
      final pointCenter = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(dotX, dotY), 3.0, pointCenter);
    }
  }

  @override
  bool shouldRepaint(covariant _PremiumGaugePainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.esOscuro != esOscuro;
  }
}
