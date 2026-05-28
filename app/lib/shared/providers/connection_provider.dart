import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/websocket_service.dart';

part 'connection_provider.g.dart';

/// Modo de fuente de datos para los sensores.
enum ModoFuente { simulacion, websocket }

/// Estado inmutable de la conexión al backend.
@immutable
class EstadoConexionBackend {
  final ModoFuente modo;
  final EstadoConexion estadoWs;
  final String wsUrl;
  final bool cargando;

  const EstadoConexionBackend({
    required this.modo,
    required this.estadoWs,
    required this.wsUrl,
    required this.cargando,
  });

  factory EstadoConexionBackend.inicial() {
    const String defaultWsUrl = String.fromEnvironment(
      'BACKEND_WS_URL',
      defaultValue: 'ws://localhost:8080/ws/sensors',
    );

    return const EstadoConexionBackend(
      modo: ModoFuente.simulacion,
      estadoWs: EstadoConexion.desconectado,
      wsUrl: defaultWsUrl,
      cargando: true,
    );
  }

  EstadoConexionBackend copiarCon({
    ModoFuente? modo,
    EstadoConexion? estadoWs,
    String? wsUrl,
    bool? cargando,
  }) {
    return EstadoConexionBackend(
      modo: modo ?? this.modo,
      estadoWs: estadoWs ?? this.estadoWs,
      wsUrl: wsUrl ?? this.wsUrl,
      cargando: cargando ?? this.cargando,
    );
  }
}

/// Notifier que administra la conexión WebSocket con el backend.
/// Persiste únicamente la preferencia del Toggle (modo fuente) en SharedPreferences.
@Riverpod(keepAlive: true)
class NotificadorConexion extends _$NotificadorConexion {
  WebSocketService? _wsService;
  SharedPreferences? _prefs;

  static const _keyModo = 'datavital_modo_fuente';

  @override
  EstadoConexionBackend build() {
    _cargarConfiguracion();
    ref.onDispose(() {
      _wsService?.dispose();
    });
    return EstadoConexionBackend.inicial();
  }

  /// Carga la preferencia de simulación/websocket guardada de SharedPreferences.
  Future<void> _cargarConfiguracion() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final modoStr = _prefs?.getString(_keyModo) ?? 'simulacion';
      final modo = modoStr == 'websocket'
          ? ModoFuente.websocket
          : ModoFuente.simulacion;

      if (modo == ModoFuente.websocket) {
        wsService.connect(state.wsUrl);
      }

      state = state.copiarCon(modo: modo, cargando: false);
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

  /// Cambia el modo de fuente de datos (simulación/websocket).
  Future<void> cambiarModo(ModoFuente nuevoModo) async {
    if (nuevoModo == state.modo) return;

    if (nuevoModo == ModoFuente.websocket) {
      // Conectar al WebSocket usando la URL única de entorno
      wsService.connect(state.wsUrl);
    } else {
      // Desconectar WebSocket
      _wsService?.disconnect();
    }

    state = state.copiarCon(modo: nuevoModo);
    await _prefs?.setString(
      _keyModo,
      nuevoModo == ModoFuente.websocket ? 'websocket' : 'simulacion',
    );
  }

  /// Fuerza reconexión manual.
  void reconectar() {
    if (state.modo == ModoFuente.websocket) {
      wsService.disconnect();
      wsService.connect(state.wsUrl);
    }
  }
}
