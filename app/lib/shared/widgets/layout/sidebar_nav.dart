import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ElementoNav {
  final IconData icono;
  final String etiqueta;
  final String ruta;

  const ElementoNav({
    required this.icono,
    required this.etiqueta,
    required this.ruta,
  });
}

/// Menú de navegación lateral mapeado de SidebarNav.tsx.
/// Resalta de manera reactiva la ruta activa usando GoRouter.
class SidebarNav extends StatelessWidget {
  final VoidCallback? onClose;

  const SidebarNav({super.key, this.onClose});

  static const List<ElementoNav> _items = [
    ElementoNav(icono: LucideIcons.layoutDashboard, etiqueta: 'Dashboard', ruta: '/'),
    ElementoNav(icono: LucideIcons.history, etiqueta: 'Historial', ruta: '/historial'),
    ElementoNav(icono: LucideIcons.clipboardList, etiqueta: 'Sesiones', ruta: '/sesiones'),
    ElementoNav(icono: LucideIcons.bell, etiqueta: 'Alertas', ruta: '/alertas'),
    ElementoNav(icono: LucideIcons.settings, etiqueta: 'Configuración', ruta: '/configuracion'),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final theme = Theme.of(context);
    final esOscuro = theme.brightness == Brightness.dark;

    return Column(
      children: _items.map((item) {
        final esActivo = location == item.ruta;

        // Estilos equivalentes a los condicionales de Tailwind en SidebarNav.tsx
        final colorIcono = esActivo
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withValues(alpha: 0.4); // Reemplazado withOpacity

        final colorFondo = esActivo
            ? (esOscuro 
                ? theme.colorScheme.primary.withValues(alpha: 0.15) // Reemplazado withOpacity
                : theme.colorScheme.primary.withValues(alpha: 0.08)) // Reemplazado withOpacity
            : Colors.transparent;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Tooltip(
            message: item.etiqueta,
            child: InkWell(
              onTap: () {
                context.go(item.ruta);
                if (onClose != null) onClose!();
              },
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorFondo,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: esActivo && !esOscuro
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00D4FF).withValues(alpha: 0.15), // Reemplazado withOpacity
                            blurRadius: 20,
                            offset: const Offset(0, 0),
                          )
                        ]
                      : null,
                ),
                child: Icon(
                  item.icono,
                  color: colorIcono,
                  size: 20,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
