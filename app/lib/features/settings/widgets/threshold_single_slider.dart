import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ThresholdSingleSlider extends StatefulWidget {
  final String title;
  final String unit;
  final IconData icon;
  final Color accentColor;
  final double min;
  final double max;
  final double initialValue;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  const ThresholdSingleSlider({
    super.key,
    required this.title,
    required this.unit,
    required this.icon,
    required this.accentColor,
    required this.min,
    required this.max,
    required this.initialValue,
    required this.onChanged,
    required this.onChangeEnd,
  });

  @override
  State<ThresholdSingleSlider> createState() => _ThresholdSingleSliderState();
}

class _ThresholdSingleSliderState extends State<ThresholdSingleSlider> {
  double? _localValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentValue = _localValue ?? widget.initialValue;

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
              '${currentValue.round()} ${widget.unit}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: widget.accentColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const Gap(8),
        Slider(
          value: currentValue,
          min: widget.min,
          max: widget.max,
          activeColor: widget.accentColor,
          inactiveColor: widget.accentColor.withValues(alpha: 0.2),
          label: '${currentValue.round()}',
          onChanged: (val) {
            setState(() {
              _localValue = val;
            });
            widget.onChanged(val);
          },
          onChangeEnd: widget.onChangeEnd,
        ),
      ],
    );
  }
}
