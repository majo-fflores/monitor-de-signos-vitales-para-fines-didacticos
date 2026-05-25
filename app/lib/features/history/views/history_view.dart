import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historial Biométrico',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800, // Reemplazado extrabold por w800
            color: isDark ? ColoresOscuros.foreground : ColoresClaros.foreground,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Auditoría de registros almacenados de los pacientes.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? ColoresOscuros.mutedForeground : ColoresClaros.mutedForeground,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? ColoresOscuros.border : ColoresClaros.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Registros Recientes',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                child: Center(
                  child: Text(
                    'No hay datos históricos disponibles por el momento.',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: ColoresClaros.mutedForeground,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
