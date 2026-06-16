import 'package:flutter/material.dart';

class AnimatedAlarmBanner extends StatefulWidget {
  final bool visible;
  final Widget child;

  const AnimatedAlarmBanner({
    super.key,
    required this.visible,
    required this.child,
  });

  @override
  State<AnimatedAlarmBanner> createState() => _AnimatedAlarmBannerState();
}

class _AnimatedAlarmBannerState extends State<AnimatedAlarmBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        setState(() {});
      }
    });
    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeInOut));
    if (widget.visible) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedAlarmBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != oldWidget.visible) {
      if (widget.visible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible && _controller.isDismissed) {
      return const SizedBox.shrink();
    }

    return SizeTransition(
      sizeFactor: _heightFactor,
      alignment: Alignment.topCenter,
      child: FadeTransition(opacity: _heightFactor, child: widget.child),
    );
  }
}
