import 'package:flutter/material.dart';

/// Colores de tema claro (mapeados de variables CSS en `:root` de index.css)
class ColoresClaros {
  static const background = Color(
    0xFFF1F5F9,
  ); // Slate 100 - Cool, clean background for high contrast with white cards
  static const foreground = Color(
    0xFF0F172A,
  ); // Slate 900 - Deep crisp charcoal for reading comfort
  static const card = Color(
    0xFFFFFFFF,
  ); // Pure white cards that stand out on slate background
  static const cardForeground = Color(0xFF1E293B); // Slate 800
  static const primary = Color(0xFF3730A3); // Warm Deep Indigo
  static const primaryForeground = Color(0xFFFFFFFF);
  static const secondary = Color(0xFFE2E8F0); // Slate 200
  static const secondaryForeground = Color(0xFF0F172A);
  static const muted = Color(0xFFE2E8F0); // Slate 200
  static const mutedForeground = Color(0xFF64748B); // Slate 500
  static const accent = Color(0xFFF8FAFC); // Slate 50
  static const accentForeground = Color(0xFF3730A3);
  static const destructive = Color(0xFFDC2626);
  static const destructiveForeground = Color(0xFFFFFFFF);
  static const border = Color(
    0xFFCBD5E1,
  ); // Slate 300 - Clearly defined borders to frame elements cleanly

  static const sidebar = Color(
    0xFFFFFFFF,
  ); // Clean white sidebar contrasting with slate background
  static const sidebarForeground = Color(
    0xFF0F172A,
  ); // Slate 900 for high-contrast text/icons
  static const sidebarPrimary = Color(0xFF3730A3); // Indigo primary
  static const sidebarPrimaryForeground = Color(0xFFFFFFFF);
  static const sidebarAccent = Color(
    0xFFF1F5F9,
  ); // Slate 100 hover/active background
  static const sidebarAccentForeground = Color(0xFF3730A3);
  static const sidebarBorder = Color(0xFFCBD5E1); // Slate 300 border
}

/// Colores de tema oscuro (mapeados de variables CSS en `.dark` de index.css)
class ColoresOscuros {
  static const background = Color(0xFF0F0F12); // Sleek deep space black
  static const foreground = Color(0xFFFCFCFC);
  static const card = Color(0xFF191921);
  static const cardForeground = Color(0xFFFCFCFC);
  static const primary = Color(
    0xFF4F46E5,
  ); // Indigo 600 - High-contrast vibrant clinical indigo (meets WCAG AA contrast)
  static const primaryForeground = Color(0xFFFFFFFF);
  static const secondary = Color(0xFF2E2E38);
  static const secondaryForeground = Color(0xFFFCFCFC);
  static const muted = Color(0xFF2E2E38);
  static const mutedForeground = Color(0xFF94A3B8);
  static const accent = Color(0xFF2E2E38);
  static const accentForeground = Color(0xFFFCFCFC);
  static const destructive = Color(0xFFEF4444);
  static const destructiveForeground = Color(0xFFFFFFFF);
  static const border = Color(0xFF2E2E38);

  static const sidebar = Color(0xFF191921);
  static const sidebarForeground = Color(0xFFFCFCFC);
  static const sidebarPrimary = Color(0xFF6366F1);
  static const sidebarPrimaryForeground = Color(0xFFFFFFFF);
  static const sidebarAccent = Color(0xFF2E2E38);
  static const sidebarAccentForeground = Color(0xFFFCFCFC);
  static const sidebarBorder = Color(0xFF2E2E38);
}

/// Colores específicos de biosensores y visualización (ECG, SpO2, CO2, etc.)
class ColoresSensores {
  static const ecgVerde = Color(0xFF10B981);
  static const spo2Azul = Color(0xFF3B82F6);
  static const co2Amarillo = Color(0xFFEAB308);
  static const statusConectado = Color(0xFF10B981);

  // Alertas por estado (Semáforo clínico)
  static const excelenteOscuro = Color(0xFF00E676); // GreenAccent
  static const excelenteClaro = Color(0xFF16A34A);

  static const moderadoOscuro = Color(0xFFEAB308); // co2Amarillo
  static const moderadoClaro = Color(0xFFD97706);

  static const criticoOscuro = Color(0xFFFF5252); // RedAccent
  static const criticoClaro = Color(0xFFDC2626);
}

/// Colores centralizados para componentes específicos para garantizar cero hardcoding.
class ColoresComponentes {
  // Glow de neón para la navegación activa
  static const sidebarShadowGlow = Color(0xFF00D4FF);

  // Plaqueta informativa de CO2 (Badges)
  static const co2BadgeBgClaro = Color(
    0xFFF0F2FA,
  ); // Soft indigo-blue tint to complement yellow and match primary theme
  static const co2BadgeBgOscuro = Color(0xFF1E1E26);

  // Medidor Gauge Instrumental de CO2
  static const co2GaugeTrackClaro = Color(0xFFE5E7EB);
  static const co2GaugeTrackOscuro = Color(0xFF1E1E26);

  // Fondos de gráficos de ondas y consola
  static const graficoHeaderOscuro = Colors.black;
  static const graficoHeaderClaro = Color(
    0xFFF0F2FA,
  ); // Soft indigo-blue tint to match primary theme
  static const graficoCuerpoOscuro = Color(0xFF0F0F12);
  static const graficoCuerpoClaro = Colors.white;

  // Rejillas de gráficos
  static const graficoRejillaOscuro = Color(0xFF222222);
  static const graficoRejillaClaro = Color(0xFFE5E7EB);

  // Contraste para temas claros de sensores
  static const sensorEcgClaro = Color(0xFF16A34A);
  static const sensorSpo2Claro = Color(0xFF2563EB);

  // Colores para avatares aleatorios de usuarios
  static const avatarColores = [
    Color(0xFF3B82F6), // Azul
    Color(0xFF10B981), // Verde
    Color(0xFFEC4899), // Rosa
    Color(0xFF8B5CF6), // Violeta
    Color(0xFFF59E0B), // Ámbar
    Color(0xFFEF4444), // Rojo
    Color(0xFF06B6D4), // Cian
  ];

  // Bordes específicos de ventanas popup y selectores
  static const popupBorderClaro = Color(0x1A000000);
  static const popupBorderOscuro = Color(0xFF333333);
}
