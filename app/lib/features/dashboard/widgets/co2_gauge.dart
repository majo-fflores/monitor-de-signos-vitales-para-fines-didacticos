import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

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
    final double endAngle = startAngle + sweepAngle;

    // 1. Dibujar el arco de base (Track)
    final trackPaint = Paint()
      ..color = esOscuro ? ColoresComponentes.co2GaugeTrackOscuro : ColoresComponentes.co2GaugeTrackClaro
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
          fontSize: 12.0,
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

/// Widget premium de visualización de indicador instrumental para calidad de aire.
/// Soporta renderizado de diales proporcionales y estáticos de manera responsiva.
class Co2Gauge extends StatelessWidget {
  final double value;
  final double minValue;
  final double maxValue;
  final Color accentColor;
  final double size;
  final bool esOscuro;

  const Co2Gauge({
    super.key,
    required this.value,
    this.minValue = 300.0,
    this.maxValue = 1500.0,
    required this.accentColor,
    required this.size,
    required this.esOscuro,
  });

  @override
  Widget build(BuildContext context) {
    final sizeInner = size - 2;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(sizeInner, sizeInner),
            painter: _PremiumGaugePainter(
              value: value,
              minValue: minValue,
              maxValue: maxValue,
              accentColor: accentColor,
              esOscuro: esOscuro,
            ),
          ),
          Positioned(
            top: sizeInner * 0.28,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${value.toInt()}',
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    fontSize: sizeInner * 0.20,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                    color: esOscuro ? Colors.white : Colors.black87,
                    shadows: [
                      Shadow(
                        color: accentColor.withValues(alpha: 0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                Text(
                  'ppm CO₂',
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    fontSize: sizeInner * 0.07,
                    color: esOscuro ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
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
