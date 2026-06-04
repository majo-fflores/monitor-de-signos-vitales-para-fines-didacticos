import 'package:datavital_flutter/core/models/ws_packet.dart';
import 'package:datavital_flutter/core/services/servicio_audio.dart';
import 'package:datavital_flutter/core/services/usuario_api_service.dart';
import 'package:datavital_flutter/core/services/websocket_service.dart';
import 'package:mocktail/mocktail.dart';

class MockWebSocketService extends Mock implements WebSocketService {
  @override
  Stream<WsPacket> get packetStream => const Stream<WsPacket>.empty();
}
class MockServicioAudio extends Mock implements ServicioAudio {}
class MockUsuarioApiService extends Mock implements UsuarioApiService {}
