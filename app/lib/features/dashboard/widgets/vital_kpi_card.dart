import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Tarjeta biométrica reutilizable mapeada a partir de los paneles de DashboardView.tsx.
/// Utiliza un borde lateral distintivo de color y tipografía tabular monoespaciada para evitar jittering.
class VitalKpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final Color accentColor;

  // Opciones para visualización dual (ej. SpO2 y Pulsaciones PPG en un mismo sensor)
  final String? secondaryValue;
  final String? secondaryUnit;
  final String? secondaryTitle;

  const VitalKpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.accentColor,
    this.secondaryValue,
    this.secondaryUnit,
    this.secondaryTitle,
  });

  Widget _buildKpiContent({
    required String title,
    required String value,
    required String unit,
    required Color accentColor,
    required double titleFontSize,
    required double valueFontSize,
    required Color borderColor,
  }) {
    final displayTitle = unit.isNotEmpty ? '$title ($unit)' : title;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
          child: Text(
            displayTitle.toUpperCase(),
            textScaler: TextScaler.noScaling,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w700,
              color: accentColor,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(height: 1, color: borderColor.withValues(alpha: 0.3)),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 12.0,
            ),
            child: FittedBox(
              fit: BoxFit
                  .contain, // Escala tanto hacia arriba como hacia abajo para llenar el espacio
              alignment: Alignment.center,
              child: Text(
                value == '-' ? '—' : value,
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  fontSize: valueFontSize,
                  fontWeight: value == '-' ? FontWeight.w400 : FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderColor = isDark ? DarkColors.border : LightColors.border;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmall = constraints.maxWidth < 220;

        final double titleFontSize = isSmall ? 14.0 : 24.0;
        final double valueFontSize = isSmall ? 64.0 : 90.0;

        return Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Row(
              children: [
                // Barra decorativa vertical de acento a la izquierda
                Container(
                  width: 5,
                  height: double.infinity,
                  color: accentColor,
                ),

                // Contenido del KPI
                Expanded(
                  child: secondaryValue != null
                      ? Row(
                          children: [
                            Expanded(
                              child: _buildKpiContent(
                                title: title,
                                value: value,
                                unit: unit,
                                accentColor: accentColor,
                                titleFontSize: titleFontSize,
                                valueFontSize: valueFontSize,
                                borderColor: borderColor,
                              ),
                            ),
                            Container(
                              width: 1,
                              color: borderColor.withValues(alpha: 0.3),
                            ),
                            Expanded(
                              child: _buildKpiContent(
                                title: secondaryTitle ?? '',
                                value: secondaryValue!,
                                unit: secondaryUnit ?? '',
                                accentColor: accentColor,
                                titleFontSize: titleFontSize,
                                valueFontSize: valueFontSize,
                                borderColor: borderColor,
                              ),
                            ),
                          ],
                        )
                      : _buildKpiContent(
                          title: title,
                          value: value,
                          unit: unit,
                          accentColor: accentColor,
                          titleFontSize: titleFontSize,
                          valueFontSize: valueFontSize,
                          borderColor: borderColor,
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
