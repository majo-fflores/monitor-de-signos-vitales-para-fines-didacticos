import 'package:datavital_flutter/core/models/usuario.dart';
import 'package:datavital_flutter/core/router/app_router.dart';
import 'package:datavital_flutter/core/services/servicio_audio.dart';
import 'package:datavital_flutter/shared/providers/usuario_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/mock_providers.dart';

void main() {
  group('UserSelectionFlow Integration Tests', () {
    late MockServicioAudio mockAudio;
    late MockUsuarioApiService mockApi;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockAudio = MockServicioAudio();
      mockApi = MockUsuarioApiService();
      ServicioAudio.instancia = mockAudio;
      when(() => mockAudio.iniciarAlarma(any())).thenAnswer((_) async {});
      when(() => mockAudio.detenerAlarma()).thenAnswer((_) async {});
      
      // Default stub for obtaining users
      when(() => mockApi.obtenerUsuarios()).thenAnswer((_) async => []);
    });

    Widget createRouterScope() {
      return ProviderScope(
        overrides: [
          usuarioApiServiceProvider.overrideWithValue(mockApi),
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

    testWidgets('should allow creating a user and automatically selecting it to navigate to dashboard', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      // Mock user creation response
      final expectedUser = Usuario(
        id: '123',
        nombre: 'Maria Gimenez',
        email: 'maria@correo.com',
        creadoEn: DateTime.now(),
      );
      when(() => mockApi.crearUsuario(
            nombre: 'Maria Gimenez',
            email: 'maria@correo.com',
          )).thenAnswer((_) async => expectedUser);

      await tester.pumpWidget(createRouterScope());
      await tester.pumpAndSettle();

      // Verify we are on User Selection page
      expect(find.text('Seleccionar Usuario'), findsOneWidget);
      expect(find.text('Registrar Nuevo'), findsOneWidget);

      // Tap on the "Registrar Nuevo" segment to show form
      await tester.tap(find.text('Registrar Nuevo'));
      await tester.pumpAndSettle();

      // Enter name, email
      await tester.enterText(find.widgetWithText(TextFormField, 'Nombre Completo'), 'Maria Gimenez');
      await tester.enterText(find.widgetWithText(TextFormField, 'Correo Electrónico'), 'maria@correo.com');
      await tester.pump();

      // Tap "CREAR Y SELECCIONAR"
      final submitBtn = find.widgetWithText(FilledButton, 'CREAR Y SELECCIONAR');
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
    });
  });
}
