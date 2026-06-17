import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/models/measurement.dart';
import '../../core/models/ws_packet.dart';
import 'alarma_state.dart';

part 'vital_signs_provider.g.dart';

/// Punto de datos para las series de fl_chart.
@immutable
class PuntoBiometrico {
  final double x;
  final double y;

  const PuntoBiometrico(this.x, this.y);
}

/// Estado inmutable de signos vitales.
@immutable
class EstadoSignosVitales {
  final List<PuntoBiometrico> ecgDatos;
  final List<PuntoBiometrico> co2Datos;
  final int frecuenciaCardiaca;
  final int nivelCo2;
  final bool ecgActivo;
  final bool co2Activo;

  const EstadoSignosVitales({
    required this.ecgDatos,
    required this.co2Datos,
    required this.frecuenciaCardiaca,
    required this.nivelCo2,
    required this.ecgActivo,
    required this.co2Activo,
  });

  factory EstadoSignosVitales.inicial() {
    return const EstadoSignosVitales(
      ecgDatos: [],
      co2Datos: [],
      frecuenciaCardiaca: 72,
      nivelCo2: 35,
      ecgActivo: true,
      co2Activo: true,
    );
  }

  EstadoSignosVitales copiarCon({
    List<PuntoBiometrico>? ecgDatos,
    List<PuntoBiometrico>? co2Datos,
    int? frecuenciaCardiaca,
    int? nivelCo2,
    bool? ecgActivo,
    bool? co2Activo,
  }) {
    return EstadoSignosVitales(
      ecgDatos: ecgDatos ?? this.ecgDatos,
      co2Datos: co2Datos ?? this.co2Datos,
      frecuenciaCardiaca: frecuenciaCardiaca ?? this.frecuenciaCardiaca,
      nivelCo2: nivelCo2 ?? this.nivelCo2,
      ecgActivo: ecgActivo ?? ((this.ecgActivo as dynamic) ?? true),
      co2Activo: co2Activo ?? ((this.co2Activo as dynamic) ?? true),
    );
  }
}

/// Notifier reactivo para signos vitales de alto rendimiento.
///
/// Características STR avanzadas:
/// - Throttling adaptativo a nivel de frame sincronizado con SchedulerBinding.
/// - Reducción de jank y micro-allocations de memoria.
@Riverpod(keepAlive: true)
class NotificadorSignosVitales extends _$NotificadorSignosVitales {
  Timer? _silenceTimer;
  Timer? _timerSimulacion;
  int _simIndex = 0;
  bool _estaActivo = false;
  int _lastEcgWindowIndex = 0;
  int _lastCo2WindowIndex = 0;
  final math.Random _random = math.Random();

  bool _isBuffering = false;
  final List<Sample> _ecgBuffer = [];
  final List<Sample> _bpmBuffer = [];
  final List<Sample> _airBuffer = [];

  void startBuffering() {
    _ecgBuffer.clear();
    _bpmBuffer.clear();
    _airBuffer.clear();
    _isBuffering = true;
  }

  Map<String, List<Sample>> stopBuffering() {
    _isBuffering = false;
    return {
      'ecg': List<Sample>.from(_ecgBuffer),
      'bpm': List<Sample>.from(_bpmBuffer),
      'air': List<Sample>.from(_airBuffer),
    };
  }

  DateTime? _lastEcgTime;
  DateTime? _lastCo2Time;

  StreamSubscription<WsPacket>? _suscripcionWs;
  List<WsPacket> _pendingPackets = [];
  bool _hasFrameCallbackPending = false;
  double? _startTimeMs;

  @override
  EstadoSignosVitales build() {
    _estaActivo = true;
    ref.onDispose(() {
      _detenerTodo();
    });
    return EstadoSignosVitales.inicial();
  }

  /// Inicializa la ventana de datos con puntos vacíos.
  void _inicializarVentana() {
    _lastEcgWindowIndex = -1;
    _lastCo2WindowIndex = -1;

    state = state.copiarCon(ecgDatos: [], co2Datos: []);
  }

  /// Detiene cualquier fuente de datos activa de forma limpia.
  void _detenerTodo() {
    _estaActivo = false;
    _silenceTimer?.cancel();
    _silenceTimer = null;
    _timerSimulacion?.cancel();
    _timerSimulacion = null;
    _suscripcionWs?.cancel();
    _suscripcionWs = null;
    _pendingPackets = [];
    _hasFrameCallbackPending = false;
    _lastEcgTime = null;
    _lastCo2Time = null;
    _startTimeMs = null;
  }

  /// Inicia la simulación local de signos vitales para pruebas.
  void iniciarSimulacion() {
    _detenerTodo();
    _estaActivo = true;
    _inicializarVentana();

    state = state.copiarCon(ecgActivo: true, co2Activo: true);

    const ecgTemplate = [
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.05,
      0.1,
      0.05,
      0.0,
      0.0,
      -0.05,
      0.8,
      -0.2,
      0.0,
      0.05,
      0.1,
      0.15,
      0.2,
      0.15,
      0.1,
      0.05,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
    ];

    _timerSimulacion = Timer.periodic(const Duration(milliseconds: 20), (
      timer,
    ) {
      if (!_estaActivo) {
        timer.cancel();
        return;
      }

      final ahora = DateTime.now().millisecondsSinceEpoch.toDouble();
      final nuevosEcg = List<PuntoBiometrico>.of(state.ecgDatos);
      final nuevosCo2 = List<PuntoBiometrico>.of(state.co2Datos);

      final currentPacketWindow = (ahora / 5000).floor();
      if (currentPacketWindow > _lastEcgWindowIndex) {
        _lastEcgWindowIndex = currentPacketWindow;
        nuevosEcg.clear();
      }

      double rawEcg = ecgTemplate[_simIndex % ecgTemplate.length];
      double valEcg = -10.0 + rawEcg * 90.0;
      nuevosEcg.add(PuntoBiometrico(ahora, valEcg));
      if (nuevosEcg.length > 1000) nuevosEcg.removeAt(0);

      double base = 1150.0 + math.Random().nextDouble() * 100.0;
      double cycle = (ahora / 1000.0) % 4.0;
      double valCo2 = base;
      if (cycle > 2.5) {
        double dropProgress = math.sin((cycle - 2.5) / 1.5 * math.pi);
        valCo2 = base - (dropProgress * 250.0);
      }
      final currentCo2Window = (ahora / 15000).floor();
      if (currentCo2Window > _lastCo2WindowIndex) {
        _lastCo2WindowIndex = currentCo2Window;
        nuevosCo2.clear();
      }
      nuevosCo2.add(PuntoBiometrico(ahora, valCo2));

      if (_isBuffering) {
        _ecgBuffer.add(Sample(timestamp: ahora.toInt(), value: valEcg));
        _airBuffer.add(Sample(timestamp: ahora.toInt(), value: valCo2));
      }

      _simIndex++;

      if (_simIndex % 50 == 0) {
        final fc = 72 + _random.nextInt(5) - 2;
        final co2 = 380 + _random.nextInt(40) - 20;

        if (_isBuffering) {
          _bpmBuffer.add(
            Sample(timestamp: ahora.toInt(), value: fc.toDouble()),
          );
        }

        state = state.copiarCon(
          ecgDatos: nuevosEcg,
          co2Datos: nuevosCo2,
          frecuenciaCardiaca: fc,
          nivelCo2: co2,
        );

        ref
            .read(notificadorAlarmaProvider.notifier)
            .monitorearValores(fc: fc, co2: co2);
      } else {
        state = state.copiarCon(ecgDatos: nuevosEcg, co2Datos: nuevosCo2);
      }
    });
  }

  void iniciarConWebSocket(Stream<WsPacket> stream) {
    _detenerTodo();
    _estaActivo = true;
    _inicializarVentana();

    state = state.copiarCon(ecgActivo: false, co2Activo: false);

    _suscripcionWs = stream.listen((packet) {
      if (!_estaActivo) return;

      final pType = packet.type.trim().toLowerCase();
      if (pType == 'ecg' || pType == 'bpm') {
        _lastEcgTime = DateTime.now();
      } else if (pType == 'co2' ||
          pType == 'air' ||
          pType == 'mq' ||
          pType == 'mq135' ||
          pType == 'gas') {
        _lastCo2Time = DateTime.now();
      }

      _pendingPackets.add(packet);

      if (!_hasFrameCallbackPending) {
        _hasFrameCallbackPending = true;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _flushPendingPackets();
        });
      }
    });

    _silenceTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_estaActivo) {
        timer.cancel();
        return;
      }

      final ahora = DateTime.now();
      final limite = const Duration(seconds: 3);

      final ecgOk =
          _lastEcgTime != null && ahora.difference(_lastEcgTime!) < limite;
      final co2Ok =
          _lastCo2Time != null && ahora.difference(_lastCo2Time!) < limite;

      if (ecgOk != state.ecgActivo || co2Ok != state.co2Activo) {
        state = state.copiarCon(
          ecgActivo: ecgOk,
          co2Activo: co2Ok,
          ecgDatos: ecgOk ? null : [],
          co2Datos: co2Ok ? null : [],
          frecuenciaCardiaca: ecgOk ? null : 0,
          nivelCo2: co2Ok ? null : 0,
        );
      }
    });
  }

  void _flushPendingPackets() {
    _hasFrameCallbackPending = false;
    if (!_estaActivo || _pendingPackets.isEmpty) return;

    final batch = _pendingPackets;
    _pendingPackets = [];

    final nuevosEcg = List<PuntoBiometrico>.of(state.ecgDatos);
    final nuevosCo2 = List<PuntoBiometrico>.of(state.co2Datos);
    int fc = state.frecuenciaCardiaca;
    int co2Nivel = state.nivelCo2;
    bool ecgActivo = state.ecgActivo;
    bool co2Activo = state.co2Activo;

    for (final packet in batch) {
      final pType = packet.type.trim().toLowerCase();
      double valor = packet.value;
      if (pType == 'ecg' && valor <= 3.0) {
        valor = -10.0 + (valor - 0.2) * 90.0;
      }

      _startTimeMs ??= packet.timestamp.toDouble();
      final normalizedTime = packet.timestamp.toDouble() - _startTimeMs!;
      final punto = PuntoBiometrico(normalizedTime, valor);

      if (_isBuffering) {
        final sample = Sample(timestamp: packet.timestamp, value: packet.value);
        if (pType == 'ecg') {
          _ecgBuffer.add(sample);
        } else if (pType == 'bpm') {
          _bpmBuffer.add(sample);
        } else {
          _airBuffer.add(sample);
        }
      }

      switch (pType) {
        case 'ecg':
          final currentPacketWindow = (normalizedTime / 5000).floor();
          if (currentPacketWindow > _lastEcgWindowIndex) {
            _lastEcgWindowIndex = currentPacketWindow;
            nuevosEcg.clear();
          }
          nuevosEcg.add(punto);
          if (nuevosEcg.length > 1000) nuevosEcg.removeAt(0);
          ecgActivo = true;
          break;
        case 'bpm':
          fc = packet.value.round();
          ecgActivo = true;
          break;
        case 'air':
        case 'co2':
        case 'mq':
        case 'mq135':
        case 'gas':
          final currentCo2Window = (normalizedTime / 15000).floor();
          if (currentCo2Window > _lastCo2WindowIndex) {
            _lastCo2WindowIndex = currentCo2Window;
            nuevosCo2.clear();
          }
          nuevosCo2.add(punto);
          co2Nivel = packet.value.round().clamp(300, 1500);
          co2Activo = true;
          break;
      }
    }

    try {
      if (!_estaActivo) return;

      state = state.copiarCon(
        ecgDatos: nuevosEcg,
        co2Datos: nuevosCo2,
        frecuenciaCardiaca: fc,
        nivelCo2: co2Nivel,
        ecgActivo: ecgActivo,
        co2Activo: co2Activo,
      );

      ref
          .read(notificadorAlarmaProvider.notifier)
          .monitorearValores(fc: fc, co2: co2Nivel);
    } catch (e) {
      debugPrint('[VitalSigns] Error en Scheduler Flush: $e');
    }
  }
}
