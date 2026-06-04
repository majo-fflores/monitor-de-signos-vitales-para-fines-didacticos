import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
      ppgFrecuenciaCardiaca: ppgFrecuenciaCardiaca ?? this.ppgFrecuenciaCardiaca,
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
  bool _estaActivo = false;
  final math.Random _random = math.Random();

  DateTime? _lastEcgTime;
  DateTime? _lastSpo2Time;
  DateTime? _lastCo2Time;

  StreamSubscription<WsPacket>? _suscripcionWs;
  List<WsPacket> _pendingPackets = [];
  bool _hasFrameCallbackPending = false;

  @override
  EstadoSignosVitales build() {
    _estaActivo = true;
    return EstadoSignosVitales.inicial();
  }

  /// Inicializa la ventana de datos con puntos vacíos.
  void _inicializarVentana() {
    final ahora = DateTime.now().millisecondsSinceEpoch.toDouble();
    final ecgInicial = <PuntoBiometrico>[];
    final spo2Inicial = <PuntoBiometrico>[];

    double t = ahora;
    for (int i = 0; i < _kVentanaPuntos; i++) {
      ecgInicial.add(PuntoBiometrico(t, 0.0));
      spo2Inicial.add(PuntoBiometrico(t, 50.0));
      t += 100;
    }

    state = state.copiarCon(
      ecgDatos: ecgInicial,
      spo2Datos: spo2Inicial,
    );
  }

  /// Detiene cualquier fuente de datos activa de forma limpia.
  void _detenerTodo() {
    _estaActivo = false;
    _silenceTimer?.cancel();
    _silenceTimer = null;
    _suscripcionWs?.cancel();
    _suscripcionWs = null;
    _pendingPackets = [];
    _hasFrameCallbackPending = false;
    _lastEcgTime = null;
    _lastSpo2Time = null;
    _lastCo2Time = null;
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

      final pType = packet.type.toLowerCase();
      // Actualizar la marca de tiempo del último paquete recibido por tipo de sensor
      if (pType == 'ecg') {
        _lastEcgTime = DateTime.now();
      } else if (pType == 'spo2') {
        _lastSpo2Time = DateTime.now();
      } else if (pType == 'co2' || pType == 'air') {
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
      final limite = const Duration(seconds: 3); // Límite de 3 segundos sin recibir datos

      final ecgOk = _lastEcgTime != null && ahora.difference(_lastEcgTime!) < limite;
      final spo2Ok = _lastSpo2Time != null && ahora.difference(_lastSpo2Time!) < limite;
      final co2Ok = _lastCo2Time != null && ahora.difference(_lastCo2Time!) < limite;

      final currentEcgActivo = (state.ecgActivo as dynamic) ?? true;
      final currentSpo2Activo = (state.spo2Activo as dynamic) ?? true;
      final currentCo2Activo = (state.co2Activo as dynamic) ?? true;

      if (ecgOk != currentEcgActivo || spo2Ok != currentSpo2Activo || co2Ok != currentCo2Activo) {
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

    for (final packet in batch) {
      final pType = packet.type.toLowerCase();
      double valor = packet.value;
      // Escalado inteligente del ECG: si los datos crudos del backend vienen en rango bajo (0.2 a 1.2),
      // los escalamos al rango visual de la gráfica (-10 a 80) para que oscilen correctamente
      if (pType == 'ecg' && valor <= 3.0) {
        valor = -10.0 + (valor - 0.2) * 90.0;
      }

      final punto = PuntoBiometrico(
        packet.timestamp.toDouble(),
        valor,
      );

      switch (pType) {
        case 'ecg':
          if (nuevosEcg.length >= _kVentanaPuntos) nuevosEcg.removeAt(0);
          nuevosEcg.add(punto);
          break;
        case 'spo2':
          if (nuevosSpo2.length >= _kVentanaPuntos) nuevosSpo2.removeAt(0);
          nuevosSpo2.add(punto);
          spo2Nivel = packet.value.round().clamp(0, 100);
          break;
        case 'bpm':
          fc = packet.value.round();
          ppgFc = fc + _random.nextInt(3) - 1;
          break;
        case 'air':
        case 'co2':
          co2Nivel = packet.value.round().clamp(300, 1500);
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
      );

      ref.read(notificadorAlarmaProvider.notifier).monitorearValores(
        fc: fc,
        spo2: spo2Nivel,
        co2: co2Nivel,
      );
    } catch (e) {
      debugPrint('[VitalSigns] Error en Scheduler Flush: $e');
    }
  }


}
