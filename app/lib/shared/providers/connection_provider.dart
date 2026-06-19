import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/websocket_service.dart';

part 'connection_provider.g.dart';

/// Estado inmutable de la conexión al backend.
@immutable
class BackendConnectionState {
  final ConnectionStatus wsStatus;
  final String wsUrl;
  final bool isLoading;

  const BackendConnectionState({
    required this.wsStatus,
    required this.wsUrl,
    required this.isLoading,
  });

  factory BackendConnectionState.inicial() {
    const String defaultWsUrl = String.fromEnvironment(
      'BACKEND_WS_URL',
      defaultValue: 'ws://localhost:8080/ws/sensors',
    );

    return const BackendConnectionState(
      wsStatus: ConnectionStatus.disconnected,
      wsUrl: defaultWsUrl,
      isLoading: true,
    );
  }

  BackendConnectionState copiarCon({
    ConnectionStatus? wsStatus,
    String? wsUrl,
    bool? isLoading,
  }) {
    return BackendConnectionState(
      wsStatus: wsStatus ?? this.wsStatus,
      wsUrl: wsUrl ?? this.wsUrl,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Notifier que administra la conexión WebSocket con el backend o la simulación de pruebas.
@Riverpod(keepAlive: true)
class ConnectionNotifier extends _$ConnectionNotifier {
  WebSocketService? _wsService;

  @visibleForTesting
  set wsServiceForTesting(WebSocketService service) {
    _wsService = service;
    _wsService!.status.addListener(() {
      if (state.wsStatus != _wsService!.status.value) {
        state = state.copiarCon(wsStatus: _wsService!.status.value);
      }
    });
  }

  @override
  BackendConnectionState build() {
    ref.onDispose(() {
      _wsService?.dispose();
    });
    Future.microtask(() => _loadConfiguration());
    return BackendConnectionState.inicial();
  }

  /// Inicia la conexión con el WebSocket.
  Future<void> _loadConfiguration() async {
    try {
      state = state.copiarCon(isLoading: false);

      wsService.connect(state.wsUrl);
    } catch (e) {
      debugPrint('[ConnectionNotifier] Error al conectar: $e');
      state = state.copiarCon(isLoading: false);
    }
  }

  /// Obtiene (o crea) la instancia del servicio WebSocket.
  WebSocketService get wsService {
    _wsService ??= WebSocketService();
    // Sincronizar estado de conexión con el notifier
    _wsService!.status.addListener(() {
      if (state.wsStatus != _wsService!.status.value) {
        state = state.copiarCon(wsStatus: _wsService!.status.value);
      }
    });
    return _wsService!;
  }

  /// Fuerza reconexión manual.
  void reconnect() {
    wsService.disconnect();
    wsService.connect(state.wsUrl);
  }
}
