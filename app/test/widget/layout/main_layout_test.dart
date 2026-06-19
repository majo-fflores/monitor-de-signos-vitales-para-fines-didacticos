import 'package:datavital_flutter/core/services/audio_service.dart';
import 'package:datavital_flutter/shared/providers/alarm_state.dart';
import 'package:datavital_flutter/shared/providers/connection_provider.dart';
import 'package:datavital_flutter/shared/providers/user_provider.dart';
import 'package:datavital_flutter/shared/widgets/layout/main_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_providers.dart';

class MockAlarmaNotifier extends AlarmNotifier {
  final AlarmState _state;
  MockAlarmaNotifier(this._state);

  @override
  AlarmState build() => _state;

  void updateState(AlarmState newState) {
    state = newState;
  }
}

class MockUsersNotifier extends UsersNotifier {
  final UsersState _state;
  MockUsersNotifier(this._state);

  @override
  UsersState build() => _state;
}

class MockConexionNotifier extends ConnectionNotifier {
  final BackendConnectionState _state;
  MockConexionNotifier(this._state);

  @override
  BackendConnectionState build() => _state;
}

void main() {
  group('MainLayout Widget Tests', () {
    late MockAudioService mockAudio;

    setUp(() {
      mockAudio = MockAudioService();
      AudioService.instance = mockAudio;
      when(() => mockAudio.startAlarm(any())).thenAnswer((_) async {});
      when(() => mockAudio.stopAlarm()).thenAnswer((_) async {});
    });

    Widget createLayoutWithRouter({
      required Widget child,
      required List<Override> overrides,
    }) {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => MainLayout(child: child),
          ),
        ],
      );

      return ProviderScope(
        overrides: overrides,
        child: MaterialApp.router(routerConfig: router),
      );
    }

    testWidgets('should render children and default layout elements', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      final alarmState = AlarmState.inicial();
      final usersState = UsersState.inicial().copiarCon(isLoading: false);
      final conState = BackendConnectionState.inicial();

      await tester.pumpWidget(
        createLayoutWithRouter(
          child: const Text('My Body Child'),
          overrides: [
            alarmNotifierProvider.overrideWith(
              () => MockAlarmaNotifier(alarmState),
            ),
            usersNotifierProvider.overrideWith(
              () => MockUsersNotifier(usersState),
            ),
            connectionNotifierProvider.overrideWith(
              () => MockConexionNotifier(conState),
            ),
          ],
        ),
      );

      expect(find.text('My Body Child'), findsOneWidget);
      expect(find.text('DataVital'), findsNothing);
      expect(find.text('ALARMA CRÍTICA'), findsNothing);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets(
      'should show BannerAlarmaCritica and trigger audio when alarm transitions to active',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;

        final initialAlarmState = AlarmState.inicial();
        final usersState = UsersState.inicial().copiarCon(isLoading: false);
        final conState = BackendConnectionState.inicial();

        final notifier = MockAlarmaNotifier(initialAlarmState);

        await tester.pumpWidget(
          createLayoutWithRouter(
            child: const Text('My Body Child'),
            overrides: [
              alarmNotifierProvider.overrideWith(() => notifier),
              usersNotifierProvider.overrideWith(
                () => MockUsersNotifier(usersState),
              ),
              connectionNotifierProvider.overrideWith(
                () => MockConexionNotifier(conState),
              ),
            ],
          ),
        );

        expect(find.text('ALARMA CRÍTICA'), findsNothing);

        // Transition state
        final activeAlarmState = AlarmState.inicial().copiarCon(
          alarmActive: true,
          secondsRemaining: 30,
          activeAlerts: [const CriticalAlert('Frecuencia Cardíaca', 110)],
        );
        notifier.updateState(activeAlarmState);
        await tester.pump();

        // Banner should be visible
        expect(find.text('ALARMA CRÍTICA'), findsOneWidget);
        // Audio should have been triggered
        verify(() => mockAudio.startAlarm(any())).called(1);

        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      },
    );
  });
}
