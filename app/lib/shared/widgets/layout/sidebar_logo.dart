import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renderiza el isotipo de la aplicación condicionado por el brillo actual del tema.
class SidebarLogo extends StatelessWidget {
  const SidebarLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final brillo = Theme.of(context).brightness;
    final esOscuro = brillo == Brightness.dark;

    return SizedBox(
      width: 56,
      height: 56,
      child: SvgPicture.asset(
        esOscuro 
            ? 'assets/svg/isotipo-dark.svg' 
            : 'assets/svg/isotipo-light.svg',
        fit: BoxFit.contain,
      ),
    );
  }
}
