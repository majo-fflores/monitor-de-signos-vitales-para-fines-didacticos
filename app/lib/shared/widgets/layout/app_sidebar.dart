import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'sidebar_logo.dart';
import 'sidebar_nav.dart';

/// Barra lateral estática para pantallas de tipo Desktop o Tablet
class AppSidebar extends StatelessWidget {
  final VoidCallback? onClose;

  const AppSidebar({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final esOscuro = theme.brightness == Brightness.dark;

    return Container(
      width: 96,
      height: double.infinity,
      decoration: BoxDecoration(
        color: esOscuro ? DarkColors.sidebar : LightColors.sidebar,
        border: Border(
          right: BorderSide(
            color: esOscuro
                ? DarkColors.sidebarBorder
                : LightColors.sidebarBorder,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const SidebarLogo(),
          const SizedBox(height: 32),
          Expanded(child: SidebarNav(onClose: onClose)),
        ],
      ),
    );
  }
}
