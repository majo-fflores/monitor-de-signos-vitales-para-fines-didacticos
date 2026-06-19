import 'package:datavital_flutter/core/models/ws_packet.dart';
import 'package:datavital_flutter/core/services/audio_service.dart';
import 'package:datavital_flutter/core/services/user_api_service.dart';
import 'package:datavital_flutter/core/services/websocket_service.dart';
import 'package:mocktail/mocktail.dart';

class MockWebSocketService extends Mock implements WebSocketService {
  @override
  Stream<WsPacket> get packetStream => const Stream<WsPacket>.empty();
}

class MockAudioService extends Mock implements AudioService {}

class MockUserApiService extends Mock implements UserApiService {}
