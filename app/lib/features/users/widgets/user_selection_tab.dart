import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/usuario_provider.dart';
import 'user_card.dart';

class UserSelectionTab extends StatelessWidget {
  final TextEditingController searchController;
  final List<dynamic> usuariosFiltrados;
  final EstadoUsuarios estadoUsuarios;
  final Map<String, int> sessionCounts;
  final String filtroBusqueda;
  final ValueChanged<dynamic> onSeleccionarUsuario;
  final ValueChanged<String> onEliminarUsuario;

  const UserSelectionTab({
    super.key,
    required this.searchController,
    required this.usuariosFiltrados,
    required this.estadoUsuarios,
    required this.sessionCounts,
    required this.filtroBusqueda,
    required this.onSeleccionarUsuario,
    required this.onEliminarUsuario,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final esOscuro = theme.brightness == Brightness.dark;

    if (estadoUsuarios.usuarios.isEmpty) {
      return SizedBox(
        height: 240,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.usersRound,
                size: 48,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
              ),
              const Gap(12),
              Text(
                'No hay usuarios creados',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(6),
              Text(
                'Crea un usuario en la pestaña de Registro.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: esOscuro
                      ? ColoresOscuros.mutedForeground
                      : ColoresClaros.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Buscador
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Buscar por nombre o correo...',
            prefixIcon: const Icon(LucideIcons.search, size: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
          ),
        ),
        const Gap(16),
        // Lista (con altura máxima para no explotar verticalmente)
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 340),
          child: usuariosFiltrados.isEmpty
              ? SizedBox(
                  height: 120,
                  child: Center(
                    child: Text(
                      'Sin resultados para "$filtroBusqueda"',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: esOscuro
                            ? ColoresOscuros.mutedForeground
                            : ColoresClaros.mutedForeground,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: usuariosFiltrados.length,
                  separatorBuilder: (_, __) => const Gap(10),
                  itemBuilder: (context, index) {
                    final u = usuariosFiltrados[index];
                    final esActivo = estadoUsuarios.usuarioActivo?.id == u.id;
                    final sesiones = sessionCounts[u.id] ?? 0;

                    return TarjetaUsuario(
                      usuario: u,
                      esSeleccionado: esActivo,
                      cantidadSesiones: sesiones,
                      onTap: () => onSeleccionarUsuario(u),
                      onDelete: () => onEliminarUsuario(u.id),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
