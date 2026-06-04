import 'package:datavital_flutter/core/router/app_router.dart';
import 'package:datavital_flutter/core/services/servicio_audio.dart';
import 'package:datavital_flutter/shared/providers/alarma_state.dart';
import 'package:datavital_flutter/shared/providers/usuario_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/mock_providers.dart';
import '../helpers/test_data.dart';

class MockUsuariosNotifier extends NotificadorUsuarios {
  final EstadoUsuarios _state;
  MockUsuariosNotifier(this._state);

  @override
  EstadoUsuarios build() => _state;
}

class TestAlarmaNotifier extends NotificadorAlarma {
  final EstadoAlarma _state;
  TestAlarmaNotifier(this._state);

  @override
  EstadoAlarma build() {
    ref.onDispose(() {
      // Do nothing
    });
    return _state;
  }

  void updateState(EstadoAlarma newState) {
    state = newState;
  }

  @override
  void silenciarAlarma() {
    state = state.copiarCon(sonidoSilenciadoTemporalmente: true);
  }

  @override
  void desactivarSilencioTemporal() {
    state = state.copiarCon(sonidoSilenciadoTemporalmente: false);
  }
}

void main() {
  group('AlertSystemFlow Integration Tests', () {
    late MockServicioAudio mockAudio;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockAudio = MockServicioAudio();
      ServicioAudio.instancia = mockAudio;
      when(() => mockAudio.iniciarAlarma(any())).thenAnswer((_) async {});
      when(() => mockAudio.detenerAlarma()).thenAnswer((_) async {});
    });

    testWidgets('should play audio alarm when triggered, allow silencing sound, and show alert banner', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      final user = TestData.usuario1;
      final usersState = EstadoUsuarios.inicial().copiarCon(
        cargando: false,
        usuarios: [user],
        usuarioActivo: user,
      );

      final initialAlarmState = EstadoAlarma.inicial().copiarCon(
        habilitada: true,
        sonidoHabilitado: true,
        sonidoSeleccionado: 'alarma_clasica',
        alarmaActiva: false,
        alertasActivas: [],
      );

      final alarmNotifier = TestAlarmaNotifier(initialAlarmState);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificadorUsuariosProvider.overrideWith(() => MockUsuariosNotifier(usersState)),
            notificadorAlarmaProvider.overrideWith(() => alarmNotifier),
          ],
          child: Consumer(
            builder: (context, ref, child) {
              final router = ref.watch(routerProvider);
              return MaterialApp.router(
                routerConfig: router,
              );
            },
          ),
        ),
      );

      // Initially no alarm banner is shown
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('ALARMA CRÍTICA'), findsNothing);

      // Now trigger an alarm state update
      final activeAlarmState = EstadoAlarma.inicial().copiarCon(
        habilitada: true,
        sonidoHabilitado: true,
        sonidoSeleccionado: 'alarma_clasica',
        alarmaActiva: true,
        segundosRestantes: 30,
        alertasActivas: [
          const AlertaCritica('Frecuencia Cardíaca', 120),
          const AlertaCritica('Saturación de Oxígeno', 92),
        ],
      );

      alarmNotifier.updateState(activeAlarmState);
      await tester.pump(); // Pump frame to trigger ref.listen in MainLayout and render changes

      // Verify that audio alarm started playing
      verify(() => mockAudio.iniciarAlarma('alarma_clasica')).called(1);

      // Verify the alarm banner is visible in the UI
      expect(find.text('ALARMA CRÍTICA'), findsOneWidget);
      expect(find.textContaining('Frecuencia Cardíaca: 120 | Saturación de Oxígeno: 92'), findsOneWidget);

      // Tap the SILENCIAR button on the banner
      final silenceBtn = find.widgetWithText(ElevatedButton, 'SILENCIAR');
      expect(silenceBtn, findsOneWidget);
      await tester.tap(silenceBtn);

      // Update notifier state to mimic the silenced state in the provider
      final silencedState = activeAlarmState.copiarCon(
        sonidoSilenciadoTemporalmente: true,
      );
      alarmNotifier.updateState(silencedState);
      await tester.pump(); // Pump frame to trigger ref.listen and rebuild

      // Verify that the audio was stopped/silenced
      verify(() => mockAudio.detenerAlarma()).called(greaterThanOrEqualTo(1));

      // Verify that the banner is still visible (visual alarm active), but now displays option to reactivate sound
      expect(find.text('ALARMA CRÍTICA'), findsOneWidget);
      expect(find.text('ACTIVAR SONIDO'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
