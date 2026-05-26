import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Indicador dinámico de estado de conexión del Arduino.
/// Replicación visual de un led pulsante verde (`animate-ping`).
class ArduinoStatus extends StatefulWidget {
  const ArduinoStatus({super.key});

  @override
  State<ArduinoStatus> createState() => _ArduinoStatusState();
}

class _ArduinoStatusState extends State<ArduinoStatus>
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: ColoresSensores.statusConectado.withValues(
          alpha: 0.1,
        ), // Reemplazado withOpacity
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColoresSensores.statusConectado.withValues(
            alpha: isDark ? 0.3 : 0.2,
          ), // Reemplazado withOpacity
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
                      decoration: const BoxDecoration(
                        color: ColoresSensores.statusConectado,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: ColoresSensores.statusConectado,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Arduino Conectado',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ColoresSensores.statusConectado,
            ),
          ),
        ],
      ),
    );
  }
}
