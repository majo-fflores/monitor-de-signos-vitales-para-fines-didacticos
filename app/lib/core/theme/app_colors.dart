import 'package:flutter/material.dart';

/// Colores de tema claro (mapeados de variables CSS en `:root` de index.css)
class ColoresClaros {
  static const background = Color(0xFFFFFFFF);
  static const foreground = Color(0xFF1E1E24); // oklch(0.145 0 0)
  static const card = Color(0xFFFFFFFF);
  static const cardForeground = Color(0xFF1E1E24);
  static const primary = Color(0xFF030213);
  static const primaryForeground = Color(0xFFFFFFFF);
  static const secondary = Color(0xFFF2F2F5); // oklch(0.95 0.0058 264.53)
  static const secondaryForeground = Color(0xFF030213);
  static const muted = Color(0xFFECECF0);
  static const mutedForeground = Color(0xFF717182);
  static const accent = Color(0xFFE9EBEF);
  static const accentForeground = Color(0xFF030213);
  static const destructive = Color(0xFFD4183D);
  static const destructiveForeground = Color(0xFFFFFFFF);
  static const border = Color(0x1A000000); // rgba(0, 0, 0, 0.1)
  
  static const sidebar = Color(0xFFFCFCFC); // oklch(0.985 0 0)
  static const sidebarForeground = Color(0xFF1E1E24);
  static const sidebarPrimary = Color(0xFF030213);
  static const sidebarPrimaryForeground = Color(0xFFFCFCFC);
  static const sidebarAccent = Color(0xFFF7F7F7); // oklch(0.97 0 0)
  static const sidebarAccentForeground = Color(0xFF2D2D2D); // oklch(0.205 0 0)
  static const sidebarBorder = Color(0xFFECECF0); // oklch(0.922 0 0)
}

/// Colores de tema oscuro (mapeados de variables CSS en `.dark` de index.css)
class ColoresOscuros {
  static const background = Color(0xFF1E1E24); // oklch(0.145 0 0)
  static const foreground = Color(0xFFFCFCFC); // oklch(0.985 0 0)
  static const card = Color(0xFF1E1E24);
  static const cardForeground = Color(0xFFFCFCFC);
  static const primary = Color(0xFFFCFCFC);
  static const primaryForeground = Color(0xFF2D2D2D); // oklch(0.205 0 0)
  static const secondary = Color(0xFF333333); // oklch(0.269 0 0)
  static const secondaryForeground = Color(0xFFFCFCFC);
  static const muted = Color(0xFF333333);
  static const mutedForeground = Color(0xFFB5B5B5); // oklch(0.708 0 0)
  static const accent = Color(0xFF333333);
  static const accentForeground = Color(0xFFFCFCFC);
  static const destructive = Color(0xFFD4183D);
  static const destructiveForeground = Color(0xFFFCFCFC);
  static const border = Color(0xFF333333);
  
  static const sidebar = Color(0xFF2D2D2D); // oklch(0.205 0 0)
  static const sidebarForeground = Color(0xFFFCFCFC);
  static const sidebarPrimary = Color(0xFF4A90E2); // oklch(0.488 0.243 264.376)
  static const sidebarPrimaryForeground = Color(0xFFFCFCFC);
  static const sidebarAccent = Color(0xFF333333);
  static const sidebarAccentForeground = Color(0xFFFCFCFC);
  static const sidebarBorder = Color(0xFF333333);
}

/// Colores específicos de biosensores y visualización (ECG, SpO2, CO2, etc.)
class ColoresSensores {
  static const ecgVerde = Color(0xFF10B981);
  static const spo2Azul = Color(0xFF3B82F6);
  static const co2Amarillo = Color(0xFFEAB308);
  static const statusConectado = Color(0xFF10B981);
}
