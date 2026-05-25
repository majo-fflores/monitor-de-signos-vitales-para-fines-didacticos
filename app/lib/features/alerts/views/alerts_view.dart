import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AlertsView extends StatelessWidget {
  const AlertsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alertas de Monitoreo',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: isDark ? ColoresOscuros.foreground : ColoresClaros.foreground,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Notificaciones y advertencias críticas de sensores vitales y ambientales.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? ColoresOscuros.mutedForeground : ColoresClaros.mutedForeground,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.error.withValues(alpha: 0.05), // Reemplazado withOpacity por withValues
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.error.withValues(alpha: 0.2), // Reemplazado withOpacity por withValues
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sistema de Alarmas Operativo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Monitoreando umbrales normales de salud y ambiente.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? ColoresOscuros.mutedForeground : ColoresClaros.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: ColoresSensores.statusConectado.withValues(alpha: 0.1), // Reemplazado withOpacity por withValues
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: ColoresSensores.statusConectado.withValues(alpha: 0.2), // Reemplazado withOpacity por withValues
                  ),
                ),
                child: const Text(
                  'Estable',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ColoresSensores.statusConectado,
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
