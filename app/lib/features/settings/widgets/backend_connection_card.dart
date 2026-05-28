import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/services/websocket_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/connection_provider.dart';
import '../../../../shared/providers/vital_signs_provider.dart';

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
    if (estado.modo == ModoFuente.simulacion) return 'Simulación';
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
                color: estadoConexion.modo == ModoFuente.websocket
                    ? _colorEstadoConexion(estadoConexion.estadoWs)
                    : subtitleColor,
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
                  color: estadoConexion.modo == ModoFuente.websocket
                      ? _colorEstadoConexion(estadoConexion.estadoWs).withValues(alpha: 0.15)
                      : subtitleColor.withValues(alpha: 0.1),
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
                        color: estadoConexion.modo == ModoFuente.websocket
                            ? _colorEstadoConexion(estadoConexion.estadoWs)
                            : subtitleColor,
                      ),
                    ),
                    const Gap(6),
                    Text(
                      _textoEstado(estadoConexion),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: estadoConexion.modo == ModoFuente.websocket
                            ? _colorEstadoConexion(estadoConexion.estadoWs)
                            : subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(8),
          Text(
            'Selecciona la fuente de datos de los sensores: simulación local o datos en tiempo real del servidor.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: subtitleColor,
            ),
          ),
          const Gap(16),

          // Toggle Simulación / WebSocket
          // NOTA: Se envuelve el ListTile en un widget de Material transparente
          // para solucionar permanentemente el crash por DecoratedBox del Framework
          Material(
            type: MaterialType.transparency,
            child: SwitchListTile(
              title: const Text('Datos del Servidor (WebSocket)'),
              subtitle: Text(
                estadoConexion.modo == ModoFuente.websocket
                    ? 'Conectado al backend: ${estadoConexion.wsUrl}'
                    : 'Usando simulación local de sensores',
              ),
              value: estadoConexion.modo == ModoFuente.websocket,
              onChanged: (val) {
                final nuevoModo = val ? ModoFuente.websocket : ModoFuente.simulacion;
                ref.read(notificadorConexionProvider.notifier).cambiarModo(nuevoModo);
                
                // Reiniciar fuente de datos
                final notifier = ref.read(notificadorSignosVitalesProvider.notifier);
                if (nuevoModo == ModoFuente.websocket) {
                  final ws = ref.read(notificadorConexionProvider.notifier).wsService;
                  notifier.iniciarConWebSocket(ws.packetStream);
                } else {
                  notifier.iniciarSimulacion();
                }
              },
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
