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
  final List<PuntoBiometrico> spo2Datos;
  final int frecuenciaCardiaca;
  final int ppgFrecuenciaCardiaca;
  final int nivelSpo2;
  final int nivelCo2;
  final bool ecgActivo;
  final bool spo2Activo;
  final bool co2Activo;

  const EstadoSignosVitales({
    required this.ecgDatos,
    required this.spo2Datos,
    required this.frecuenciaCardiaca,
    required this.ppgFrecuenciaCardiaca,
    required this.nivelSpo2,
    required this.nivelCo2,
    required this.ecgActivo,
    required this.spo2Activo,
    required this.co2Activo,
  });

  factory EstadoSignosVitales.inicial() {
    return const EstadoSignosVitales(
      ecgDatos: [],
      spo2Datos: [],
      frecuenciaCardiaca: 72,
      ppgFrecuenciaCardiaca: 72,
      nivelSpo2: 98,
      nivelCo2: 35,
      ecgActivo: true,
      spo2Activo: true,
      co2Activo: true,
    );
  }

  EstadoSignosVitales copiarCon({
    List<PuntoBiometrico>? ecgDatos,
    List<PuntoBiometrico>? spo2Datos,
    int? frecuenciaCardiaca,
    int? ppgFrecuenciaCardiaca,
    int? nivelSpo2,
    int? nivelCo2,
    bool? ecgActivo,
    bool? spo2Activo,
    bool? co2Activo,
  }) {
    return EstadoSignosVitales(
      ecgDatos: ecgDatos ?? this.ecgDatos,
      spo2Datos: spo2Datos ?? this.spo2Datos,
      frecuenciaCardiaca: frecuenciaCardiaca ?? this.frecuenciaCardiaca,
      ppgFrecuenciaCardiaca:
          ppgFrecuenciaCardiaca ?? this.ppgFrecuenciaCardiaca,
      nivelSpo2: nivelSpo2 ?? this.nivelSpo2,
      nivelCo2: nivelCo2 ?? this.nivelCo2,
      ecgActivo: ecgActivo ?? ((this.ecgActivo as dynamic) ?? true),
      spo2Activo: spo2Activo ?? ((this.spo2Activo as dynamic) ?? true),
      co2Activo: co2Activo ?? ((this.co2Activo as dynamic) ?? true),
    );
  }
}

/// Tamaño de la ventana deslizante de datos para los gráficos.
const int _kVentanaPuntos = 100;

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
  final math.Random _random = math.Random();

  bool _isBuffering = false;
  final List<Sample> _ecgBuffer = [];
  final List<Sample> _bpmBuffer = [];
  final List<Sample> _spo2Buffer = [];
  final List<Sample> _airBuffer = [];

  void startBuffering() {
    _ecgBuffer.clear();
    _bpmBuffer.clear();
    _spo2Buffer.clear();
    _airBuffer.clear();
    _isBuffering = true;
  }

  Map<String, List<Sample>> stopBuffering() {
    _isBuffering = false;
    return {
      'ecg': List<Sample>.from(_ecgBuffer),
      'bpm': List<Sample>.from(_bpmBuffer),
      'spo2': List<Sample>.from(_spo2Buffer),
      'air': List<Sample>.from(_airBuffer),
    };
  }

  DateTime? _lastEcgTime;
  DateTime? _lastSpo2Time;
  DateTime? _lastCo2Time;

  StreamSubscription<WsPacket>? _suscripcionWs;
  List<WsPacket> _pendingPackets = [];
  bool _hasFrameCallbackPending = false;

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
    final ahora = DateTime.now().millisecondsSinceEpoch.toDouble();
    _lastEcgWindowIndex = (ahora / 5000).floor();
    final spo2Inicial = <PuntoBiometrico>[];

    double t = ahora;
    for (int i = 0; i < _kVentanaPuntos; i++) {
      spo2Inicial.add(PuntoBiometrico(t, 98.0));
      t += 100;
    }

    state = state.copiarCon(
      ecgDatos: [], // ECG inicia vacío y se llena dinámicamente cada 5 segundos
      spo2Datos: spo2Inicial,
    );
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
    _lastSpo2Time = null;
    _lastCo2Time = null;
  }

  /// Inicia la simulación local de signos vitales para pruebas.
  void iniciarSimulacion() {
    _detenerTodo();
    _estaActivo = true;
    _inicializarVentana();

    // Marcamos los sensores simulados como activos
    state = state.copiarCon(ecgActivo: true, spo2Activo: true, co2Activo: true);

    // Plantillas de ondas sinusoidales/fisiológicas para ECG y SpO2 (Plethysmogram)
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

    const spo2Template = [
      50.0,
      50.5,
      51.5,
      53.0,
      55.0,
      57.5,
      60.0,
      62.0,
      63.5,
      64.0,
      63.5,
      62.5,
      61.0,
      59.5,
      58.5,
      58.0,
      58.5,
      59.0,
      58.5,
      57.0,
      55.0,
      53.0,
      51.5,
      50.5,
      50.0,
      50.0,
      50.0,
      50.0,
      50.0,
      50.0,
    ];

    int tick = 0;
    _timerSimulacion = Timer.periodic(const Duration(milliseconds: 20), (
      timer,
    ) {
      if (!_estaActivo) {
        timer.cancel();
        return;
      }

      final ahora = DateTime.now().millisecondsSinceEpoch.toDouble();

      // Añadir puntos a los gráficos
      final nuevosEcg = List<PuntoBiometrico>.of(state.ecgDatos);
      final nuevosSpo2 = List<PuntoBiometrico>.of(state.spo2Datos);

      // Lógica de barrido (sweep) de 5 segundos para ECG
      final currentPacketWindow = (ahora / 5000).floor();
      if (currentPacketWindow > _lastEcgWindowIndex) {
        _lastEcgWindowIndex = currentPacketWindow;
        nuevosEcg.clear();
      }

      double rawEcg = ecgTemplate[_simIndex % ecgTemplate.length];
      double valEcg = -10.0 + rawEcg * 90.0;
      nuevosEcg.add(PuntoBiometrico(ahora, valEcg));
      // Prevenir desbordamientos en caso de latencia prolongada
      if (nuevosEcg.length > 1000) nuevosEcg.removeAt(0);

      if (nuevosSpo2.length >= _kVentanaPuntos) nuevosSpo2.removeAt(0);
      double valSpo2 = spo2Template[_simIndex % spo2Template.length];
      nuevosSpo2.add(PuntoBiometrico(ahora, valSpo2));

      if (_isBuffering) {
        _ecgBuffer.add(Sample(timestamp: ahora.toInt(), value: valEcg));
        _spo2Buffer.add(Sample(timestamp: ahora.toInt(), value: valSpo2));
      }

      _simIndex++;

      // Cada 1 segundo (50 ticks @ 20ms) actualizamos las métricas de texto y monitoreamos alarmas
      tick++;
      if (tick >= 50) {
        tick = 0;

        // Generar valores fisiológicos realistas
        final fc = 72 + _random.nextInt(5) - 2; // 70-74 BPM
        final spo2 = 98 - _random.nextInt(2); // 97-98%
        final co2 = 380 + _random.nextInt(40) - 20; // 360-400 ppm

        if (_isBuffering) {
          _bpmBuffer.add(
            Sample(timestamp: ahora.toInt(), value: fc.toDouble()),
          );
          _airBuffer.add(
            Sample(timestamp: ahora.toInt(), value: co2.toDouble()),
          );
        }

        state = state.copiarCon(
          ecgDatos: nuevosEcg,
          spo2Datos: nuevosSpo2,
          frecuenciaCardiaca: fc,
          ppgFrecuenciaCardiaca: fc + 1,
          nivelSpo2: spo2,
          nivelCo2: co2,
        );

        ref
            .read(notificadorAlarmaProvider.notifier)
            .monitorearValores(fc: fc, ppg: fc + 1, co2: co2);
      } else {
        state = state.copiarCon(ecgDatos: nuevosEcg, spo2Datos: nuevosSpo2);
      }
    });
  }

  // ═══════════════════════════════════════════════════════════════
  //  MODO WEBSOCKET CON SCHEDULER BINDING (FRAME-RATE THROTTLING)
  // ═══════════════════════════════════════════════════════════════

  /// Inicia el WebSocket con sincronización de fotograma adaptativa.
  void iniciarConWebSocket(Stream<WsPacket> stream) {
    _detenerTodo();
    _estaActivo = true;
    _inicializarVentana();

    // Al iniciar en modo WebSocket, marcamos inicialmente todos como inactivos (Desconectados)
    // hasta recibir su primer paquete real
    state = state.copiarCon(
      ecgActivo: false,
      spo2Activo: false,
      co2Activo: false,
    );

    _suscripcionWs = stream.listen((packet) {
      if (!_estaActivo) return;

      final pType = packet.type.trim().toLowerCase();
      // Actualizar la marca de tiempo del último paquete recibido por tipo de sensor
      if (pType == 'ecg') {
        _lastEcgTime = DateTime.now();
      } else if (pType == 'spo2') {
        _lastSpo2Time = DateTime.now();
      } else if (pType == 'co2' ||
          pType == 'air' ||
          pType == 'mq' ||
          pType == 'mq135' ||
          pType == 'gas') {
        _lastCo2Time = DateTime.now();
      }

      _pendingPackets.add(packet);

      // Si no tenemos programado un vaciado para el siguiente frame, lo planificamos
      if (!_hasFrameCallbackPending) {
        _hasFrameCallbackPending = true;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _flushPendingPackets();
        });
      }
    });

    // Temporizador de silencio para detectar si algún sensor se desconectó (cada 1 segundo)
    _silenceTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_estaActivo) {
        timer.cancel();
        return;
      }

      final ahora = DateTime.now();
      final limite = const Duration(
        seconds: 3,
      ); // Límite de 3 segundos sin recibir datos

      final ecgOk =
          _lastEcgTime != null && ahora.difference(_lastEcgTime!) < limite;
      final spo2Ok =
          _lastSpo2Time != null && ahora.difference(_lastSpo2Time!) < limite;
      final co2Ok =
          _lastCo2Time != null && ahora.difference(_lastCo2Time!) < limite;

      final currentEcgActivo = (state.ecgActivo as dynamic) ?? true;
      final currentSpo2Activo = (state.spo2Activo as dynamic) ?? true;
      final currentCo2Activo = (state.co2Activo as dynamic) ?? true;

      if (ecgOk != currentEcgActivo ||
          spo2Ok != currentSpo2Activo ||
          co2Ok != currentCo2Activo) {
        state = state.copiarCon(
          ecgActivo: ecgOk,
          spo2Activo: spo2Ok,
          co2Activo: co2Ok,
          ecgDatos: ecgOk ? null : [],
          spo2Datos: spo2Ok ? null : [],
          frecuenciaCardiaca: ecgOk ? null : 0,
          ppgFrecuenciaCardiaca: spo2Ok ? null : 0,
          nivelSpo2: spo2Ok ? null : 0,
          nivelCo2: co2Ok ? null : 0,
        );
      }
    });
  }

  /// Vacía la cola de paquetes pendientes sincronizado con la GPU del terminal.
  void _flushPendingPackets() {
    _hasFrameCallbackPending = false;
    if (!_estaActivo || _pendingPackets.isEmpty) return;

    final batch = _pendingPackets;
    _pendingPackets = [];

    final nuevosEcg = List<PuntoBiometrico>.of(state.ecgDatos);
    final nuevosSpo2 = List<PuntoBiometrico>.of(state.spo2Datos);
    int fc = state.frecuenciaCardiaca;
    int ppgFc = state.ppgFrecuenciaCardiaca;
    int spo2Nivel = state.nivelSpo2;
    int co2Nivel = state.nivelCo2;
    bool ecgActivo = state.ecgActivo;
    bool spo2Activo = state.spo2Activo;
    bool co2Activo = state.co2Activo;

    for (final packet in batch) {
      final pType = packet.type.trim().toLowerCase();
      double valor = packet.value;
      // Escalado inteligente del ECG: si los datos crudos del backend vienen en rango bajo (0.2 a 1.2),
      // los escalamos al rango visual de la gráfica (-10 a 80) para que oscilen correctamente
      if (pType == 'ecg' && valor <= 3.0) {
        valor = -10.0 + (valor - 0.2) * 90.0;
      }

      final punto = PuntoBiometrico(packet.timestamp.toDouble(), valor);

      if (_isBuffering) {
        final sample = Sample(timestamp: packet.timestamp, value: packet.value);
        switch (pType) {
          case 'ecg':
            _ecgBuffer.add(sample);
            break;
          case 'spo2':
            _spo2Buffer.add(sample);
            break;
          case 'bpm':
            _bpmBuffer.add(sample);
            break;
          case 'air':
          case 'co2':
          case 'mq':
          case 'mq135':
          case 'gas':
            _airBuffer.add(sample);
            break;
        }
      }

      switch (pType) {
        case 'ecg':
          final currentPacketWindow = (packet.timestamp / 5000).floor();
          if (currentPacketWindow > _lastEcgWindowIndex) {
            _lastEcgWindowIndex = currentPacketWindow;
            nuevosEcg.clear();
          }
          nuevosEcg.add(punto);
          if (nuevosEcg.length > 1000) nuevosEcg.removeAt(0);
          ecgActivo = true;
          break;
        case 'spo2':
          if (nuevosSpo2.length >= _kVentanaPuntos) nuevosSpo2.removeAt(0);
          nuevosSpo2.add(punto);
          spo2Nivel = packet.value.round().clamp(0, 100);
          spo2Activo = true;
          break;
        case 'bpm':
          fc = packet.value.round();
          ppgFc = fc + _random.nextInt(3) - 1;
          break;
        case 'air':
        case 'co2':
        case 'mq':
        case 'mq135':
        case 'gas':
          co2Nivel = packet.value.round().clamp(300, 1500);
          co2Activo = true;
          break;
      }
    }

    try {
      if (!_estaActivo) return;

      state = state.copiarCon(
        ecgDatos: nuevosEcg,
        spo2Datos: nuevosSpo2,
        frecuenciaCardiaca: fc,
        ppgFrecuenciaCardiaca: ppgFc,
        nivelSpo2: spo2Nivel,
        nivelCo2: co2Nivel,
        ecgActivo: ecgActivo,
        spo2Activo: spo2Activo,
        co2Activo: co2Activo,
      );

      ref
          .read(notificadorAlarmaProvider.notifier)
          .monitorearValores(fc: fc, ppg: ppgFc, co2: co2Nivel);
    } catch (e) {
      debugPrint('[VitalSigns] Error en Scheduler Flush: $e');
    }
  }
}
