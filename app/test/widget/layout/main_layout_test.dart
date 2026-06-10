import 'package:datavital_flutter/core/services/servicio_audio.dart';
import 'package:datavital_flutter/shared/providers/alarma_state.dart';
import 'package:datavital_flutter/shared/providers/connection_provider.dart';
import 'package:datavital_flutter/shared/providers/usuario_provider.dart';
import 'package:datavital_flutter/shared/widgets/layout/main_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_providers.dart';

class MockAlarmaNotifier extends NotificadorAlarma {
  final EstadoAlarma _state;
  MockAlarmaNotifier(this._state);

  @override
  EstadoAlarma build() => _state;

  void updateState(EstadoAlarma newState) {
    state = newState;
  }
}

class MockUsuariosNotifier extends NotificadorUsuarios {
  final EstadoUsuarios _state;
  MockUsuariosNotifier(this._state);

  @override
  EstadoUsuarios build() => _state;
}

class MockConexionNotifier extends NotificadorConexion {
  final EstadoConexionBackend _state;
  MockConexionNotifier(this._state);

  @override
  EstadoConexionBackend build() => _state;
}

void main() {
  group('MainLayout Widget Tests', () {
    late MockServicioAudio mockAudio;

    setUp(() {
      mockAudio = MockServicioAudio();
      ServicioAudio.instancia = mockAudio;
      when(() => mockAudio.iniciarAlarma(any())).thenAnswer((_) async {});
      when(() => mockAudio.detenerAlarma()).thenAnswer((_) async {});
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
        child: MaterialApp.router(
          routerConfig: router,
        ),
      );
    }

    testWidgets('should render children and default layout elements', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      final alarmState = EstadoAlarma.inicial();
      final usersState = EstadoUsuarios.inicial().copiarCon(cargando: false);
      final conState = EstadoConexionBackend.inicial();

      await tester.pumpWidget(
        createLayoutWithRouter(
          child: const Text('My Body Child'),
          overrides: [
            notificadorAlarmaProvider.overrideWith(() => MockAlarmaNotifier(alarmState)),
            notificadorUsuariosProvider.overrideWith(() => MockUsuariosNotifier(usersState)),
            notificadorConexionProvider.overrideWith(() => MockConexionNotifier(conState)),
          ],
        ),
      );

      expect(find.text('My Body Child'), findsOneWidget);
      expect(find.text('DataVital'), findsNothing);
      expect(find.text('ALARMA CRÍTICA'), findsNothing);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('should show BannerAlarmaCritica and trigger audio when alarm transitions to active', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      final initialAlarmState = EstadoAlarma.inicial();
      final usersState = EstadoUsuarios.inicial().copiarCon(cargando: false);
      final conState = EstadoConexionBackend.inicial();

      final notifier = MockAlarmaNotifier(initialAlarmState);

      await tester.pumpWidget(
        createLayoutWithRouter(
          child: const Text('My Body Child'),
          overrides: [
            notificadorAlarmaProvider.overrideWith(() => notifier),
            notificadorUsuariosProvider.overrideWith(() => MockUsuariosNotifier(usersState)),
            notificadorConexionProvider.overrideWith(() => MockConexionNotifier(conState)),
          ],
        ),
      );

      expect(find.text('ALARMA CRÍTICA'), findsNothing);

      // Transition state
      final activeAlarmState = EstadoAlarma.inicial().copiarCon(
        alarmaActiva: true,
        segundosRestantes: 30,
        alertasActivas: [const AlertaCritica('Frecuencia Cardíaca', 110)],
      );
      notifier.updateState(activeAlarmState);
      await tester.pump();

      // Banner should be visible
      expect(find.text('ALARMA CRÍTICA'), findsOneWidget);
      // Audio should have been triggered
      verify(() => mockAudio.iniciarAlarma(any())).called(1);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
