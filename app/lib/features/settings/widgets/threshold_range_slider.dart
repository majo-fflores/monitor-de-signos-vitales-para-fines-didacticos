import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../shared/providers/alarma_state.dart';

class ThresholdRangeSlider extends ConsumerStatefulWidget {
  final String titulo;
  final String unidad;
  final IconData icono;
  final Color colorAcento;
  final double min;
  final double max;

  const ThresholdRangeSlider({
    super.key,
    required this.titulo,
    required this.unidad,
    required this.icono,
    required this.colorAcento,
    required this.min,
    required this.max,
  });

  @override
  ConsumerState<ThresholdRangeSlider> createState() =>
      _ThresholdRangeSliderState();
}

class _ThresholdRangeSliderState extends ConsumerState<ThresholdRangeSlider> {
  RangeValues? _rangoLocal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Obtenemos los valores iniciales del provider si no han sido cargados localmente
    final umbrales = ref.read(
      notificadorAlarmaProvider.select((s) => s.umbrales),
    );
    final rangoActual =
        _rangoLocal ??
        RangeValues(umbrales.fcMin.toDouble(), umbrales.fcMax.toDouble());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(widget.icono, color: widget.colorAcento, size: 20),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      widget.titulo,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(16),
            Text(
              '${rangoActual.start.round()} - ${rangoActual.end.round()} ${widget.unidad}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: widget.colorAcento,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const Gap(8),
        RangeSlider(
          values: rangoActual,
          min: widget.min,
          max: widget.max,
          activeColor: widget.colorAcento,
          inactiveColor: widget.colorAcento.withValues(alpha: 0.2),
          labels: RangeLabels(
            '${rangoActual.start.round()}',
            '${rangoActual.end.round()}',
          ),
          onChanged: (values) {
            setState(() {
              _rangoLocal = values;
            });
            ref
                .read(notificadorAlarmaProvider.notifier)
                .actualizarUmbralesMemoria(
                  fcMin: values.start.round(),
                  fcMax: values.end.round(),
                );
          },
          onChangeEnd: (_) {
            ref
                .read(notificadorAlarmaProvider.notifier)
                .guardarUmbralesEnDisco();
          },
        ),
      ],
    );
  }
}
