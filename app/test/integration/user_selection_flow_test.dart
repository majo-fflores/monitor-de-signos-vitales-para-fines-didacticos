import 'package:datavital_flutter/core/models/user.dart';
import 'package:datavital_flutter/core/router/app_router.dart';
import 'package:datavital_flutter/core/services/audio_service.dart';
import 'package:datavital_flutter/shared/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/mock_providers.dart';

void main() {
  group('UserSelectionFlow Integration Tests', () {
    late MockAudioService mockAudio;
    late MockUserApiService mockApi;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockAudio = MockAudioService();
      mockApi = MockUserApiService();
      AudioService.instance = mockAudio;
      when(() => mockAudio.startAlarm(any())).thenAnswer((_) async {});
      when(() => mockAudio.stopAlarm()).thenAnswer((_) async {});

      // Default stub for obtaining users
      when(() => mockApi.getUsers()).thenAnswer((_) async => []);
    });

    Widget createRouterScope() {
      return ProviderScope(
        overrides: [userApiServiceProvider.overrideWithValue(mockApi)],
        child: Consumer(
          builder: (context, ref, child) {
            final router = ref.watch(routerProvider);
            return MaterialApp.router(routerConfig: router);
          },
        ),
      );
    }

    testWidgets(
      'should allow creating a user and automatically selecting it to navigate to dashboard',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;

        // Mock user creation response
        final expectedUser = User(
          id: '123',
          name: 'Maria Gimenez',
          email: 'maria@correo.com',
          dni: 12345678,
          createdAt: DateTime.now(),
        );
        when(
          () => mockApi.createUser(
            name: 'Maria Gimenez',
            email: 'maria@correo.com',
            dni: 12345678,
          ),
        ).thenAnswer((_) async => expectedUser);

        await tester.pumpWidget(createRouterScope());
        await tester.pumpAndSettle();

        // Verify we are on User Selection page
        expect(find.text('Seleccionar Usuario'), findsOneWidget);
        expect(find.text('Registrar Nuevo'), findsOneWidget);

        // Tap on the "Registrar Nuevo" segment to show form
        await tester.tap(find.text('Registrar Nuevo'));
        await tester.pumpAndSettle();

        // Enter name, DNI, email
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nombre Completo'),
          'Maria Gimenez',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'DNI'),
          '12345678',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Correo Electrónico'),
          'maria@correo.com',
        );
        await tester.pump();

        // Tap "CREAR Y SELECCIONAR"
        final submitBtn = find.widgetWithText(
          FilledButton,
          'CREAR Y SELECCIONAR',
        );
        expect(submitBtn, findsOneWidget);
        await tester.tap(submitBtn);

        // Wait for navigation and layout loading
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Should be redirected to Dashboard
        expect(find.text('Dashboard de Bioseñales'), findsOneWidget);
        expect(find.text('MG'), findsOneWidget); // Initials of Maria Gimenez

        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      },
    );
  });
}
