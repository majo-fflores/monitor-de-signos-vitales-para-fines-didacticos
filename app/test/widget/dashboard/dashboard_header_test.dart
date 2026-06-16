import 'package:datavital_flutter/core/services/websocket_service.dart';
import 'package:datavital_flutter/features/dashboard/widgets/dashboard_header.dart';
import 'package:datavital_flutter/shared/providers/connection_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('DashboardHeader Widget Tests', () {
    const defaultCon = EstadoConexionBackend(
      estadoWs: EstadoConexion.desconectado,
      wsUrl: 'ws://test',
      cargando: false,
    );

    testWidgets('should render titles correctly', (tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          child: DashboardHeader(
            esOscuro: true,
            tieneUsuarioActivo: false,
            grabando: false,
            tiempoFormateado: '00:00',
            estadoConexion: defaultCon,
            onStartRecording: () {},
            onStopRecording: () {},
          ),
        ),
      );

      expect(find.text('Dashboard de Bioseñales'), findsOneWidget);
      expect(
        find.text('Visualización en tiempo real de sensores.'),
        findsOneWidget,
      );
      expect(find.text('GRABAR SESIÓN'), findsNothing);
    });

    testWidgets(
      'should show grab button when has active user and not recording',
      (tester) async {
        bool startCalled = false;

        await tester.pumpWidget(
          createTestableWidget(
            child: DashboardHeader(
              esOscuro: true,
              tieneUsuarioActivo: true,
              grabando: false,
              tiempoFormateado: '00:00',
              estadoConexion: defaultCon,
              onStartRecording: () {
                startCalled = true;
              },
              onStopRecording: () {},
            ),
          ),
        );

        final button = find.text('GRABAR SESIÓN');
        expect(button, findsOneWidget);

        await tester.tap(button);
        expect(startCalled, isTrue);
      },
    );

    testWidgets('should show stop button when recording', (tester) async {
      bool stopCalled = false;

      await tester.pumpWidget(
        createTestableWidget(
          child: DashboardHeader(
            esOscuro: true,
            tieneUsuarioActivo: true,
            grabando: true,
            tiempoFormateado: '01:45',
            estadoConexion: defaultCon,
            onStartRecording: () {},
            onStopRecording: () {
              stopCalled = true;
            },
          ),
        ),
      );

      final button = find.text('DETENER (01:45)');
      expect(button, findsOneWidget);

      await tester.tap(button);
      expect(stopCalled, isTrue);
    });
  });
}
