import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/services/websocket_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/connection_provider.dart';

class BackendConnectionCard extends ConsumerWidget {
  final Color subtitleColor;
  final Color borderColor;

  const BackendConnectionCard({
    super.key,
    required this.subtitleColor,
    required this.borderColor,
  });

  Color _colorEstadoConexion(EstadoConexion estado) {
    switch (estado) {
      case EstadoConexion.conectado:
        return ColoresSensores.statusConectado;
      case EstadoConexion.conectando:
        return Colors.amber;
      case EstadoConexion.error:
        return Colors.redAccent;
      case EstadoConexion.desconectado:
        return Colors.grey;
    }
  }

  String _textoEstado(EstadoConexionBackend estado) {
    switch (estado.estadoWs) {
      case EstadoConexion.conectado:
        return 'Conectado';
      case EstadoConexion.conectando:
        return 'Conectando...';
      case EstadoConexion.error:
        return 'Error';
      case EstadoConexion.desconectado:
        return 'Desconectado';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final estadoConexion = ref.watch(notificadorConexionProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.wifi,
                color: _colorEstadoConexion(estadoConexion.estadoWs),
              ),
              const Gap(10),
              Expanded(
                child: Text(
                  'Conexión al Backend',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Chip de estado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _colorEstadoConexion(estadoConexion.estadoWs).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _colorEstadoConexion(estadoConexion.estadoWs),
                      ),
                    ),
                    const Gap(6),
                    Text(
                      _textoEstado(estadoConexion),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _colorEstadoConexion(estadoConexion.estadoWs),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(8),
          Text(
            'Visualiza el estado de la conexión en tiempo real con el servidor de sensores biométricos.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: subtitleColor,
            ),
          ),
          const Divider(height: 32),

          // Switch para simulación local de prueba
          Material(
            type: MaterialType.transparency,
            child: SwitchListTile(
              title: const Text('Simular Datos de Prueba'),
              subtitle: const Text('Genera datos locales y ondas en tiempo real para probar alarmas y vistas'),
              value: estadoConexion.modoSimulacion,
              onChanged: (val) {
                ref.read(notificadorConexionProvider.notifier).cambiarModoSimulacion(val);
              },
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const Divider(height: 32),

          // Información de conexión y botón de reconexión manual
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dirección del Servidor',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      estadoConexion.wsUrl,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: estadoConexion.modoSimulacion
                    ? null
                    : () {
                        ref.read(notificadorConexionProvider.notifier).reconectar();
                      },
                icon: const Icon(LucideIcons.refreshCw, size: 16),
                label: const Text('Reconectar'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
