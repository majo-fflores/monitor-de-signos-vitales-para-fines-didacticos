import 'package:datavital_flutter/core/services/websocket_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WebSocketService Unit Tests', () {
    late WebSocketService service;

    setUp(() {
      service = WebSocketService();
    });

    tearDown(() {
      try {
        service.dispose();
      } catch (_) {}
    });

    test('initial state should be disconnected', () {
      expect(service.status.value, equals(ConnectionStatus.disconnected));
      expect(service.currentUrl, isNull);
    });

    test(
      'connect should update currentUrl and transition to connecting',
      () async {
        await service.connect('ws://localhost:9999');

        expect(service.currentUrl, equals('ws://localhost:9999'));
        expect(service.status.value, equals(ConnectionStatus.connecting));
      },
    );

    test('disconnect should transition state to disconnected', () async {
      await service.connect('ws://localhost:9999');
      expect(service.status.value, equals(ConnectionStatus.connecting));

      service.disconnect();
      expect(service.status.value, equals(ConnectionStatus.disconnected));
    });

    test('packetStream should be a broadcast stream', () {
      expect(service.packetStream.isBroadcast, isTrue);
    });
  });
}
