import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';

/// Renderiza el isotipo de la aplicación condicionado por el brillo actual del tema.
class SidebarLogo extends StatelessWidget {
  const SidebarLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sidebarColor = theme.brightness == Brightness.dark
        ? DarkColors.sidebar
        : LightColors.sidebar;
    final esOscuroSidebar = sidebarColor.computeLuminance() < 0.5;

    return SizedBox(
      width: 56,
      height: 56,
      child: SvgPicture.asset(
        esOscuroSidebar
            ? 'assets/svg/isotipo-dark.svg'
            : 'assets/svg/isotipo-light.svg',
        fit: BoxFit.contain,
      ),
    );
  }
}
