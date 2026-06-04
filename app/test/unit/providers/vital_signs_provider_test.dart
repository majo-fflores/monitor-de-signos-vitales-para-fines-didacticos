import 'package:datavital_flutter/shared/providers/alarma_state.dart';
import 'package:datavital_flutter/shared/providers/vital_signs_provider.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('NotificadorSignosVitales Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initial state should have correct default values', () {
      final container = createContainer();
      final state = container.read(notificadorSignosVitalesProvider);

      expect(state.frecuenciaCardiaca, equals(72));
      expect(state.ppgFrecuenciaCardiaca, equals(72));
      expect(state.nivelSpo2, equals(98));
      expect(state.nivelCo2, equals(35));
      expect(state.ecgDatos, isEmpty);
      expect(state.spo2Datos, isEmpty);
      expect(state.ecgActivo, isTrue);
      expect(state.spo2Activo, isTrue);
      expect(state.co2Activo, isTrue);
    });

    test('iniciarSimulacion should populate initial points and start ticks', () {
      fakeAsync((async) {
        final container = createContainer();
        final notifier = container.read(notificadorSignosVitalesProvider.notifier);

        notifier.iniciarSimulacion();

        var state = container.read(notificadorSignosVitalesProvider);
        expect(state.ecgDatos, hasLength(100));
        expect(state.spo2Datos, hasLength(100));

        // Advance 20ms to fire first simulation timer tick
        async.elapse(const Duration(milliseconds: 20));

        // State should be updated with new points (since timer rotated them)
        state = container.read(notificadorSignosVitalesProvider);
        expect(state.ecgDatos, hasLength(100));
        expect(state.spo2Datos, hasLength(100));
      });
    });

    test('ticks should eventually update numeric metrics and check alarms', () {
      fakeAsync((async) {
        final container = createContainer();
        
        // Listen to alarms provider to keep it alive
        container.listen(notificadorAlarmaProvider, (_, __) {});
        
        final notifier = container.read(notificadorSignosVitalesProvider.notifier);

        notifier.iniciarSimulacion();

        // 50 ticks at 20ms = 1000ms
        async.elapse(const Duration(milliseconds: 1000));

        final state = container.read(notificadorSignosVitalesProvider);
        // Numerical values should change/deviate from initial (random variation is added)
        // Check that they are inside realistic ranges
        expect(state.frecuenciaCardiaca, isBetween(70, 74));
        expect(state.nivelSpo2, isBetween(97, 98));
        expect(state.nivelCo2, isBetween(360, 420));
      });
    });

    test('copiarCon copies state fields correctly', () {
      final original = EstadoSignosVitales.inicial();
      final copied = original.copiarCon(
        frecuenciaCardiaca: 88,
        nivelSpo2: 96,
        co2Activo: false,
      );

      expect(copied.frecuenciaCardiaca, equals(88));
      expect(copied.nivelSpo2, equals(96));
      expect(copied.co2Activo, isFalse);
      expect(copied.ecgActivo, isTrue); // unchanged
    });
  });
}

// Custom matcher for range checks
Matcher isBetween(num min, num max) => allOf(greaterThanOrEqualTo(min), lessThanOrEqualTo(max));
