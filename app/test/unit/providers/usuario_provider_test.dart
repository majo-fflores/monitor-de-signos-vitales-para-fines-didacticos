import 'package:datavital_flutter/shared/providers/usuario_provider.dart';
import 'package:datavital_flutter/shared/utils/almacenamiento_local.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/mock_providers.dart';
import '../../helpers/test_data.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('UsuarioProvider Tests', () {
    late MockUsuarioApiService mockApiService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockApiService = MockUsuarioApiService();
      when(() => mockApiService.obtenerUsuarios()).thenAnswer((_) async => []);
    });

    test('initial state has cargando: true', () {
      final container = createContainer(
        overrides: [
          usuarioApiServiceProvider.overrideWithValue(mockApiService),
        ],
      );
      final state = container.read(notificadorUsuariosProvider);

      expect(state.cargando, isTrue);
      expect(state.usuarios, isEmpty);
      expect(state.usuarioActivo, isNull);
    });

    test(
      'should load users from UsuarioApiService on init and set cargando to false',
      () async {
        final user = TestData.usuario1;
        when(
          () => mockApiService.obtenerUsuarios(),
        ).thenAnswer((_) async => [user]);

        final container = createContainer(
          overrides: [
            usuarioApiServiceProvider.overrideWithValue(mockApiService),
          ],
        );
        container.listen(notificadorUsuariosProvider, (_, __) {});

        // Wait for _cargarUsuarios to finish
        await Future.delayed(const Duration(milliseconds: 50));

        final state = container.read(notificadorUsuariosProvider);
        expect(state.cargando, isFalse);
        expect(state.usuarios, hasLength(1));
        expect(state.usuarios.first.id, equals(user.id));
        expect(state.usuarioActivo, isNull); // forces re-login on startup
        verify(() => mockApiService.obtenerUsuarios()).called(1);
      },
    );

    test(
      'crearUsuario should add user to list and select it as active',
      () async {
        final user = TestData.usuario1;
        when(
          () => mockApiService.crearUsuario(
            nombre: any(named: 'nombre'),
            email: any(named: 'email'),
            dni: any(named: 'dni'),
          ),
        ).thenAnswer((_) async => user);

        final container = createContainer(
          overrides: [
            usuarioApiServiceProvider.overrideWithValue(mockApiService),
          ],
        );
        container.listen(notificadorUsuariosProvider, (_, __) {});

        await Future.delayed(const Duration(milliseconds: 50));

        final notifier = container.read(notificadorUsuariosProvider.notifier);
        await notifier.crearUsuario(
          nombre: user.nombre,
          email: user.email,
          dni: 12345678,
        );

        final state = container.read(notificadorUsuariosProvider);
        expect(state.usuarios, hasLength(1));
        expect(state.usuarios.first.nombre, equals(user.nombre));
        expect(state.usuarioActivo, equals(state.usuarios.first));

        final activeId = await AlmacenamientoLocal.obtenerUsuarioActivoId();
        expect(activeId, equals(state.usuarios.first.id));
        verify(
          () => mockApiService.crearUsuario(
            nombre: user.nombre,
            email: user.email,
            dni: 12345678,
          ),
        ).called(1);
      },
    );

    test('seleccionarUsuario should update active user', () async {
      final user = TestData.usuario1;
      when(
        () => mockApiService.obtenerUsuarios(),
      ).thenAnswer((_) async => [user]);

      final container = createContainer(
        overrides: [
          usuarioApiServiceProvider.overrideWithValue(mockApiService),
        ],
      );
      container.listen(notificadorUsuariosProvider, (_, __) {});
      final notifier = container.read(notificadorUsuariosProvider.notifier);

      await Future.delayed(const Duration(milliseconds: 50));

      notifier.seleccionarUsuario(user);

      final state = container.read(notificadorUsuariosProvider);
      expect(state.usuarioActivo, equals(user));

      final activeId = await AlmacenamientoLocal.obtenerUsuarioActivoId();
      expect(activeId, equals(user.id));
    });

    test('cambiarUsuario should deselect active user', () async {
      final user = TestData.usuario1;
      final container = createContainer(
        overrides: [
          usuarioApiServiceProvider.overrideWithValue(mockApiService),
        ],
      );
      container.listen(notificadorUsuariosProvider, (_, __) {});
      final notifier = container.read(notificadorUsuariosProvider.notifier);

      await Future.delayed(const Duration(milliseconds: 50));

      notifier.seleccionarUsuario(user);
      expect(
        container.read(notificadorUsuariosProvider).usuarioActivo,
        equals(user),
      );

      notifier.cambiarUsuario();

      expect(container.read(notificadorUsuariosProvider).usuarioActivo, isNull);
      final activeId = await AlmacenamientoLocal.obtenerUsuarioActivoId();
      expect(activeId, isNull);
    });

    test(
      'eliminarUsuario should remove user from list, delete data, and clear active selection',
      () async {
        final user1 = TestData.usuario1;
        final user2 = TestData.usuario2;
        when(
          () => mockApiService.obtenerUsuarios(),
        ).thenAnswer((_) async => [user1, user2]);
        when(
          () => mockApiService.eliminarUsuario(any()),
        ).thenAnswer((_) async {});

        final container = createContainer(
          overrides: [
            usuarioApiServiceProvider.overrideWithValue(mockApiService),
          ],
        );
        container.listen(notificadorUsuariosProvider, (_, __) {});
        final notifier = container.read(notificadorUsuariosProvider.notifier);

        await Future.delayed(const Duration(milliseconds: 50));

        // Select user1 as active
        notifier.seleccionarUsuario(user1);
        expect(
          container.read(notificadorUsuariosProvider).usuarioActivo,
          equals(user1),
        );

        // Delete user1
        await notifier.eliminarUsuario(user1.id);

        final state = container.read(notificadorUsuariosProvider);
        expect(state.usuarios, hasLength(1));
        expect(state.usuarios.first.id, equals(user2.id));
        expect(state.usuarioActivo, isNull); // cleared because it was active

        final activeId = await AlmacenamientoLocal.obtenerUsuarioActivoId();
        expect(activeId, isNull);
        verify(() => mockApiService.eliminarUsuario(user1.id)).called(1);
      },
    );
  });
}
