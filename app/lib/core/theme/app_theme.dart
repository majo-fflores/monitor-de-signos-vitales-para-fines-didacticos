import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Configuración de ThemeData para Light y Dark theme cached as final fields to avoid overhead.
class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      surface: LightColors.background,
      onSurface: LightColors.foreground,
      primary: LightColors.primary,
      onPrimary: LightColors.primaryForeground,
      secondary: LightColors.secondary,
      onSecondary: LightColors.secondaryForeground,
      error: LightColors.destructive,
      onError: LightColors.destructiveForeground,
      outline: LightColors.border,
    ),
    scaffoldBackgroundColor: LightColors.background,
    textTheme: GoogleFonts.interTextTheme(
      const TextTheme(
        bodyLarge: TextStyle(color: LightColors.foreground),
        bodyMedium: TextStyle(color: LightColors.foreground),
      ),
    ),
    cardTheme: CardThemeData(
      color: LightColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: LightColors.border),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: LightColors.border,
      thickness: 1,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      surface: DarkColors.background,
      onSurface: DarkColors.foreground,
      primary: DarkColors.primary,
      onPrimary: DarkColors.primaryForeground,
      secondary: DarkColors.secondary,
      onSecondary: DarkColors.secondaryForeground,
      error: DarkColors.destructive,
      onError: DarkColors.destructiveForeground,
      outline: DarkColors.border,
    ),
    scaffoldBackgroundColor: DarkColors.background,
    textTheme: GoogleFonts.interTextTheme(
      const TextTheme(
        bodyLarge: TextStyle(color: DarkColors.foreground),
        bodyMedium: TextStyle(color: DarkColors.foreground),
      ),
    ),
    cardTheme: CardThemeData(
      color: DarkColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: DarkColors.border),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: DarkColors.border,
      thickness: 1,
    ),
  );
}
