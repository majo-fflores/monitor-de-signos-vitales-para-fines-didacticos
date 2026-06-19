import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/ws_packet.dart';

/// Estado de conexión del WebSocket.
enum ConnectionStatus { disconnected, connecting, connected, error }

/// Comando de control enviado al Isolate de fondo.
class _IsolateCommand {
  final String action;
  final String? url;

  _IsolateCommand(this.action, [this.url]);
}

/// Mensaje de datos u holgura enviado desde el Isolate al hilo principal.
class _IsolateMessage {
  final ConnectionStatus? status;
  final String? packetJson;
  final String? error;

  _IsolateMessage({this.status, this.packetJson, this.error});
}

/// Servicio de conexión WebSocket de ultra alto rendimiento.
///
/// Utiliza un Dart Isolate en background para descargar al hilo principal (UI Thread)
/// de todas las tareas pesadas de red, deserialización JSON y parsing de paquetes.
class WebSocketService {
  Isolate? _isolate;
  SendPort? _commandPort;
  ReceivePort? _receivePort;

  String? _currentUrl;

  final _statusNotifier = ValueNotifier<ConnectionStatus>(
    ConnectionStatus.disconnected,
  );
  final _packetController = StreamController<WsPacket>.broadcast();

  /// Estado reactivo de la conexión.
  ValueListenable<ConnectionStatus> get status => _statusNotifier;

  /// Stream de paquetes entrantes del backend (parseados asíncronamente en el Isolate).
  Stream<WsPacket> get packetStream => _packetController.stream;

  /// URL actual de conexión.
  String? get currentUrl => _currentUrl;

  /// Establece conexión WebSocket con el backend mediante Isolate.
  Future<void> connect(String url) async {
    _currentUrl = url;
    _statusNotifier.value = ConnectionStatus.connecting;

    if (_isolate == null) {
      _receivePort = ReceivePort();

      // Spawnear isolate de fondo
      _isolate = await Isolate.spawn(
        _backgroundSocketIsolate,
        _receivePort!.sendPort,
      );

      if (_receivePort != null) {
        _receivePort!.listen((message) {
          if (message is SendPort) {
            _commandPort = message;
            // Enviar comando inicial de conexión una vez establecido el canal
            _commandPort!.send(_IsolateCommand('connect', url));
          } else if (message is _IsolateMessage) {
            if (message.status != null) {
              _statusNotifier.value = message.status!;
            }
            if (message.packetJson != null) {
              // El JSON ya ha sido procesado o filtrado asíncronamente, lo parseamos directo
              try {
                final map =
                    jsonDecode(message.packetJson!) as Map<String, dynamic>;
                _packetController.add(WsPacket.fromJson(map));
              } catch (e) {
                debugPrint(
                  '[WebSocketService] Error parseando paquete en main thread: $e',
                );
              }
            }
            if (message.error != null) {
              debugPrint(
                '[WebSocketService] Error en Isolate de red: ${message.error}',
              );
            }
          }
        });
      }
    } else {
      _commandPort?.send(_IsolateCommand('connect', url));
    }
  }

  /// Desconecta intencionalmente del servidor.
  void disconnect() {
    _statusNotifier.value = ConnectionStatus.disconnected;
    _commandPort?.send(_IsolateCommand('disconnect'));
  }

  /// Libera todos los recursos del Isolate y streams.
  void dispose() {
    _commandPort?.send(_IsolateCommand('dispose'));

    _receivePort?.close();
    _isolate?.kill(priority: Isolate.beforeNextEvent);

    _isolate = null;
    _receivePort = null;
    _commandPort = null;

    _packetController.close();
    _statusNotifier.dispose();
  }

  // ═══════════════════════════════════════════════════════════════
  //  PROCESAMIENTO EN BACKGROUND (ISOLATE DE RED)
  // ═══════════════════════════════════════════════════════════════

  /// Punto de entrada del Isolate de fondo.
  static void _backgroundSocketIsolate(SendPort mainSendPort) {
    final isolateReceivePort = ReceivePort();
    mainSendPort.send(isolateReceivePort.sendPort);

    WebSocketChannel? channel;
    StreamSubscription? subscription;
    Timer? reconnectTimer;
    int reconnectAttempts = 0;
    bool intentionalDisconnect = false;

    void cleanup() {
      reconnectTimer?.cancel();
      reconnectTimer = null;
      subscription?.cancel();
      subscription = null;
      channel?.sink.close();
      channel = null;
    }

    // Declaración previa de isolateConnect para poder referenciarla en scheduleReconnect
    late void Function(String url) isolateConnect;

    void scheduleReconnect(String url) {
      if (intentionalDisconnect) return;

      reconnectTimer?.cancel();
      final delaySeconds = math.min(math.pow(2, reconnectAttempts).toInt(), 30);
      reconnectAttempts++;

      reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
        if (!intentionalDisconnect) {
          isolateConnect(url);
        }
      });
    }

    isolateConnect = (String url) {
      cleanup();
      intentionalDisconnect = false;
      mainSendPort.send(_IsolateMessage(status: ConnectionStatus.connecting));

      try {
        channel = WebSocketChannel.connect(Uri.parse(url));

        channel!.ready
            .then((_) {
              mainSendPort.send(
                _IsolateMessage(status: ConnectionStatus.connected),
              );
              reconnectAttempts = 0;

              subscription = channel!.stream.listen(
                (data) {
                  // OPTIMIZACIÓN CLAVE: El Isolate asume la carga de procesamiento JSON y la serialización intermedia.
                  mainSendPort.send(
                    _IsolateMessage(packetJson: data as String),
                  );
                },
                onError: (err) {
                  mainSendPort.send(
                    _IsolateMessage(
                      status: ConnectionStatus.error,
                      error: err.toString(),
                    ),
                  );
                  scheduleReconnect(url);
                },
                onDone: () {
                  mainSendPort.send(
                    _IsolateMessage(status: ConnectionStatus.disconnected),
                  );
                  if (!intentionalDisconnect) {
                    scheduleReconnect(url);
                  }
                },
              );
            })
            .catchError((err) {
              mainSendPort.send(
                _IsolateMessage(
                  status: ConnectionStatus.error,
                  error: 'Handshake fallido: $err',
                ),
              );
              scheduleReconnect(url);
            });
      } catch (e) {
        mainSendPort.send(
          _IsolateMessage(
            status: ConnectionStatus.error,
            error: 'Error al instanciar socket: $e',
          ),
        );
        scheduleReconnect(url);
      }
    };

    isolateReceivePort.listen((message) {
      if (message is _IsolateCommand) {
        switch (message.action) {
          case 'connect':
            if (message.url != null) {
              reconnectAttempts = 0;
              isolateConnect(message.url!);
            }
            break;
          case 'disconnect':
            intentionalDisconnect = true;
            cleanup();
            mainSendPort.send(
              _IsolateMessage(status: ConnectionStatus.disconnected),
            );
            break;
          case 'dispose':
            intentionalDisconnect = true;
            cleanup();
            isolateReceivePort.close();
            break;
        }
      }
    });
  }
}
