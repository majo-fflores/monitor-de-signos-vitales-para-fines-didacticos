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
  });
}
