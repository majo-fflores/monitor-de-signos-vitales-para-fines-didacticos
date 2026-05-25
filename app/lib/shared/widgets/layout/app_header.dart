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

    final anchoPantalla = MediaQuery.of(context).size.width;
    final esMobileChico = anchoPantalla < 500;

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
      padding: EdgeInsets.symmetric(horizontal: esMobileChico ? 12 : 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Enums fijos
        children: [
          // Sección izquierda: Hamburguesa (mobile) + Título + Arduino
          Expanded(
            child: Row(
              children: [
                if (mostrarBotonMenu) ...[
                  IconButton(
                    onPressed: onMenuClick,
                    icon: const Icon(LucideIcons.menu),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  'DataVital',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800, // Reemplazado extrabold por w800
                    letterSpacing: -0.5,
                  ),
                ),
                if (!esMobileChico) ...[
                  const SizedBox(width: 12),
                  const ArduinoStatus(),
                ] else ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981), // Emerald green hex value
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Sección derecha: Reloj (si no es pantalla ultra chica) + ThemeToggle
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (anchoPantalla > 640) ...[
                const LiveClock(),
                const SizedBox(width: 16),
              ],
              const ThemeToggle(),
            ],
          ),
        ],
      ),
    );
  }
}
