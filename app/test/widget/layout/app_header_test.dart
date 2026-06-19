import 'package:datavital_flutter/core/services/websocket_service.dart';
import 'package:datavital_flutter/shared/providers/connection_provider.dart';
import 'package:datavital_flutter/shared/providers/theme_provider.dart';
import 'package:datavital_flutter/shared/providers/user_provider.dart';
import 'package:datavital_flutter/shared/widgets/layout/app_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_data.dart';
import '../../helpers/test_helpers.dart';

class MockUsersNotifier extends UsersNotifier {
  final UsersState _state;
  MockUsersNotifier(this._state);

  @override
  UsersState build() => _state;

  bool changeUserCalled = false;

  @override
  Future<void> changeUser() async {
    changeUserCalled = true;
  }
}

class MockConexionNotifier extends ConnectionNotifier {
  final BackendConnectionState _state;
  MockConexionNotifier(this._state);

  @override
  BackendConnectionState build() => _state;
}

class MockThemeNotifier extends ThemeNotifier {
  final ThemeMode _state;
  MockThemeNotifier(this._state);

  @override
  ThemeMode build() => _state;

  bool toggleThemeCalled = false;

  @override
  Future<void> toggleTheme() async {
    toggleThemeCalled = true;
  }
}

void main() {
  group('AppHeader Widget Tests', () {
    testWidgets('should render title and status without user active', (
      tester,
    ) async {
      final usersState = UsersState.inicial().copiarCon(isLoading: false);
      final conState = BackendConnectionState.inicial();

      await tester.pumpWidget(
        createTestableWidget(
          overrides: [
            usersNotifierProvider.overrideWith(
              () => MockUsersNotifier(usersState),
            ),
            connectionNotifierProvider.overrideWith(
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
      final user = TestData.user1; // John Doe
      final usersState = UsersState.inicial().copiarCon(
        isLoading: false,
        activeUser: user,
      );
      final conState = BackendConnectionState.inicial().copiarCon(
        wsStatus: ConnectionStatus.connected,
      );

      final usersNotifier = MockUsersNotifier(usersState);

      await tester.pumpWidget(
        createTestableWidget(
          overrides: [
            usersNotifierProvider.overrideWith(() => usersNotifier),
            connectionNotifierProvider.overrideWith(
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

      expect(usersNotifier.changeUserCalled, isTrue);
    });
  });
}
