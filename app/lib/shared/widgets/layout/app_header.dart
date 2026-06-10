import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/usuario_provider.dart';
import 'arduino_status.dart';
import 'live_clock.dart';

/// Encabezado estático superior de la aplicación.
/// Muestra título, widget del estado de Arduino, chip del usuario activo y controles de tema/reloj.
class AppHeader extends ConsumerWidget {
  final VoidCallback? onMenuClick;
  final bool mostrarBotonMenu;

  const AppHeader({
    super.key,
    this.onMenuClick,
    this.mostrarBotonMenu = false,
  });

  Color _obtenerColorAvatar(String nombre) {
    final colores = ColoresComponentes.avatarColores;
    final hash = nombre.hashCode.abs();
    return colores[hash % colores.length];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final esOscuro = theme.brightness == Brightness.dark;

    final anchoPantalla = MediaQuery.of(context).size.width;
    final esMobileChico = anchoPantalla < 500;

    final estadoUsuarios = ref.watch(notificadorUsuariosProvider);
    final usuarioActivo = estadoUsuarios.usuarioActivo;

    return Container(
      height: 80,
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        border: Border(
          bottom: BorderSide(
            color: esOscuro 
                ? ColoresOscuros.border
                : ColoresClaros.border,
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: esMobileChico ? 12 : 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                if (!esMobileChico) ...[
                  const ArduinoStatus(),
                ] else ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: ColoresSensores.statusConectado, // Emerald green hex value
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Sección derecha: Reloj, Chip de Usuario, ThemeToggle
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (anchoPantalla > 640) ...[
                const LiveClock(),
                const SizedBox(width: 16),
              ],
              
              // Chip de Usuario Activo con menú desplegable
              if (usuarioActivo != null) ...[
                PopupMenuButton<String>(
                  offset: const Offset(0, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: esOscuro ? ColoresComponentes.popupBorderOscuro : ColoresComponentes.popupBorderClaro,
                    ),
                  ),
                  onSelected: (value) {
                    if (value == 'cambiar') {
                      ref.read(notificadorUsuariosProvider.notifier).cambiarUsuario();
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      enabled: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            usuarioActivo.nombre,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            usuarioActivo.email,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const Divider(),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'cambiar',
                      child: Row(
                        children: [
                          const Icon(LucideIcons.users, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Cambiar Usuario',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: esOscuro
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _obtenerColorAvatar(usuarioActivo.nombre),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            usuarioActivo.iniciales,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (anchoPantalla > 500) ...[
                          Text(
                            usuarioActivo.nombre.split(' ')[0],
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            LucideIcons.chevronDown,
                            size: 14,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
              
            ],
          ),
        ],
      ),
    );
  }
}
