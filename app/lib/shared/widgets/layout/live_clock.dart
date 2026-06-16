import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Reloj y fecha en vivo actualizados cada segundo.
/// Idioma y formateo nativo en español para paridad visual.
class LiveClock extends StatefulWidget {
  const LiveClock({super.key});

  @override
  State<LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<LiveClock> {
  late DateTime _ahora;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _ahora = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _ahora = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Traducción y formateo simple a español para evitar dependencias intl pesadas
  String get _fechaFormateada {
    final dias = ['dom', 'lun', 'mar', 'mié', 'jue', 'vie', 'sáb'];
    final meses = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    final diaSem = dias[_ahora.weekday % 7];
    final mes = meses[_ahora.month - 1];
    return '$diaSem, ${_ahora.day} $mes ${_ahora.year}';
  }

  String get _horaFormateada {
    final hh = _ahora.hour.toString().padLeft(2, '0');
    final mm = _ahora.minute.toString().padLeft(2, '0');
    final ss = _ahora.second.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _fechaFormateada,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600, // Reemplazado semibold por w600
            color: isDark
                ? ColoresOscuros.foreground
                : ColoresClaros.foreground,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _horaFormateada,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            color: isDark
                ? ColoresOscuros.mutedForeground
                : ColoresClaros.mutedForeground,
          ),
        ),
      ],
    );
  }
}
