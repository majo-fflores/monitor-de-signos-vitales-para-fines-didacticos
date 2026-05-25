import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Configuración de ThemeData para Light y Dark theme
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        surface: ColoresClaros.background,
        onSurface: ColoresClaros.foreground,
        primary: ColoresClaros.primary,
        onPrimary: ColoresClaros.primaryForeground,
        secondary: ColoresClaros.secondary,
        onSecondary: ColoresClaros.secondaryForeground,
        error: ColoresClaros.destructive,
        onError: ColoresClaros.destructiveForeground,
        outline: ColoresClaros.border,
      ),
      scaffoldBackgroundColor: ColoresClaros.background,
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          bodyLarge: TextStyle(color: ColoresClaros.foreground),
          bodyMedium: TextStyle(color: ColoresClaros.foreground),
        ),
      ),
      cardTheme: CardThemeData(
        color: ColoresClaros.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: ColoresClaros.border),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: ColoresClaros.border,
        thickness: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        surface: ColoresOscuros.background,
        onSurface: ColoresOscuros.foreground,
        primary: ColoresOscuros.primary,
        onPrimary: ColoresOscuros.primaryForeground,
        secondary: ColoresOscuros.secondary,
        onSecondary: ColoresOscuros.secondaryForeground,
        error: ColoresOscuros.destructive,
        onError: ColoresOscuros.destructiveForeground,
        outline: ColoresOscuros.border,
      ),
      scaffoldBackgroundColor: ColoresOscuros.background,
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          bodyLarge: TextStyle(color: ColoresOscuros.foreground),
          bodyMedium: TextStyle(color: ColoresOscuros.foreground),
        ),
      ),
      cardTheme: CardThemeData(
        color: ColoresOscuros.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: ColoresOscuros.border),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: ColoresOscuros.border,
        thickness: 1,
      ),
    );
  }
}
