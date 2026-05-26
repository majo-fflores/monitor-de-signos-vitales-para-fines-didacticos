import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class MetricaInline extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final ThemeData theme;
  final bool esOscuro;

  const MetricaInline({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
    required this.esOscuro,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: esOscuro
                ? ColoresOscuros.mutedForeground
                : ColoresClaros.mutedForeground,
            fontSize: 11,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall
              ?.copyWith(fontWeight: FontWeight.bold, fontSize: 11),
        ),
      ],
    );
  }
}
