import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/websocket_service.dart';
import '../../providers/connection_provider.dart';

/// Indicador dinámico de estado de conexión del Arduino.
/// Replicación visual de un led pulsante verde (`animate-ping`) para estado conectado,
/// led azul para simulado, y rojo/gris para desconectado.
class ArduinoStatus extends ConsumerStatefulWidget {
  const ArduinoStatus({super.key});

  @override
  ConsumerState<ArduinoStatus> createState() => _ArduinoStatusState();
}

class _ArduinoStatusState extends ConsumerState<ArduinoStatus>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _obtenerColor(ModoFuente modo, EstadoConexion estadoWs) {
    if (modo == ModoFuente.simulacion) {
      return Colors.blueAccent;
    }
    switch (estadoWs) {
      case EstadoConexion.conectado:
        return ColoresSensores.statusConectado;
      case EstadoConexion.conectando:
        return Colors.amber;
      case EstadoConexion.error:
        return Colors.redAccent;
      case EstadoConexion.desconectado:
        return Colors.grey.shade500;
    }
  }

  String _obtenerTexto(ModoFuente modo, EstadoConexion estadoWs) {
    if (modo == ModoFuente.simulacion) {
      return 'Simulado';
    }
    switch (estadoWs) {
      case EstadoConexion.conectado:
        return 'Conectado';
      case EstadoConexion.conectando:
        return 'Conectando...';
      case EstadoConexion.error:
        return 'Desconectado'; // error se muestra como Desconectado por pedido del usuario
      case EstadoConexion.desconectado:
        return 'Desconectado';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Escuchamos el estado de conexión global
    final estadoConexion = ref.watch(notificadorConexionProvider);
    final color = _obtenerColor(estadoConexion.modo, estadoConexion.estadoWs);
    final texto = _obtenerTexto(estadoConexion.modo, estadoConexion.estadoWs);

    // Solo parpadea el LED si está conectado, simulando, o conectando
    final debeAnimar = estadoConexion.modo == ModoFuente.simulacion || 
                       estadoConexion.estadoWs == EstadoConexion.conectado ||
                       estadoConexion.estadoWs == EstadoConexion.conectando;

    if (!debeAnimar && _controller.isAnimating) {
      _controller.stop();
    } else if (debeAnimar && !_controller.isAnimating) {
      _controller.repeat();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.3 : 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Led pulsante
          RepaintBoundary(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (debeAnimar)
                  ScaleTransition(
                    scale: Tween<double>(begin: 1.0, end: 2.2).animate(
                      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
                    ),
                    child: FadeTransition(
                      opacity: Tween<double>(
                        begin: 0.8,
                        end: 0.0,
                      ).animate(_controller),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            texto,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
