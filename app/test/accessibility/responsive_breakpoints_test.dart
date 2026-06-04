import 'package:datavital_flutter/core/models/ws_packet.dart';
import 'package:datavital_flutter/core/router/app_router.dart';
import 'package:datavital_flutter/core/services/servicio_audio.dart';
import 'package:datavital_flutter/core/services/websocket_service.dart';
import 'package:datavital_flutter/shared/providers/connection_provider.dart';
import 'package:datavital_flutter/shared/providers/usuario_provider.dart';
import 'package:datavital_flutter/shared/providers/vital_signs_provider.dart';
import 'package:datavital_flutter/shared/widgets/layout/app_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
  group('ResponsiveBreakpoints Accessibility Tests', () {
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

    Widget createRouterScope({List<Override> overrides = const []}) {
      return ProviderScope(
        overrides: overrides,
        child: Consumer(
          builder: (context, ref, child) {
            final router = ref.watch(routerProvider);
            return MaterialApp.router(
              routerConfig: router,
            );
          },
        ),
      );
    }

    testWidgets('should render drawer menu button and hide sidebar on mobile layout (< 600)', (tester) async {
      // 480 width is mobile and triggers esMobileChico (renders compact dot in header)
      tester.view.physicalSize = const Size(480, 800);
      tester.view.devicePixelRatio = 1.0;

      final user = TestData.usuario1;
      final usersState = EstadoUsuarios.inicial().copiarCon(
        cargando: false,
        usuarios: [user],
        usuarioActivo: user,
      );

      final connectionState = const EstadoConexionBackend(
        estadoWs: EstadoConexion.desconectado,
        wsUrl: 'ws://localhost',
        cargando: false,
      );

      final vitalSignsState = EstadoSignosVitales.inicial();

      await tester.pumpWidget(
        createRouterScope(
          overrides: [
            notificadorUsuariosProvider.overrideWith(() => MockUsuariosNotifier(usersState)),
            notificadorConexionProvider.overrideWith(() => MockConnectionNotifier(connectionState, mockWebSocketService)),
            notificadorSignosVitalesProvider.overrideWith(() => MockDashboardVitalSignsNotifier(vitalSignsState)),
          ],
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Sidebar should NOT be rendered in the mobile layout body
      expect(find.byType(AppSidebar), findsNothing);

      // Drawer menu button should be visible in the header
      final menuButton = find.byIcon(LucideIcons.menu);
      expect(menuButton, findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('should render inline sidebar and hide drawer menu button on desktop layout (>= 1200)', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      final user = TestData.usuario1;
      final usersState = EstadoUsuarios.inicial().copiarCon(
        cargando: false,
        usuarios: [user],
        usuarioActivo: user,
      );

      final connectionState = const EstadoConexionBackend(
        estadoWs: EstadoConexion.desconectado,
        wsUrl: 'ws://localhost',
        cargando: false,
      );

      final vitalSignsState = EstadoSignosVitales.inicial();

      await tester.pumpWidget(
        createRouterScope(
          overrides: [
            notificadorUsuariosProvider.overrideWith(() => MockUsuariosNotifier(usersState)),
            notificadorConexionProvider.overrideWith(() => MockConnectionNotifier(connectionState, mockWebSocketService)),
            notificadorSignosVitalesProvider.overrideWith(() => MockDashboardVitalSignsNotifier(vitalSignsState)),
          ],
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Sidebar SHOULD be rendered inline in the layout body
      expect(find.byType(AppSidebar), findsOneWidget);

      // Drawer menu button should NOT be rendered
      final menuButton = find.byIcon(LucideIcons.menu);
      expect(menuButton, findsNothing);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
