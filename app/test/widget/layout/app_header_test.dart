import 'package:datavital_flutter/core/services/websocket_service.dart';
import 'package:datavital_flutter/shared/providers/connection_provider.dart';
import 'package:datavital_flutter/shared/providers/theme_provider.dart';
import 'package:datavital_flutter/shared/providers/usuario_provider.dart';
import 'package:datavital_flutter/shared/widgets/layout/app_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_data.dart';
import '../../helpers/test_helpers.dart';

class MockUsuariosNotifier extends NotificadorUsuarios {
  final EstadoUsuarios _state;
  MockUsuariosNotifier(this._state);

  @override
  EstadoUsuarios build() => _state;

  bool cambiarUsuarioCalled = false;

  @override
  Future<void> cambiarUsuario() async {
    cambiarUsuarioCalled = true;
  }
}

class MockConexionNotifier extends NotificadorConexion {
  final EstadoConexionBackend _state;
  MockConexionNotifier(this._state);

  @override
  EstadoConexionBackend build() => _state;
}

class MockThemeNotifier extends ThemeNotifier {
  final ThemeMode _state;
  MockThemeNotifier(this._state);

  @override
  ThemeMode build() => _state;

  bool alternarTemaCalled = false;

  @override
  Future<void> alternarTema() async {
    alternarTemaCalled = true;
  }
}

void main() {
  group('AppHeader Widget Tests', () {
    testWidgets('should render title and status without user active', (
      tester,
    ) async {
      final usersState = EstadoUsuarios.inicial().copiarCon(cargando: false);
      final conState = EstadoConexionBackend.inicial();

      await tester.pumpWidget(
        createTestableWidget(
          overrides: [
            notificadorUsuariosProvider.overrideWith(
              () => MockUsuariosNotifier(usersState),
            ),
            notificadorConexionProvider.overrideWith(
              () => MockConexionNotifier(conState),
            ),
          ],
          child: const AppHeader(),
        ),
      );

      expect(find.text('DataVital'), findsNothing);
      expect(find.text('Desconectado'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsNothing);
    });

    testWidgets('should render active user initials and handle changing user', (
      tester,
    ) async {
      final user = TestData.usuario1; // John Doe
      final usersState = EstadoUsuarios.inicial().copiarCon(
        cargando: false,
        usuarioActivo: user,
      );
      final conState = EstadoConexionBackend.inicial().copiarCon(
        estadoWs: EstadoConexion.conectado,
      );

      final usersNotifier = MockUsuariosNotifier(usersState);

      await tester.pumpWidget(
        createTestableWidget(
          overrides: [
            notificadorUsuariosProvider.overrideWith(() => usersNotifier),
            notificadorConexionProvider.overrideWith(
              () => MockConexionNotifier(conState),
            ),
          ],
          child: const AppHeader(),
        ),
      );

      // Verify initials are displayed
      expect(find.text('JD'), findsOneWidget);
      expect(find.text('Conectado'), findsOneWidget);

      // Tap on the PopupMenuButton trigger (the user chip)
      await tester.tap(find.text('JD'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify popup items are shown
      expect(find.text('Cambiar Usuario'), findsOneWidget);

      // Tap on the Change User option
      await tester.tap(find.text('Cambiar Usuario'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(usersNotifier.cambiarUsuarioCalled, isTrue);
    });
  });
}
