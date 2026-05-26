import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class KpiChip extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;
  final ThemeData theme;
  final bool esOscuro;

  const KpiChip({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.color,
    required this.theme,
    required this.esOscuro,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: esOscuro ? ColoresOscuros.border : ColoresClaros.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icono, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                titulo,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: esOscuro
                      ? ColoresOscuros.mutedForeground
                      : ColoresClaros.mutedForeground,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                valor,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
