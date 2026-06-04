import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/models/usuario.dart';

/// Tarjeta compacta de usuario para la pantalla de selección.
/// Layout horizontal: Avatar | Info | Badge de sesiones | Eliminar.
class TarjetaUsuario extends StatelessWidget {
  final Usuario usuario;
  final bool esSeleccionado;
  final int cantidadSesiones;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TarjetaUsuario({
    super.key,
    required this.usuario,
    required this.esSeleccionado,
    required this.cantidadSesiones,
    required this.onTap,
    required this.onDelete,
  });

  Color _obtenerColorAvatar(String nombre) {
    const colores = [
      Color(0xFF3B82F6),
      Color(0xFF10B981),
      Color(0xFFEC4899),
      Color(0xFF8B5CF6),
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
      Color(0xFF06B6D4),
    ];
    return colores[nombre.hashCode.abs() % colores.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final esOscuro = theme.brightness == Brightness.dark;
    final colorAvatar = _obtenerColorAvatar(usuario.nombre);

    final borderColor = esSeleccionado
        ? theme.colorScheme.primary
        : (esOscuro ? const Color(0xFF333333) : const Color(0x1A000000));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: esSeleccionado
                ? theme.colorScheme.primary.withValues(alpha: 0.06)
                : theme.cardTheme.color,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: esSeleccionado ? 2 : 1),
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorAvatar.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: colorAvatar, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  usuario.iniciales,
                  style: TextStyle(
                    color: colorAvatar,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Nombre + meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      usuario.nombre,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      usuario.email,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Badge de sesiones
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$cantidadSesiones',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const SizedBox(width: 4),

              // Botón eliminar
              SizedBox(
                width: 32,
                height: 32,
                child: IconButton(
                  icon: const Icon(LucideIcons.trash2, size: 16),
                  color: theme.colorScheme.error.withValues(alpha: 0.7),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('¿Eliminar usuario?'),
                        content: Text(
                          'Se eliminará permanentemente a ${usuario.nombre} y todo su historial local.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancelar'),
                          ),
                          FilledButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              onDelete();
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: theme.colorScheme.error,
                              foregroundColor: theme.colorScheme.onError,
                            ),
                            child: const Text('Eliminar'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
