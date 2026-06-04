import 'package:datavital_flutter/core/router/app_router.dart';
import 'package:datavital_flutter/core/services/servicio_audio.dart';
import 'package:datavital_flutter/shared/providers/usuario_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/mock_providers.dart';
import '../helpers/test_data.dart';

void main() {
  group('NavigationFlow Integration Tests', () {
    late MockServicioAudio mockAudio;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockAudio = MockServicioAudio();
      ServicioAudio.instancia = mockAudio;
      when(() => mockAudio.iniciarAlarma(any())).thenAnswer((_) async {});
      when(() => mockAudio.detenerAlarma()).thenAnswer((_) async {});
    });

    Widget createRouterScope({List<Override> overrides = const []}) {
      final mockApi = MockUsuarioApiService();
      when(() => mockApi.obtenerUsuarios()).thenAnswer((_) async => []);

      return ProviderScope(
        overrides: [
          usuarioApiServiceProvider.overrideWithValue(mockApi),
          ...overrides,
        ],
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

    testWidgets('should redirect to /usuarios when starting with no active user', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createRouterScope());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Should show the gateway page
      expect(find.text('Seleccionar Usuario'), findsOneWidget);
      expect(find.text('Registrar Nuevo'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('should allow navigation when active user is selected', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      final user = TestData.usuario1;
      final usersState = EstadoUsuarios.inicial().copiarCon(
        cargando: false,
        usuarios: [user],
        usuarioActivo: user,
      );

      await tester.pumpWidget(
        createRouterScope(
          overrides: [
            notificadorUsuariosProvider.overrideWith(() => MockUsuariosNotifier(usersState)),
          ],
        ),
      );

      // Wait for build/nav
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Should be on dashboard, search for dashboard titles
      expect(find.text('Dashboard de Bioseñales'), findsOneWidget);
      expect(find.text('JD'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}

class MockUsuariosNotifier extends NotificadorUsuarios {
  final EstadoUsuarios _state;
  MockUsuariosNotifier(this._state);

  @override
  EstadoUsuarios build() => _state;
}
