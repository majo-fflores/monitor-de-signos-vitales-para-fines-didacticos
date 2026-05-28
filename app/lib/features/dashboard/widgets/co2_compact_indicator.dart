import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Indicador clínico compacto utilizado en la vista móvil adaptada del MQ-135.
class Co2CompactIndicator extends StatelessWidget {
  final String label;
  final String range;
  final Color color;
  final double fontSizeMultiplier;

  const Co2CompactIndicator({
    super.key,
    required this.label,
    required this.range,
    required this.color,
    this.fontSizeMultiplier = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final double bulletSize = 10.0 * fontSizeMultiplier;
    final double innerGapSize = 10.0 * fontSizeMultiplier;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: bulletSize,
          height: bulletSize,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.25),
                blurRadius: 4 * fontSizeMultiplier,
                spreadRadius: 1 * fontSizeMultiplier,
              ),
            ],
          ),
        ),
        Gap(innerGapSize),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 12 * fontSizeMultiplier,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: 0.7 * fontSizeMultiplier,
              ),
            ),
            Gap(2 * fontSizeMultiplier),
            Text(
              range,
              style: TextStyle(
                fontSize: 13 * fontSizeMultiplier,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
                letterSpacing: -0.2 * fontSizeMultiplier,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
