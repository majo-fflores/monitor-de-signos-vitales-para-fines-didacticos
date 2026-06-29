import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/models/measurement.dart';
import '../../core/models/ws_packet.dart';
import 'alarm_state.dart';

part 'vital_signs_provider.g.dart';

/// Punto de datos para las series de fl_chart.
@immutable
class BiometricPoint {
  final double x;
  final double y;

  const BiometricPoint(this.x, this.y);
}

/// Estado inmutable de signos vitales.
@immutable
class VitalSignsState {
  final List<BiometricPoint> ecgData;
  final List<BiometricPoint> co2Data;
  final int heartRate;
  final int co2Level;
  final bool isEcgActive;
  final bool isCo2Active;

  const VitalSignsState({
    required this.ecgData,
    required this.co2Data,
    required this.heartRate,
    required this.co2Level,
    required this.isEcgActive,
    required this.isCo2Active,
  });

  factory VitalSignsState.inicial() {
    return const VitalSignsState(
      ecgData: [],
      co2Data: [],
      heartRate: 72,
      co2Level: 35,
      isEcgActive: true,
      isCo2Active: true,
    );
  }

  VitalSignsState copiarCon({
    List<BiometricPoint>? ecgData,
    List<BiometricPoint>? co2Data,
    int? heartRate,
    int? co2Level,
    bool? isEcgActive,
    bool? isCo2Active,
  }) {
    return VitalSignsState(
      ecgData: ecgData ?? this.ecgData,
      co2Data: co2Data ?? this.co2Data,
      heartRate: heartRate ?? this.heartRate,
      co2Level: co2Level ?? this.co2Level,
      isEcgActive: isEcgActive ?? this.isEcgActive,
      isCo2Active: isCo2Active ?? this.isCo2Active,
    );
  }
}

/// Notifier reactivo para signos vitales de alto rendimiento.
///
/// Características STR avanzadas:
/// - Throttling adaptativo a nivel de frame sincronizado con SchedulerBinding.
/// - Reducción de jank y micro-allocations de memoria.
@Riverpod(keepAlive: true)
class VitalSignsNotifier extends _$VitalSignsNotifier {
  Timer? _silenceTimer;
  Timer? _simulationTimer;
  int _simIndex = 0;
  bool _isActive = false;
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

  StreamSubscription<WsPacket>? _wsSubscription;
  List<WsPacket> _pendingPackets = [];
  bool _hasFrameCallbackPending = false;
  double? _startTimeMs;

  @override
  VitalSignsState build() {
    _isActive = true;
    ref.onDispose(() {
      _stopAll();
    });
    return VitalSignsState.inicial();
  }

  /// Inicializa la ventana de datos con puntos vacíos.
  void _initializeWindow() {
    _lastEcgWindowIndex = -1;
    _lastCo2WindowIndex = -1;

    state = state.copiarCon(ecgData: [], co2Data: []);
  }

  /// Detiene cualquier fuente de datos activa de forma limpia.
  void _stopAll() {
    _isActive = false;
    _silenceTimer?.cancel();
    _silenceTimer = null;
    _simulationTimer?.cancel();
    _simulationTimer = null;
    _wsSubscription?.cancel();
    _wsSubscription = null;
    _pendingPackets = [];
    _hasFrameCallbackPending = false;
    _lastEcgTime = null;
    _lastCo2Time = null;
    _startTimeMs = null;
  }

  /// Inicia la simulación local de signos vitales para pruebas.
  void startSimulation() {
    _stopAll();
    _isActive = true;
    _initializeWindow();

    state = state.copiarCon(isEcgActive: true, isCo2Active: true);

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

    _simulationTimer = Timer.periodic(const Duration(milliseconds: 20), (
      timer,
    ) {
      if (!_isActive) {
        timer.cancel();
        return;
      }

      final ahora = DateTime.now().millisecondsSinceEpoch.toDouble();
      final nuevosEcg = List<BiometricPoint>.of(state.ecgData);
      final nuevosCo2 = List<BiometricPoint>.of(state.co2Data);

      final currentPacketWindow = (ahora / 5000).floor();
      if (currentPacketWindow > _lastEcgWindowIndex) {
        _lastEcgWindowIndex = currentPacketWindow;
        nuevosEcg.clear();
      }

      double rawEcg = ecgTemplate[_simIndex % ecgTemplate.length];
      double valEcg = -10.0 + rawEcg * 90.0;
      nuevosEcg.add(BiometricPoint(ahora, valEcg));
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
      nuevosCo2.add(BiometricPoint(ahora, valCo2));

      if (_isBuffering) {
        _ecgBuffer.add(
          Sample(timestamp: ahora.toInt(), value: valEcg, alert: false),
        );
        final alarmState = ref.read(alarmNotifierProvider);
        _airBuffer.add(
          Sample(
            timestamp: ahora.toInt(),
            value: valCo2,
            alert: valCo2 > alarmState.thresholds.co2Max,
          ),
        );
      }

      _simIndex++;

      if (_simIndex % 50 == 0) {
        final fc = 72 + _random.nextInt(5) - 2;
        final co2 = 380 + _random.nextInt(40) - 20;

        if (_isBuffering) {
          final alarmState = ref.read(alarmNotifierProvider);
          _bpmBuffer.add(
            Sample(
              timestamp: ahora.toInt(),
              value: fc.toDouble(),
              alert:
                  fc < alarmState.thresholds.bpmMin ||
                  fc > alarmState.thresholds.bpmMax,
            ),
          );
        }

        state = state.copiarCon(
          ecgData: nuevosEcg,
          co2Data: nuevosCo2,
          heartRate: fc,
          co2Level: co2,
        );

        ref
            .read(alarmNotifierProvider.notifier)
            .monitorValues(fc: fc, co2: co2);
      } else {
        state = state.copiarCon(ecgData: nuevosEcg, co2Data: nuevosCo2);
      }
    });
  }

  void startWithWebSocket(Stream<WsPacket> stream) {
    _stopAll();
    _isActive = true;
    _initializeWindow();

    state = state.copiarCon(
      isEcgActive: false,
      isCo2Active: false,
      heartRate: 0,
      co2Level: 0,
    );

    _wsSubscription = stream.listen((packet) {
      if (!_isActive) return;

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
      if (!_isActive) {
        timer.cancel();
        return;
      }

      final ahora = DateTime.now();
      final limite = const Duration(seconds: 3);

      final ecgOk =
          _lastEcgTime != null && ahora.difference(_lastEcgTime!) < limite;
      final co2Ok =
          _lastCo2Time != null && ahora.difference(_lastCo2Time!) < limite;

      if (ecgOk != state.isEcgActive || co2Ok != state.isCo2Active) {
        state = state.copiarCon(
          isEcgActive: ecgOk,
          isCo2Active: co2Ok,
          ecgData: ecgOk ? null : [],
          co2Data: co2Ok ? null : [],
          heartRate: ecgOk ? null : 0,
          co2Level: co2Ok ? null : 0,
        );
      }
    });
  }

  void _flushPendingPackets() {
    _hasFrameCallbackPending = false;
    if (!_isActive || _pendingPackets.isEmpty) return;

    final batch = _pendingPackets;
    _pendingPackets = [];

    final nuevosEcg = List<BiometricPoint>.of(state.ecgData);
    final nuevosCo2 = List<BiometricPoint>.of(state.co2Data);
    int fc = state.heartRate;
    int co2Nivel = state.co2Level;
    bool isEcgActive = state.isEcgActive;
    bool isCo2Active = state.isCo2Active;

    for (final packet in batch) {
      final pType = packet.type.trim().toLowerCase();
      double valor = packet.value;
      if (pType == 'ecg' && valor <= 3.0) {
        valor = -10.0 + (valor - 0.2) * 90.0;
      }

      _startTimeMs ??= packet.timestamp.toDouble();
      final normalizedTime = packet.timestamp.toDouble() - _startTimeMs!;
      final punto = BiometricPoint(normalizedTime, valor);

      if (_isBuffering) {
        bool isAlert = false;
        if (pType == 'bpm') {
          final alarmState = ref.read(alarmNotifierProvider);
          isAlert =
              valor < alarmState.thresholds.bpmMin ||
              valor > alarmState.thresholds.bpmMax;
        } else if (pType == 'air' ||
            pType == 'co2' ||
            pType == 'mq' ||
            pType == 'mq135' ||
            pType == 'gas') {
          final alarmState = ref.read(alarmNotifierProvider);
          isAlert = valor > alarmState.thresholds.co2Max;
        }

        final sample = Sample(
          timestamp: packet.timestamp,
          value: packet.value,
          alert: isAlert,
        );
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
          isEcgActive = true;
          break;
        case 'bpm':
          fc = packet.value.round();
          isEcgActive = true;
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
          co2Nivel = packet.value.round().clamp(300, 10000);
          isCo2Active = true;
          break;
      }
    }

    try {
      if (!_isActive) return;

      state = state.copiarCon(
        ecgData: nuevosEcg,
        co2Data: nuevosCo2,
        heartRate: fc,
        co2Level: co2Nivel,
        isEcgActive: isEcgActive,
        isCo2Active: isCo2Active,
      );

      ref
          .read(alarmNotifierProvider.notifier)
          .monitorValues(fc: fc, co2: co2Nivel);
    } catch (e) {
      debugPrint('[VitalSignsNotifier] Error en Scheduler Flush: $e');
    }
  }
}
