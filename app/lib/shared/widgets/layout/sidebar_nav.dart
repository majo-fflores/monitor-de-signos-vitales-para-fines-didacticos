import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';

class NavItem {
  final IconData icon;
  final String label;
  final String path;

  const NavItem({required this.icon, required this.label, required this.path});
}

/// Menú de navegación lateral mapeado de SidebarNav.tsx.
/// Resalta de manera reactiva la ruta activa usando GoRouter.
class SidebarNav extends StatelessWidget {
  final VoidCallback? onClose;

  const SidebarNav({super.key, this.onClose});

  static const List<NavItem> _items = [
    NavItem(icon: LucideIcons.layoutDashboard, label: 'Dashboard', path: '/'),
    NavItem(
      icon: LucideIcons.clipboardList,
      label: 'Sesiones',
      path: '/sessions',
    ),
    NavItem(icon: LucideIcons.history, label: 'Reportes', path: '/history'),
    NavItem(icon: LucideIcons.bellRing, label: 'Alertas', path: '/alerts'),
    NavItem(
      icon: LucideIcons.settings,
      label: 'Configuración',
      path: '/settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: _items.map((item) {
        final isActive = location == item.path;

        // Estilos equivalentes a los condicionales de Tailwind en SidebarNav.tsx
        final iconColor = isActive
            ? (isDark ? DarkColors.sidebarPrimary : LightColors.sidebarPrimary)
            : (isDark
                      ? DarkColors.sidebarForeground
                      : LightColors.sidebarForeground)
                  .withValues(alpha: 0.4);

        final bgColor = isActive
            ? (isDark
                  ? DarkColors.sidebarPrimary.withValues(alpha: 0.15)
                  : LightColors.sidebarPrimary.withValues(alpha: 0.15))
            : Colors.transparent;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Tooltip(
            message: item.label,
            child: InkWell(
              onTap: () {
                context.go(item.path);
                if (onClose != null) onClose!();
              },
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isActive && !isDark
                      ? [
                          BoxShadow(
                            color: ComponentColors.sidebarShadowGlow.withValues(
                              alpha: 0.15,
                            ), // Reemplazado withOpacity
                            blurRadius: 20,
                            offset: const Offset(0, 0),
                          ),
                        ]
                      : null,
                ),
                child: Icon(item.icon, color: iconColor, size: 20),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
