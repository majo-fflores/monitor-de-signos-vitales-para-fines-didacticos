import 'package:datavital_flutter/core/services/websocket_service.dart';
import 'package:datavital_flutter/shared/providers/connection_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/mock_providers.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('ConnectionProvider Tests', () {
    late MockWebSocketService mockWsService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockWsService = MockWebSocketService();
      when(() => mockWsService.status).thenReturn(ValueNotifier(EstadoConexion.desconectado));
      when(() => mockWsService.connect(any())).thenAnswer((_) async {});
      when(() => mockWsService.disconnect()).thenAnswer((_) => {});
    });

    test('initial state has default wsUrl and cargando: true', () {
      final container = createContainer();
      final state = container.read(notificadorConexionProvider);

      expect(state.wsUrl, contains('ws://'));
      expect(state.cargando, isTrue);
    });

    test('after loading configuration, cargando is false', () async {
      final container = createContainer();
      final notifier = container.read(notificadorConexionProvider.notifier);
      notifier.wsServiceForTesting = mockWsService;

      await Future.delayed(Duration.zero);

      final state = container.read(notificadorConexionProvider);
      expect(state.cargando, isFalse);
      verify(() => mockWsService.connect(state.wsUrl)).called(1);
    });

    test('reconectar reconnects', () async {
      final container = createContainer();
      final notifier = container.read(notificadorConexionProvider.notifier);
      notifier.wsServiceForTesting = mockWsService;

      await Future.delayed(Duration.zero);

      notifier.reconectar();

      verify(() => mockWsService.disconnect()).called(1);
      verify(() => mockWsService.connect(any())).called(2);
    });
  });
}
