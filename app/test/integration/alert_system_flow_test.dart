import 'package:datavital_flutter/core/router/app_router.dart';
import 'package:datavital_flutter/core/services/audio_service.dart';
import 'package:datavital_flutter/shared/providers/alarm_state.dart';
import 'package:datavital_flutter/shared/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/mock_providers.dart';
import '../helpers/test_data.dart';

class MockUsersNotifier extends UsersNotifier {
  final UsersState _state;
  MockUsersNotifier(this._state);

  @override
  UsersState build() => _state;
}

class TestAlarmaNotifier extends AlarmNotifier {
  final AlarmState _state;
  TestAlarmaNotifier(this._state);

  @override
  AlarmState build() {
    ref.onDispose(() {
      // Do nothing
    });
    return _state;
  }

  void updateState(AlarmState newState) {
    state = newState;
  }

  @override
  void muteAlarm() {
    state = state.copiarCon(isSoundTemporarilyMuted: true);
  }

  @override
  void unmuteAlarm() {
    state = state.copiarCon(isSoundTemporarilyMuted: false);
  }
}

void main() {
  group('AlertSystemFlow Integration Tests', () {
    late MockAudioService mockAudio;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockAudio = MockAudioService();
      AudioService.instance = mockAudio;
      when(() => mockAudio.startAlarm(any())).thenAnswer((_) async {});
      when(() => mockAudio.stopAlarm()).thenAnswer((_) async {});
    });

    testWidgets(
      'should play audio alarm when triggered, allow silencing sound, and show alert banner',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;

        final user = TestData.user1;
        final usersState = UsersState.inicial().copiarCon(
          isLoading: false,
          users: [user],
          activeUser: user,
        );

        final initialAlarmState = AlarmState.inicial().copiarCon(
          isEnabled: true,
          isSoundEnabled: true,
          selectedSound: 'alarma_clasica',
          alarmActive: false,
          activeAlerts: [],
        );

        final alarmNotifier = TestAlarmaNotifier(initialAlarmState);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              usersNotifierProvider.overrideWith(
                () => MockUsersNotifier(usersState),
              ),
              alarmNotifierProvider.overrideWith(() => alarmNotifier),
            ],
            child: Consumer(
              builder: (context, ref, child) {
                final router = ref.watch(routerProvider);
                return MaterialApp.router(routerConfig: router);
              },
            ),
          ),
        );

        // Initially no alarm banner is shown
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.text('ALARMA CRÍTICA'), findsNothing);

        // Now trigger an alarm state update
        final activeAlarmState = AlarmState.inicial().copiarCon(
          isEnabled: true,
          isSoundEnabled: true,
          selectedSound: 'alarma_clasica',
          alarmActive: true,
          secondsRemaining: 30,
          activeAlerts: [
            const CriticalAlert('Frecuencia Cardíaca', 120),
            const CriticalAlert('Saturación de Oxígeno', 92),
          ],
        );

        alarmNotifier.updateState(activeAlarmState);
        await tester
            .pump(); // Pump frame to trigger ref.listen in MainLayout and render changes

        // Verify that audio alarm started playing
        verify(() => mockAudio.startAlarm('alarma_clasica')).called(1);

        // Verify the alarm banner is visible in the UI
        expect(find.text('ALARMA CRÍTICA'), findsOneWidget);
        expect(
          find.textContaining(
            'Frecuencia Cardíaca: 120 | Saturación de Oxígeno: 92',
          ),
          findsOneWidget,
        );

        // Tap the SILENCIAR button on the banner
        final silenceBtn = find.widgetWithText(ElevatedButton, 'SILENCIAR');
        expect(silenceBtn, findsOneWidget);
        await tester.tap(silenceBtn);

        // Update notifier state to mimic the silenced state in the provider
        final silencedState = activeAlarmState.copiarCon(
          isSoundTemporarilyMuted: true,
        );
        alarmNotifier.updateState(silencedState);
        await tester.pump(); // Pump frame to trigger ref.listen and rebuild

        // Verify that the audio was stopped/silenced
        verify(() => mockAudio.stopAlarm()).called(greaterThanOrEqualTo(1));

        // Verify that the banner is still visible (visual alarm active), but now displays option to reactivate sound
        expect(find.text('ALARMA CRÍTICA'), findsOneWidget);
        expect(find.text('ACTIVAR SONIDO'), findsOneWidget);

        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      },
    );
  });
}
