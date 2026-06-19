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
      when(
        () => mockWsService.status,
      ).thenReturn(ValueNotifier(ConnectionStatus.disconnected));
      when(() => mockWsService.connect(any())).thenAnswer((_) async {});
      when(() => mockWsService.disconnect()).thenAnswer((_) => {});
    });

    test('initial state has default wsUrl and isLoading: true', () {
      final container = createContainer();
      final state = container.read(connectionNotifierProvider);

      expect(state.wsUrl, contains('ws://'));
      expect(state.isLoading, isTrue);
    });

    test('after loading configuration, isLoading is false', () async {
      final container = createContainer();
      final notifier = container.read(connectionNotifierProvider.notifier);
      notifier.wsServiceForTesting = mockWsService;

      await Future.delayed(Duration.zero);

      final state = container.read(connectionNotifierProvider);
      expect(state.isLoading, isFalse);
      verify(() => mockWsService.connect(state.wsUrl)).called(1);
    });

    test('reconnect reconnects', () async {
      final container = createContainer();
      final notifier = container.read(connectionNotifierProvider.notifier);
      notifier.wsServiceForTesting = mockWsService;

      await Future.delayed(Duration.zero);

      notifier.reconnect();

      verify(() => mockWsService.disconnect()).called(1);
      verify(() => mockWsService.connect(any())).called(2);
    });
  });
}
