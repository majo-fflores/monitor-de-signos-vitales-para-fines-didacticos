import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Tarjeta biométrica reutilizable mapeada a partir de los paneles de DashboardView.tsx.
/// Utiliza un borde lateral distintivo de color y tipografía tabular monoespaciada para evitar jittering.
class TarjetaKpiVital extends StatelessWidget {
  final String titulo;
  final String valor;
  final String unidad;
  final Color colorAcento;

  // Opciones para visualización dual (ej. SpO2 y Pulsaciones PPG en un mismo sensor)
  final String? valorSecundario;
  final String? unidadSecundaria;
  final String? tituloSecundario;

  const TarjetaKpiVital({
    super.key,
    required this.titulo,
    required this.valor,
    required this.unidad,
    required this.colorAcento,
    this.valorSecundario,
    this.unidadSecundaria,
    this.tituloSecundario,
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
    final esOscuro = theme.brightness == Brightness.dark;

    final borderColor = esOscuro ? ColoresOscuros.border : ColoresClaros.border;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool esPequeno = constraints.maxWidth < 220;

        final double titleFontSize = esPequeno ? 12.0 : 16.0;
        final double valueFontSize = esPequeno ? 72.0 : 120.0;

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
                  color: colorAcento,
                ),

                // Contenido del KPI
                Expanded(
                  child: valorSecundario != null
                      ? Row(
                          children: [
                            Expanded(
                              child: _buildKpiContent(
                                title: titulo,
                                value: valor,
                                unit: unidad,
                                accentColor: colorAcento,
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
                                title: tituloSecundario ?? '',
                                value: valorSecundario!,
                                unit: unidadSecundaria ?? '',
                                accentColor: colorAcento,
                                titleFontSize: titleFontSize,
                                valueFontSize: valueFontSize,
                                borderColor: borderColor,
                              ),
                            ),
                          ],
                        )
                      : _buildKpiContent(
                          title: titulo,
                          value: valor,
                          unit: unidad,
                          accentColor: colorAcento,
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
