import 'package:datavital_flutter/core/router/app_router.dart';
import 'package:datavital_flutter/core/services/audio_service.dart';
import 'package:datavital_flutter/shared/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/mock_providers.dart';
import '../helpers/test_data.dart';

void main() {
  group('NavigationFlow Integration Tests', () {
    late MockAudioService mockAudio;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockAudio = MockAudioService();
      AudioService.instance = mockAudio;
      when(() => mockAudio.startAlarm(any())).thenAnswer((_) async {});
      when(() => mockAudio.stopAlarm()).thenAnswer((_) async {});
    });

    Widget createRouterScope({List<Override> overrides = const []}) {
      final mockApi = MockUserApiService();
      when(() => mockApi.getUsers()).thenAnswer((_) async => []);

      return ProviderScope(
        overrides: [
          userApiServiceProvider.overrideWithValue(mockApi),
          ...overrides,
        ],
        child: Consumer(
          builder: (context, ref, child) {
            final router = ref.watch(routerProvider);
            return MaterialApp.router(routerConfig: router);
          },
        ),
      );
    }

    testWidgets('should redirect to /users when starting with no active user', (
      tester,
    ) async {
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

    testWidgets('should allow navigation when active user is selected', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      final user = TestData.user1;
      final usersState = UsersState.inicial().copiarCon(
        isLoading: false,
        users: [user],
        activeUser: user,
      );

      await tester.pumpWidget(
        createRouterScope(
          overrides: [
            usersNotifierProvider.overrideWith(
              () => MockUsersNotifier(usersState),
            ),
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

class MockUsersNotifier extends UsersNotifier {
  final UsersState _state;
  MockUsersNotifier(this._state);

  @override
  UsersState build() => _state;
}
