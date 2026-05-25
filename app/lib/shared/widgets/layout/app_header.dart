import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'arduino_status.dart';
import 'live_clock.dart';
import 'theme_toggle.dart';

/// Encabezado estático superior de la aplicación.
/// Muestra título, widget del estado de Arduino y controles de tema/reloj.
class AppHeader extends StatelessWidget {
  final VoidCallback? onMenuClick;
  final bool mostrarBotonMenu;

  const AppHeader({
    super.key,
    this.onMenuClick,
    this.mostrarBotonMenu = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final esOscuro = theme.brightness == Brightness.dark;

    return Container(
      height: 80,
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        border: Border(
          bottom: BorderSide(
            color: esOscuro 
                ? const Color(0xFF333333) // ColoresOscuros.border
                : const Color(0xFFECECF0), // ColoresClaros.border
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Enums fijos
        children: [
          // Sección izquierda: Hamburguesa (mobile) + Título + Arduino
          Row(
            children: [
              if (mostrarBotonMenu) ...[
                IconButton(
                  onPressed: onMenuClick,
                  icon: const Icon(LucideIcons.menu),
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Text(
                'DataVital',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800, // Reemplazado extrabold por w800
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 16),
              const ArduinoStatus(),
            ],
          ),
          
          // Sección derecha: Reloj (si no es pantalla ultra chica) + ThemeToggle
          Row(
            children: [
              if (MediaQuery.of(context).size.width > 640) ...[
                const LiveClock(),
                const SizedBox(width: 24),
              ],
              const ThemeToggle(),
            ],
          ),
        ],
      ),
    );
  }
}
