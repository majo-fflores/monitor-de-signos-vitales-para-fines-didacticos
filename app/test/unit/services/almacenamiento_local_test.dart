import 'package:datavital_flutter/core/models/registro_medicion.dart';
import 'package:datavital_flutter/shared/utils/almacenamiento_local.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AlmacenamientoLocal Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('guardarUsuarioActivo should store and remove active user ID', () async {
      // Initially null
      var activeId = await AlmacenamientoLocal.obtenerUsuarioActivoId();
      expect(activeId, isNull);

      // Save ID
      await AlmacenamientoLocal.guardarUsuarioActivo('user_123');
      activeId = await AlmacenamientoLocal.obtenerUsuarioActivoId();
      expect(activeId, equals('user_123'));

      // Save null to remove
      await AlmacenamientoLocal.guardarUsuarioActivo(null);
      activeId = await AlmacenamientoLocal.obtenerUsuarioActivoId();
      expect(activeId, isNull);
    });

    test('guardarRegistros and obtenerRegistros should work per-user', () async {
      final user1Regs = [
        RegistroMedicion(
          id: 'r1',
          usuarioId: 'user_1',
          fechaRegistro: DateTime(2026, 6, 4),
          duracionSegundos: 30,
          frecuenciaCardiaca: 70,
          ppgFrecuenciaCardiaca: 70,
          nivelSpo2: 98,
          nivelCo2: 400,
          alertasDisparadas: 0,
          notasClinicas: '',
        ),
      ];

      final user2Regs = [
        RegistroMedicion(
          id: 'r2',
          usuarioId: 'user_2',
          fechaRegistro: DateTime(2026, 6, 4),
          duracionSegundos: 40,
          frecuenciaCardiaca: 80,
          ppgFrecuenciaCardiaca: 80,
          nivelSpo2: 99,
          nivelCo2: 420,
          alertasDisparadas: 1,
          notasClinicas: 'Normal',
        ),
      ];

      await AlmacenamientoLocal.guardarRegistros('user_1', user1Regs);
      await AlmacenamientoLocal.guardarRegistros('user_2', user2Regs);

      final retrieved1 = await AlmacenamientoLocal.obtenerRegistros('user_1');
      final retrieved2 = await AlmacenamientoLocal.obtenerRegistros('user_2');

      expect(retrieved1, hasLength(1));
      expect(retrieved1.first.id, equals('r1'));
      expect(retrieved2, hasLength(1));
      expect(retrieved2.first.id, equals('r2'));
    });

    test('eliminarRegistrosDeUsuario should clear only that user\'s records', () async {
      final user1Regs = [
        RegistroMedicion(
          id: 'r1',
          usuarioId: 'user_1',
          fechaRegistro: DateTime.now(),
          duracionSegundos: 10,
          frecuenciaCardiaca: 70,
          ppgFrecuenciaCardiaca: 70,
          nivelSpo2: 98,
          nivelCo2: 400,
          alertasDisparadas: 0,
          notasClinicas: '',
        )
      ];

      await AlmacenamientoLocal.guardarRegistros('user_1', user1Regs);
      await AlmacenamientoLocal.eliminarRegistrosDeUsuario('user_1');

      final retrieved = await AlmacenamientoLocal.obtenerRegistros('user_1');
      expect(retrieved, isEmpty);
    });

  });
}
