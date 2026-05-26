import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ThresholdSingleSlider extends StatefulWidget {
  final String titulo;
  final String unidad;
  final IconData icono;
  final Color colorAcento;
  final double min;
  final double max;
  final double valorInicial;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  const ThresholdSingleSlider({
    super.key,
    required this.titulo,
    required this.unidad,
    required this.icono,
    required this.colorAcento,
    required this.min,
    required this.max,
    required this.valorInicial,
    required this.onChanged,
    required this.onChangeEnd,
  });

  @override
  State<ThresholdSingleSlider> createState() => _ThresholdSingleSliderState();
}

class _ThresholdSingleSliderState extends State<ThresholdSingleSlider> {
  double? _valorLocal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final valorActual = _valorLocal ?? widget.valorInicial;

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
                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(16),
            Text(
              '${valorActual.round()} ${widget.unidad}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: widget.colorAcento,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const Gap(8),
        Slider(
          value: valorActual,
          min: widget.min,
          max: widget.max,
          activeColor: widget.colorAcento,
          inactiveColor: widget.colorAcento.withValues(alpha: 0.2),
          label: '${valorActual.round()}',
          onChanged: (val) {
            setState(() {
              _valorLocal = val;
            });
            widget.onChanged(val);
          },
          onChangeEnd: widget.onChangeEnd,
        ),
      ],
    );
  }
}
