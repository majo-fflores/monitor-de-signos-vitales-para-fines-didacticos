import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/alarma_state.dart';
import '../../../shared/providers/vital_signs_provider.dart';

/// Tipos de métrica soportados por el indicador.
enum TipoMetrica { frecuenciaCardiaca, frecuenciaPulsoPPG, dioxidoCarbono }

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
    late final String rangoNormal;
    late final IconData icono;
    late final Color colorBase;
    late final bool fueraDeRango;

    switch (tipo) {
      case TipoMetrica.frecuenciaCardiaca:
        valor = ref.watch(notificadorSignosVitalesProvider.select((s) => s.frecuenciaCardiaca));
        activo = ref.watch(notificadorSignosVitalesProvider.select((s) => s.ecgActivo));
        metrica = 'Frecuencia Cardíaca';
        valorFormateado = '$valor BPM';
        rangoNormal = '${umbrales.fcMin} - ${umbrales.fcMax} BPM';
        icono = LucideIcons.heart;
        colorBase = ColoresSensores.ecgVerde;
        fueraDeRango = (valor < umbrales.fcMin || valor > umbrales.fcMax) && activo;
      case TipoMetrica.frecuenciaPulsoPPG:
        valor = ref.watch(notificadorSignosVitalesProvider.select((s) => s.ppgFrecuenciaCardiaca));
        activo = ref.watch(notificadorSignosVitalesProvider.select((s) => s.spo2Activo));
        metrica = 'Frecuencia de Pulso (PPG)';
        valorFormateado = '$valor LPM';
        rangoNormal = '≥ ${umbrales.ppgMin} LPM';
        icono = LucideIcons.activity;
        colorBase = ColoresSensores.spo2Azul;
        fueraDeRango = (valor < umbrales.ppgMin) && activo;
      case TipoMetrica.dioxidoCarbono:
        valor = ref.watch(notificadorSignosVitalesProvider.select((s) => s.nivelCo2));
        activo = ref.watch(notificadorSignosVitalesProvider.select((s) => s.co2Activo));
        metrica = 'Dióxido de Carbono';
        valorFormateado = '$valor ppm';
        rangoNormal = '≤ ${umbrales.co2Max} ppm';
        icono = LucideIcons.cloud;
        colorBase = ColoresSensores.co2Amarillo;
        fueraDeRango = (valor > umbrales.co2Max) && activo;
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
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icono, color: color, size: 20),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metrica,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Umbral Normal: $rangoNormal',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  valorFormateado,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                if (fueraDeRango)
                  Text(
                    'CRÍTICO',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  )
                else
                  Text(
                    'NORMAL',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: ColoresSensores.statusConectado,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
