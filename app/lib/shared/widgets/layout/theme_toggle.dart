import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../providers/theme_provider.dart';

/// Botón interactivo para alternar el tema visual de la aplicación.
class ThemeToggle extends ConsumerWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final esOscuro = theme.brightness == Brightness.dark;

    return IconButton(
      onPressed: () {
        ref.read(themeNotifierProvider.notifier).alternarTema();
      },
      icon: esOscuro
          ? const Icon(
              LucideIcons.sun,
              color: Colors.amber,
              size: 20,
            )
          : const Icon(
              LucideIcons.moon,
              color: Colors.grey,
              size: 20,
            ),
      style: IconButton.styleFrom(
        minimumSize: const Size(40, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: esOscuro 
                ? Colors.white.withValues(alpha: 0.1) // Reemplazado withOpacity
                : Colors.black.withValues(alpha: 0.1), // Reemplazado withOpacity
          ),
        ),
      ),
      tooltip: esOscuro ? 'Cambiar a Modo Claro' : 'Cambiar a Modo Oscuro',
    );
  }
}
