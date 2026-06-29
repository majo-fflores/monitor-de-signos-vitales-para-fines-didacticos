import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/websocket_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/connection_provider.dart';
import '../../providers/vital_signs_provider.dart';

/// Indicador dinámico de estado de conexión del Arduino.
/// Replicación visual de un led pulsante verde (`animate-ping`) para estado conectado,
/// led azul para simulado, y rojo/gris para desconectado.
class ArduinoStatus extends ConsumerStatefulWidget {
  final bool isCompact;
  const ArduinoStatus({super.key, this.isCompact = false});

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

  Color _getColor(ConnectionStatus wsStatus) {
    switch (wsStatus) {
      case ConnectionStatus.connected:
        return SensorColors.statusConnected;
      case ConnectionStatus.connecting:
        return Colors.amber;
      case ConnectionStatus.error:
        return Colors.redAccent;
      case ConnectionStatus.disconnected:
        return Colors.grey.shade500;
    }
  }

  String _getText(ConnectionStatus wsStatus) {
    switch (wsStatus) {
      case ConnectionStatus.connected:
        return 'Conectado';
      case ConnectionStatus.connecting:
        return 'Conectando...';
      case ConnectionStatus.error:
        return 'Desconectado'; // error se muestra como Desconectado por pedido del usuario
      case ConnectionStatus.disconnected:
        return 'Desconectado';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Escuchamos el estado de conexión global y de signos vitales
    final connectionState = ref.watch(connectionNotifierProvider);
    final vitalState = ref.watch(vitalSignsNotifierProvider);

    final bool isArduinoConnected = connectionState.wsStatus == ConnectionStatus.connected &&
        (vitalState.isEcgActive || vitalState.isCo2Active);

    // Si wsStatus está conectado pero el arduino está desconectado, mostramos el estado como desconectado.
    final effectiveStatus = isArduinoConnected
        ? ConnectionStatus.connected
        : (connectionState.wsStatus == ConnectionStatus.connected
            ? ConnectionStatus.disconnected
            : connectionState.wsStatus);

    final color = _getColor(effectiveStatus);
    final text = _getText(effectiveStatus);

    // Solo parpadea el LED si está conectado o conectando
    final shouldAnimate =
        effectiveStatus == ConnectionStatus.connected ||
        effectiveStatus == ConnectionStatus.connecting;

    if (!shouldAnimate && _controller.isAnimating) {
      _controller.stop();
    } else if (shouldAnimate && !_controller.isAnimating) {
      _controller.repeat();
    }

    if (widget.isCompact) {
      return RepaintBoundary(
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (shouldAnimate)
              ScaleTransition(
                scale: Tween<double>(begin: 1.0, end: 2.2).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: Curves.easeOut,
                  ),
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
      );
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
                if (shouldAnimate)
                  ScaleTransition(
                    scale: Tween<double>(begin: 1.0, end: 2.2).animate(
                      CurvedAnimation(
                        parent: _controller,
                        curve: Curves.easeOut,
                      ),
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
            text,
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
