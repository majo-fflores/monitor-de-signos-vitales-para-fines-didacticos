import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/websocket_service.dart';

part 'connection_provider.g.dart';

/// Estado inmutable de la conexión al backend.
@immutable
class EstadoConexionBackend {
  final EstadoConexion estadoWs;
  final String wsUrl;
  final bool cargando;
  final bool modoSimulacion;

  const EstadoConexionBackend({
    required this.estadoWs,
    required this.wsUrl,
    required this.cargando,
    required this.modoSimulacion,
  });

  factory EstadoConexionBackend.inicial() {
    const String defaultWsUrl = String.fromEnvironment(
      'BACKEND_WS_URL',
      defaultValue: 'ws://localhost:8080/ws/sensors',
    );

    return const EstadoConexionBackend(
      estadoWs: EstadoConexion.desconectado,
      wsUrl: defaultWsUrl,
      cargando: true,
      modoSimulacion: false,
    );
  }

  EstadoConexionBackend copiarCon({
    EstadoConexion? estadoWs,
    String? wsUrl,
    bool? cargando,
    bool? modoSimulacion,
  }) {
    return EstadoConexionBackend(
      estadoWs: estadoWs ?? this.estadoWs,
      wsUrl: wsUrl ?? this.wsUrl,
      cargando: cargando ?? this.cargando,
      modoSimulacion: modoSimulacion ?? this.modoSimulacion,
    );
  }
}

/// Notifier que administra la conexión WebSocket con el backend o la simulación de pruebas.
@Riverpod(keepAlive: true)
class NotificadorConexion extends _$NotificadorConexion {
  WebSocketService? _wsService;

  @override
  EstadoConexionBackend build() {
    ref.onDispose(() {
      _wsService?.dispose();
    });
    Future.microtask(() => _cargarConfiguracion());
    return EstadoConexionBackend.inicial();
  }

  /// Inicia la conexión con el WebSocket o habilita el modo simulación según las preferencias.
  Future<void> _cargarConfiguracion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modoSim = prefs.getBool('datavital_modo_simulacion') ?? false;

      state = state.copiarCon(
        modoSimulacion: modoSim,
        cargando: false,
      );

      if (!modoSim) {
        wsService.connect(state.wsUrl);
      }
    } catch (e) {
      debugPrint('[NotificadorConexion] Error cargando config: $e');
      state = state.copiarCon(cargando: false);
    }
  }

  /// Obtiene (o crea) la instancia del servicio WebSocket.
  WebSocketService get wsService {
    _wsService ??= WebSocketService();
    // Sincronizar estado de conexión con el notifier
    _wsService!.status.addListener(() {
      if (state.estadoWs != _wsService!.status.value) {
        state = state.copiarCon(estadoWs: _wsService!.status.value);
      }
    });
    return _wsService!;
  }

  /// Cambia el modo de simulación local y conecta/desconecta el WS correspondiente.
  Future<void> cambiarModoSimulacion(bool valor) async {
    state = state.copiarCon(modoSimulacion: valor);
    
    if (valor) {
      wsService.disconnect();
    } else {
      wsService.connect(state.wsUrl);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('datavital_modo_simulacion', valor);
    } catch (e) {
      debugPrint('[NotificadorConexion] Error guardando modo simulación: $e');
    }
  }

  /// Fuerza reconexión manual (sólo si no estamos en modo simulación).
  void reconectar() {
    if (state.modoSimulacion) return;
    wsService.disconnect();
    wsService.connect(state.wsUrl);
  }
}
