import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/connection_provider.dart';

class DashboardHeader extends StatelessWidget {
  final bool esOscuro;
  final bool tieneUsuarioActivo;
  final bool grabando;
  final bool vistaCompacta;
  final String tiempoFormateado;
  final EstadoConexionBackend estadoConexion;
  final VoidCallback onToggleVista;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;

  const DashboardHeader({
    super.key,
    required this.esOscuro,
    required this.tieneUsuarioActivo,
    required this.grabando,
    required this.vistaCompacta,
    required this.tiempoFormateado,
    required this.estadoConexion,
    required this.onToggleVista,
    required this.onStartRecording,
    required this.onStopRecording,
  });


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Dashboard de Bioseñales',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: esOscuro ? ColoresOscuros.foreground : ColoresClaros.foreground,
                    ),
                  ),
                ],
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
          IconButton(
            tooltip: vistaCompacta ? 'Vista Extendida (Lista)' : 'Vista Compacta (Cuadrícula)',
            icon: Icon(
              vistaCompacta ? LucideIcons.layoutList : LucideIcons.layoutGrid,
              color: vistaCompacta ? theme.colorScheme.primary : (esOscuro ? Colors.white70 : Colors.black54),
            ),
            onPressed: onToggleVista,
          ),
          const SizedBox(width: 8),
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
