import 'package:datavital_flutter/core/models/registro_medicion.dart';
import 'package:datavital_flutter/shared/providers/historial_provider.dart';
import 'package:datavital_flutter/shared/utils/almacenamiento_local.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_data.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('HistorialProvider Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initial state is initial', () {
      final container = createContainer();
      final state = container.read(notificadorHistorialProvider);

      expect(state.registros, isEmpty);
      expect(state.cargando, isFalse);
      expect(state.usuarioIdCargado, isNull);
    });

    test('cargarHistorial should load and sort records by date desc', () async {
      final regOld = RegistroMedicion(
        id: 'old',
        usuarioId: 'user_1',
        fechaRegistro: DateTime(2026, 6, 1),
        duracionSegundos: 10,
        frecuenciaCardiaca: 70,
        ppgFrecuenciaCardiaca: 70,
        nivelSpo2: 98,
        nivelCo2: 400,
        alertasDisparadas: 0,
        notasClinicas: '',
      );

      final regNew = RegistroMedicion(
        id: 'new',
        usuarioId: 'user_1',
        fechaRegistro: DateTime(2026, 6, 2),
        duracionSegundos: 10,
        frecuenciaCardiaca: 70,
        ppgFrecuenciaCardiaca: 70,
        nivelSpo2: 98,
        nivelCo2: 400,
        alertasDisparadas: 0,
        notasClinicas: '',
      );

      await AlmacenamientoLocal.guardarRegistros('user_1', [regOld, regNew]);

      final container = createContainer();
      final notifier = container.read(notificadorHistorialProvider.notifier);

      await notifier.cargarHistorial('user_1');

      final state = container.read(notificadorHistorialProvider);
      expect(state.cargando, isFalse);
      expect(state.usuarioIdCargado, equals('user_1'));
      expect(state.registros, hasLength(2));
      expect(state.registros[0].id, equals('new'));
      expect(state.registros[1].id, equals('old'));
    });

    test('guardarRegistro should add to state and store in local storage', () async {
      final container = createContainer();
      final notifier = container.read(notificadorHistorialProvider.notifier);

      final reg = TestData.registro1;
      await notifier.guardarRegistro(reg);

      var state = container.read(notificadorHistorialProvider);
      expect(state.registros, hasLength(1));
      expect(state.registros.first, equals(reg));

      final stored = await AlmacenamientoLocal.obtenerRegistros(reg.usuarioId);
      expect(stored, hasLength(1));
      expect(stored.first.id, equals(reg.id));
    });

    test('eliminarRegistro should filter out and update storage', () async {
      final container = createContainer();
      final notifier = container.read(notificadorHistorialProvider.notifier);

      final reg1 = TestData.registro1;
      final regCritico = TestData.registroCritico;

      await notifier.guardarRegistro(reg1);
      await notifier.guardarRegistro(regCritico);

      expect(container.read(notificadorHistorialProvider).registros, hasLength(2));

      await notifier.eliminarRegistro(reg1.id, reg1.usuarioId);

      final state = container.read(notificadorHistorialProvider);
      expect(state.registros, hasLength(1));
      expect(state.registros.first.id, equals(regCritico.id));

      final stored = await AlmacenamientoLocal.obtenerRegistros(reg1.usuarioId);
      expect(stored, hasLength(1));
      expect(stored.first.id, equals(regCritico.id));
    });

    test('limpiar should reset state to initial', () async {
      final container = createContainer();
      final notifier = container.read(notificadorHistorialProvider.notifier);

      await notifier.guardarRegistro(TestData.registro1);
      expect(container.read(notificadorHistorialProvider).registros, isNotEmpty);

      notifier.limpiar();

      final state = container.read(notificadorHistorialProvider);
      expect(state.registros, isEmpty);
      expect(state.usuarioIdCargado, isNull);
    });
  });
}
