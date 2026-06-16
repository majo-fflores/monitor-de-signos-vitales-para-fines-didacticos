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

    test('initial state should be desconectado', () {
      expect(service.status.value, equals(EstadoConexion.desconectado));
      expect(service.currentUrl, isNull);
    });

    test(
      'connect should update currentUrl and transition to conectando',
      () async {
        await service.connect('ws://localhost:9999');

        expect(service.currentUrl, equals('ws://localhost:9999'));
        expect(service.status.value, equals(EstadoConexion.conectando));
      },
    );

    test('disconnect should transition state to desconectado', () async {
      await service.connect('ws://localhost:9999');
      expect(service.status.value, equals(EstadoConexion.conectando));

      service.disconnect();
      expect(service.status.value, equals(EstadoConexion.desconectado));
    });

    test('packetStream should be a broadcast stream', () {
      expect(service.packetStream.isBroadcast, isTrue);
    });
  });
}
