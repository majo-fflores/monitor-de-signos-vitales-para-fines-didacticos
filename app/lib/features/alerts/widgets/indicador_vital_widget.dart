import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/alarma_state.dart';
import '../../../shared/providers/vital_signs_provider.dart';

/// Tipos de métrica soportados por el indicador.
enum TipoMetrica { frecuenciaCardiaca, dioxidoCarbono }

/// Widget aislado para una sola métrica vital.
/// Cada instancia hace su propio `ref.watch` selectivo para evitar
/// rebuilds innecesarios cuando cambia otra métrica.
class IndicadorVitalWidget extends ConsumerWidget {
  final TipoMetrica tipo;

  const IndicadorVitalWidget({super.key, required this.tipo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final umbrales = ref.watch(
      notificadorAlarmaProvider.select((s) => s.umbrales),
    );

    // Cada tipo solo observa su propio dato
    late final int valor;
    late final bool activo;
    late final String metrica;
    late final String valorFormateado;
    late final IconData icono;
    late final Color colorBase;
    late final bool fueraDeRango;

    switch (tipo) {
      case TipoMetrica.frecuenciaCardiaca:
        valor = ref.watch(
          notificadorSignosVitalesProvider.select((s) => s.frecuenciaCardiaca),
        );
        activo = ref.watch(
          notificadorSignosVitalesProvider.select((s) => s.ecgActivo),
        );
        metrica = 'Frecuencia Cardíaca';
        valorFormateado = valor == 0 ? '-' : '$valor BPM';
        icono = LucideIcons.heart;
        colorBase = ColoresSensores.ecgVerde;
        fueraDeRango =
            (valor != 0 &&
                (valor < umbrales.fcMin || valor > umbrales.fcMax)) &&
            activo;
      case TipoMetrica.dioxidoCarbono:
        valor = ref.watch(
          notificadorSignosVitalesProvider.select((s) => s.nivelCo2),
        );
        activo = ref.watch(
          notificadorSignosVitalesProvider.select((s) => s.co2Activo),
        );
        metrica = 'Dióxido de Carbono';
        valorFormateado = valor == 0 ? '-' : '$valor ppm';
        icono = LucideIcons.wind;
        colorBase = ColoresSensores.co2Amarillo;
        fueraDeRango = (valor != 0 && (valor > umbrales.co2Max)) && activo;
    }

    final color = fueraDeRango ? theme.colorScheme.error : colorBase;

    final esOscuro = theme.brightness == Brightness.dark;

    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: fueraDeRango
                ? theme.colorScheme.error.withValues(alpha: 0.5)
                : (esOscuro ? ColoresOscuros.border : ColoresClaros.border),
            width: fueraDeRango ? 1.5 : 1.0,
          ),
          boxShadow: fueraDeRango
              ? [
                  BoxShadow(
                    color: theme.colorScheme.error.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icono, color: color, size: 20),
                ),
                const Gap(12),
                Text(
                  metrica,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const Gap(12),
            Container(
              height: 1,
              color: esOscuro ? ColoresOscuros.border : ColoresClaros.border,
            ),
            const Gap(12),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          valorFormateado,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: color,
                            fontFeatures: const [FontFeature.tabularFigures()],
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                  ),
                  VerticalDivider(
                    width: 24,
                    thickness: 1,
                    color: esOscuro
                        ? ColoresOscuros.border
                        : ColoresClaros.border,
                  ),
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          fueraDeRango ? 'CRÍTICO' : 'NORMAL',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: fueraDeRango
                                ? theme.colorScheme.error
                                : ColoresSensores.statusConectado,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
