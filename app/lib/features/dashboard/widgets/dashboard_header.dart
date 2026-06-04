import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/connection_provider.dart';

class DashboardHeader extends StatelessWidget {
  final bool esOscuro;
  final bool tieneUsuarioActivo;
  final bool grabando;
  final String tiempoFormateado;
  final EstadoConexionBackend estadoConexion;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;

  const DashboardHeader({
    super.key,
    required this.esOscuro,
    required this.tieneUsuarioActivo,
    required this.grabando,
    required this.tiempoFormateado,
    required this.estadoConexion,
    required this.onStartRecording,
    required this.onStopRecording,
  });


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final anchoPantalla = MediaQuery.of(context).size.width;
    final esMobile = anchoPantalla < 600;

    final titleStyle = esMobile
        ? theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: esOscuro ? ColoresOscuros.foreground : ColoresClaros.foreground,
          )
        : theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: esOscuro ? ColoresOscuros.foreground : ColoresClaros.foreground,
          );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard de Bioseñales',
                style: titleStyle,
              ),
              const SizedBox(height: 4),
              Text(
                'Visualización en tiempo real de sensores.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: esOscuro ? ColoresOscuros.mutedForeground : ColoresClaros.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        
        // Botón de control de grabación
        if (tieneUsuarioActivo) ...[
          grabando
              ? OutlinedButton.icon(
                  onPressed: onStopRecording,
                  icon: const Icon(LucideIcons.square, size: 16, color: Colors.red),
                  label: Text(
                    'DETENER ($tiempoFormateado)',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                  ),
                )
              : FilledButton.icon(
                  onPressed: onStartRecording,
                  icon: const Icon(LucideIcons.play, size: 16),
                  label: const Text('GRABAR SESIÓN'),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                ),
        ],
      ],
    );
  }
}
