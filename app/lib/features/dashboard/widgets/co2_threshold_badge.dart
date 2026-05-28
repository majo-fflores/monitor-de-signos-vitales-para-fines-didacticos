import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Plaqueta informativa (Badge) para mostrar umbrales y rangos en el diseño estándar.
class Co2ThresholdBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool esOscuro;

  const Co2ThresholdBadge({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.esOscuro,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: esOscuro ? ColoresComponentes.co2BadgeBgOscuro : ColoresComponentes.co2BadgeBgClaro,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: esOscuro ? ColoresOscuros.border : ColoresClaros.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
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
              color: esOscuro ? ColoresOscuros.foreground : ColoresClaros.foreground,
            ),
          ),
        ],
      ),
    );
  }
}
