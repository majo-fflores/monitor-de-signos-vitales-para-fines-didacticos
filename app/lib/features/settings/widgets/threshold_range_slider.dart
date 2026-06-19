import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../shared/providers/alarm_state.dart';

class ThresholdRangeSlider extends ConsumerStatefulWidget {
  final String title;
  final String unit;
  final IconData icon;
  final Color accentColor;
  final double min;
  final double max;

  const ThresholdRangeSlider({
    super.key,
    required this.title,
    required this.unit,
    required this.icon,
    required this.accentColor,
    required this.min,
    required this.max,
  });

  @override
  ConsumerState<ThresholdRangeSlider> createState() =>
      _ThresholdRangeSliderState();
}

class _ThresholdRangeSliderState extends ConsumerState<ThresholdRangeSlider> {
  RangeValues? _localRange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Obtenemos los valores iniciales del provider si no han sido cargados localmente
    final thresholds = ref.read(
      alarmNotifierProvider.select((s) => s.thresholds),
    );
    final currentRange =
        _localRange ??
        RangeValues(thresholds.bpmMin.toDouble(), thresholds.bpmMax.toDouble());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(widget.icon, color: widget.accentColor, size: 20),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      widget.title,
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
              '${currentRange.start.round()} - ${currentRange.end.round()} ${widget.unit}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: widget.accentColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const Gap(8),
        RangeSlider(
          values: currentRange,
          min: widget.min,
          max: widget.max,
          activeColor: widget.accentColor,
          inactiveColor: widget.accentColor.withValues(alpha: 0.2),
          labels: RangeLabels(
            '${currentRange.start.round()}',
            '${currentRange.end.round()}',
          ),
          onChanged: (values) {
            setState(() {
              _localRange = values;
            });
            ref
                .read(alarmNotifierProvider.notifier)
                .updateThresholdsInMemory(
                  bpmMin: values.start.round(),
                  bpmMax: values.end.round(),
                );
          },
          onChangeEnd: (_) {
            ref.read(alarmNotifierProvider.notifier).saveThresholdsToDisk();
          },
        ),
      ],
    );
  }
}
