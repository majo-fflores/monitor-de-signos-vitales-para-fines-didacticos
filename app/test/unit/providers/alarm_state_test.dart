import 'package:datavital_flutter/shared/providers/alarm_history_provider.dart';
import 'package:datavital_flutter/shared/providers/alarm_state.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('AlarmNotifier Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('AlertThresholds.defecto has correct default values', () {
      final defaults = AlertThresholds.defecto();
      expect(defaults.bpmMin, equals(60));
      expect(defaults.bpmMax, equals(100));
      expect(defaults.co2Max, equals(1600));
    });

    test('initial state should be normal', () async {
      final container = createContainer();
      container.listen(alarmNotifierProvider, (_, __) {});
      await Future.delayed(const Duration(milliseconds: 50));

      final state = container.read(alarmNotifierProvider);
      expect(state.alarmActive, isFalse);
      expect(state.activeAlerts, isEmpty);
      expect(state.secondsRemaining, equals(0));
      expect(state.isEnabled, isTrue);
      expect(state.isSoundEnabled, isTrue);
    });

    test('monitorValues with normal readings does not trigger alarm', () async {
      final container = createContainer();
      container.listen(alarmNotifierProvider, (_, __) {});
      await Future.delayed(const Duration(milliseconds: 50));

      final notifier = container.read(alarmNotifierProvider.notifier);
      notifier.monitorValues(fc: 75, co2: 500);

      final state = container.read(alarmNotifierProvider);
      expect(state.alarmActive, isFalse);
      expect(state.activeAlerts, isEmpty);
    });

    test('monitorValues with abnormal FC triggers alarm', () async {
      fakeAsync((async) {
        final container = createContainer();
        container.listen(alarmNotifierProvider, (_, __) {});
        container.listen(alarmHistoryProvider, (_, __) {});
        async.elapse(const Duration(milliseconds: 50));

        final notifier = container.read(alarmNotifierProvider.notifier);
        notifier.monitorValues(fc: 110, co2: 500);

        final state = container.read(alarmNotifierProvider);
        expect(state.alarmActive, isTrue);
        expect(state.secondsRemaining, equals(15));
        expect(state.activeAlerts, hasLength(1));
        expect(state.activeAlerts.first.metric, equals('Frecuencia Cardíaca'));
        expect(state.activeAlerts.first.value, equals(110));

        final history = container.read(alarmHistoryProvider);
        expect(history, hasLength(1));
        expect(history.first.metrics, contains('Frecuencia Cardíaca'));
      });
    });

    test('monitorValues with multiple alerts accumulates them', () async {
      fakeAsync((async) {
        final container = createContainer();
        container.listen(alarmNotifierProvider, (_, __) {});
        container.listen(alarmHistoryProvider, (_, __) {});
        async.elapse(const Duration(milliseconds: 50));

        final notifier = container.read(alarmNotifierProvider.notifier);
        notifier.monitorValues(fc: 110, co2: 1700);

        final state = container.read(alarmNotifierProvider);
        expect(state.alarmActive, isTrue);
        expect(state.activeAlerts, hasLength(2));
      });
    });

    test('muteAlarm silences sound but keeps visual alarm running', () async {
      fakeAsync((async) {
        final container = createContainer();
        container.listen(alarmNotifierProvider, (_, __) {});
        async.elapse(const Duration(milliseconds: 50));

        final notifier = container.read(alarmNotifierProvider.notifier);
        notifier.monitorValues(fc: 110, co2: 500);

        var state = container.read(alarmNotifierProvider);
        expect(state.alarmActive, isTrue);
        expect(state.isSoundTemporarilyMuted, isFalse);

        notifier.muteAlarm();

        state = container.read(alarmNotifierProvider);
        expect(state.alarmActive, isTrue);
        expect(state.isSoundTemporarilyMuted, isTrue);
      });
    });

    test('countdown timer decrements and auto-clears', () async {
      fakeAsync((async) {
        final container = createContainer();
        container.listen(alarmNotifierProvider, (_, __) {});
        container.listen(alarmHistoryProvider, (_, __) {});
        async.elapse(const Duration(milliseconds: 50));

        final notifier = container.read(alarmNotifierProvider.notifier);
        notifier.monitorValues(fc: 110, co2: 500);

        var state = container.read(alarmNotifierProvider);
        expect(state.alarmActive, isTrue);
        expect(state.secondsRemaining, equals(15));

        async.elapse(const Duration(seconds: 8));
        state = container.read(alarmNotifierProvider);
        expect(state.alarmActive, isTrue);
        expect(state.secondsRemaining, equals(7));

        async.elapse(const Duration(seconds: 7));
        state = container.read(alarmNotifierProvider);
        expect(state.alarmActive, isFalse);
        expect(state.secondsRemaining, equals(0));
      });
    });

    test('updateThresholds persists to SharedPreferences', () async {
      final container = createContainer();
      container.listen(alarmNotifierProvider, (_, __) {});
      final notifier = container.read(alarmNotifierProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 50));

      await notifier.updateThresholds(bpmMin: 55, bpmMax: 105, co2Max: 850);

      final state = container.read(alarmNotifierProvider);
      expect(state.thresholds.bpmMin, equals(55));
      expect(state.thresholds.bpmMax, equals(105));
      expect(state.thresholds.co2Max, equals(850));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('umbral_fc_min'), equals(55));
      expect(prefs.getInt('umbral_fc_max'), equals(105));
      expect(prefs.getInt('umbral_co2_max'), equals(850));
    });

    test('toggleEnabled(false) disables monitoring and clears alarm', () async {
      fakeAsync((async) {
        final container = createContainer();
        container.listen(alarmNotifierProvider, (_, __) {});
        container.listen(alarmHistoryProvider, (_, __) {});
        async.elapse(const Duration(milliseconds: 50));

        final notifier = container.read(alarmNotifierProvider.notifier);
        notifier.monitorValues(fc: 110, co2: 500);

        var state = container.read(alarmNotifierProvider);
        expect(state.alarmActive, isTrue);

        notifier.toggleEnabled(false);

        state = container.read(alarmNotifierProvider);
        expect(state.alarmActive, isFalse);
        expect(state.isEnabled, isFalse);
      });
    });

    test(
      'alarma histéresis - FC mantiene alerta al retornar levemente al rango normal',
      () async {
        fakeAsync((async) {
          final container = createContainer();
          container.listen(alarmNotifierProvider, (_, __) {});
          async.elapse(const Duration(milliseconds: 50));

          final notifier = container.read(alarmNotifierProvider.notifier);

          // 1. Traspasar umbral superior de FC (bpmMax = 100) -> Debe activarse la alarma
          notifier.monitorValues(fc: 101, co2: 500);
          var state = container.read(alarmNotifierProvider);
          expect(state.alarmActive, isTrue);
          expect(
            state.activeAlerts.any((a) => a.metric == 'Frecuencia Cardíaca'),
            isTrue,
          );

          // 2. Retornar levemente a un value normal pero dentro del margen de histéresis (ej: 99 BPM)
          // -> Debe mantenerse activa
          notifier.monitorValues(fc: 99, co2: 500);
          state = container.read(alarmNotifierProvider);
          expect(state.alarmActive, isTrue);

          // 3. Bajar por debajo del margen de histéresis (ej: 96 BPM)
          notifier.monitorValues(fc: 96, co2: 500);
          state = container.read(alarmNotifierProvider);
          expect(
            state.alarmActive,
            isTrue,
          ); // Sigue activa porque el ciclo de 15s no finalizó

          // 4. Avanzar el tiempo para que expire el ciclo de 15s
          async.elapse(const Duration(seconds: 15));
          state = container.read(alarmNotifierProvider);
          expect(
            state.alarmActive,
            isFalse,
          ); // Ya se limpia porque expiró el ciclo con valuees normales
        });
      },
    );

    test(
      'alarma histéresis - CO2 mantiene alerta al retornar levemente al rango normal',
      () async {
        fakeAsync((async) {
          final container = createContainer();
          container.listen(alarmNotifierProvider, (_, __) {});
          async.elapse(const Duration(milliseconds: 50));

          final notifier = container.read(alarmNotifierProvider.notifier);

          // 1. Traspasar umbral superior de CO2 (co2Max = 1600) -> Debe activarse la alarma
          notifier.monitorValues(fc: 75, co2: 1605);
          var state = container.read(alarmNotifierProvider);
          expect(state.alarmActive, isTrue);
          expect(
            state.activeAlerts.any((a) => a.metric == 'Dióxido de Carbono'),
            isTrue,
          );

          // 2. Retornar levemente a un value normal pero dentro del margen de histéresis (ej: 1590 ppm)
          // -> Debe mantenerse activa
          notifier.monitorValues(fc: 75, co2: 1590);
          state = container.read(alarmNotifierProvider);
          expect(state.alarmActive, isTrue);

          // 3. Bajar por debajo del margen de histéresis (ej: 1575 ppm)
          notifier.monitorValues(fc: 75, co2: 1575);
          state = container.read(alarmNotifierProvider);
          expect(
            state.alarmActive,
            isTrue,
          ); // Sigue activa porque el ciclo de 15s no finalizó

          // 4. Avanzar el tiempo para que expire el ciclo de 15s
          async.elapse(const Duration(seconds: 15));
          state = container.read(alarmNotifierProvider);
          expect(
            state.alarmActive,
            isFalse,
          ); // Ya se limpia porque expiró el ciclo con valuees normales
        });
      },
    );

    test(
      'alarma mantiene visualización activa por periodo completo de 15s al normalizarse',
      () async {
        fakeAsync((async) {
          final container = createContainer();
          container.listen(alarmNotifierProvider, (_, __) {});
          async.elapse(const Duration(milliseconds: 50));

          final notifier = container.read(alarmNotifierProvider.notifier);
          notifier.monitorValues(fc: 110, co2: 500);

          var state = container.read(alarmNotifierProvider);
          expect(state.alarmActive, isTrue);
          expect(state.secondsRemaining, equals(15));

          // Avanzar 5 segundos e intentar normalizar los signos
          async.elapse(const Duration(seconds: 5));
          notifier.monitorValues(fc: 75, co2: 500);
          state = container.read(alarmNotifierProvider);
          expect(state.alarmActive, isTrue); // Sigue activa
          expect(state.secondsRemaining, equals(10));

          // Avanzar 10 segundos más (total 15s desde el disparo inicial) para finalizar el ciclo
          async.elapse(const Duration(seconds: 10));
          state = container.read(alarmNotifierProvider);
          expect(state.alarmActive, isFalse); // Ya se limpia al final del ciclo
        });
      },
    );

    test('discardAlarm limpia inmediatamente el estado de la alarma', () async {
      fakeAsync((async) {
        final container = createContainer();
        container.listen(alarmNotifierProvider, (_, __) {});
        async.elapse(const Duration(milliseconds: 50));

        final notifier = container.read(alarmNotifierProvider.notifier);
        notifier.monitorValues(fc: 110, co2: 500);

        var state = container.read(alarmNotifierProvider);
        expect(state.alarmActive, isTrue);

        notifier.discardAlarm();

        state = container.read(alarmNotifierProvider);
        expect(state.alarmActive, isFalse);
        expect(state.secondsRemaining, equals(0));
        expect(state.activeAlerts, isEmpty);
      });
    });
  });
}
