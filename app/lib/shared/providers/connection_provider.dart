import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/websocket_service.dart';

part 'connection_provider.g.dart';

/// Estado inmutable de la conexión al backend.
@immutable
class EstadoConexionBackend {
  final EstadoConexion estadoWs;
  final String wsUrl;
  final bool cargando;

  const EstadoConexionBackend({
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
      estadoWs: EstadoConexion.desconectado,
      wsUrl: defaultWsUrl,
      cargando: true,
    );
  }

  EstadoConexionBackend copiarCon({
    EstadoConexion? estadoWs,
    String? wsUrl,
    bool? cargando,
  }) {
    return EstadoConexionBackend(
      estadoWs: estadoWs ?? this.estadoWs,
      wsUrl: wsUrl ?? this.wsUrl,
      cargando: cargando ?? this.cargando,
    );
  }
}

/// Notifier que administra la conexión WebSocket con el backend o la simulación de pruebas.
@Riverpod(keepAlive: true)
class NotificadorConexion extends _$NotificadorConexion {
  WebSocketService? _wsService;

  @visibleForTesting
  set wsServiceForTesting(WebSocketService service) {
    _wsService = service;
    _wsService!.status.addListener(() {
      if (state.estadoWs != _wsService!.status.value) {
        state = state.copiarCon(estadoWs: _wsService!.status.value);
      }
    });
  }

  @override
  EstadoConexionBackend build() {
    ref.onDispose(() {
      _wsService?.dispose();
    });
    Future.microtask(() => _cargarConfiguracion());
    return EstadoConexionBackend.inicial();
  }

  /// Inicia la conexión con el WebSocket.
  Future<void> _cargarConfiguracion() async {
    try {
      state = state.copiarCon(cargando: false);

      wsService.connect(state.wsUrl);
    } catch (e) {
      debugPrint('[NotificadorConexion] Error al conectar: $e');
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

  /// Fuerza reconexión manual.
  void reconectar() {
    wsService.disconnect();
    wsService.connect(state.wsUrl);
  }
}
