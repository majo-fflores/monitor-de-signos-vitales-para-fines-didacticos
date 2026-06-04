import 'package:datavital_flutter/core/models/ws_packet.dart';
import 'package:datavital_flutter/core/services/servicio_audio.dart';
import 'package:datavital_flutter/core/services/websocket_service.dart';
import 'package:datavital_flutter/features/dashboard/views/dashboard_view.dart';
import 'package:datavital_flutter/shared/providers/connection_provider.dart';
import 'package:datavital_flutter/shared/providers/usuario_provider.dart';
import 'package:datavital_flutter/shared/providers/vital_signs_provider.dart';
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

class MockDashboardVitalSignsNotifier extends NotificadorSignosVitales {
  final EstadoSignosVitales _state;
  MockDashboardVitalSignsNotifier(this._state);

  @override
  EstadoSignosVitales build() => _state;

  @override
  void iniciarSimulacion() {}

  @override
  void iniciarConWebSocket(Stream<WsPacket> stream) {}
}

class MockConnectionNotifier extends NotificadorConexion {
  final EstadoConexionBackend _state;
  final WebSocketService _mockWs;

  MockConnectionNotifier(this._state, this._mockWs);

  @override
  EstadoConexionBackend build() => _state;

  @override
  WebSocketService get wsService => _mockWs;
}

void main() {
  group('DashboardView Integration Tests', () {
    late MockServicioAudio mockAudio;
    late MockWebSocketService mockWebSocketService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockAudio = MockServicioAudio();
      mockWebSocketService = MockWebSocketService();
      ServicioAudio.instancia = mockAudio;
      when(() => mockAudio.iniciarAlarma(any())).thenAnswer((_) async {});
      when(() => mockAudio.detenerAlarma()).thenAnswer((_) async {});
    });

    testWidgets('should start recording, capture periodic ticks, stop recording, and save session', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      final user = TestData.usuario1;
      final usersState = EstadoUsuarios.inicial().copiarCon(
        cargando: false,
        usuarios: [user],
        usuarioActivo: user,
      );

      final vitalSignsState = EstadoSignosVitales.inicial().copiarCon(
        frecuenciaCardiaca: 75,
        ppgFrecuenciaCardiaca: 76,
        nivelSpo2: 98,
        nivelCo2: 450,
      );

      final connectionState = const EstadoConexionBackend(
        estadoWs: EstadoConexion.desconectado,
        wsUrl: 'ws://localhost',
        cargando: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificadorUsuariosProvider.overrideWith(() => MockUsuariosNotifier(usersState)),
            notificadorConexionProvider.overrideWith(() => MockConnectionNotifier(connectionState, mockWebSocketService)),
            notificadorSignosVitalesProvider.overrideWith(() => MockDashboardVitalSignsNotifier(vitalSignsState)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: DashboardView(),
            ),
          ),
        ),
      );

      // Render view
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // 1. Verify "GRABAR SESIÓN" button exists and tap it
      final startBtn = find.text('GRABAR SESIÓN');
      expect(startBtn, findsOneWidget);
      await tester.tap(startBtn);
      await tester.pump();

      // 2. Advance time to trigger recording ticks (3 seconds)
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      // 3. Verify recording status (should show "DETENER (00:03)")
      final stopBtn = find.textContaining('DETENER');
      expect(stopBtn, findsOneWidget);

      // 4. Tap "DETENER"
      await tester.tap(stopBtn);
      await tester.pumpAndSettle(); // Dialog animation

      // 5. Verify Dialog is shown
      expect(find.text('Guardar Medición'), findsOneWidget);
      expect(find.textContaining('Duración: 3 segundos'), findsOneWidget);

      // 6. Enter clinical notes
      await tester.enterText(find.widgetWithText(TextField, 'Notas y Observaciones Clínicas'), 'Patient is healthy');
      await tester.pump();

      // 7. Tap "Guardar"
      final saveBtn = find.widgetWithText(FilledButton, 'Guardar');
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      // 8. Verify the dialog is dismissed and a success SnackBar or action has run
      expect(find.text('Guardar Medición'), findsNothing);
      expect(find.text('Sesión de medición guardada con éxito'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
