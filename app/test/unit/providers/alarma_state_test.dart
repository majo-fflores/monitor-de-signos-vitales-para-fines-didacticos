import 'package:datavital_flutter/shared/providers/alarma_state.dart';
import 'package:datavital_flutter/shared/providers/historial_alarmas_provider.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('NotificadorAlarma Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('UmbralesAlerta.defecto has correct default values', () {
      final defaults = UmbralesAlerta.defecto();
      expect(defaults.fcMin, equals(60));
      expect(defaults.fcMax, equals(100));
      expect(defaults.ppgMin, equals(60));
      expect(defaults.co2Max, equals(800));
    });

    test('initial state should be normal', () async {
      final container = createContainer();
      container.listen(notificadorAlarmaProvider, (_, __) {});
      await Future.delayed(const Duration(milliseconds: 50));

      final state = container.read(notificadorAlarmaProvider);
      expect(state.alarmaActiva, isFalse);
      expect(state.alertasActivas, isEmpty);
      expect(state.segundosRestantes, equals(0));
      expect(state.habilitada, isTrue);
      expect(state.sonidoHabilitado, isTrue);
    });

    test(
      'monitorearValores with normal readings does not trigger alarm',
      () async {
        final container = createContainer();
        container.listen(notificadorAlarmaProvider, (_, __) {});
        await Future.delayed(const Duration(milliseconds: 50));

        final notifier = container.read(notificadorAlarmaProvider.notifier);
        notifier.monitorearValores(fc: 75, ppg: 98, co2: 500);

        final state = container.read(notificadorAlarmaProvider);
        expect(state.alarmaActiva, isFalse);
        expect(state.alertasActivas, isEmpty);
      },
    );

    test('monitorearValores with abnormal FC triggers alarm', () async {
      fakeAsync((async) {
        final container = createContainer();
        container.listen(notificadorAlarmaProvider, (_, __) {});
        container.listen(historialAlarmasProvider, (_, __) {});
        async.elapse(const Duration(milliseconds: 50));

        final notifier = container.read(notificadorAlarmaProvider.notifier);
        notifier.monitorearValores(fc: 110, ppg: 98, co2: 500);

        final state = container.read(notificadorAlarmaProvider);
        expect(state.alarmaActiva, isTrue);
        expect(state.segundosRestantes, equals(15));
        expect(state.alertasActivas, hasLength(1));
        expect(
          state.alertasActivas.first.metrica,
          equals('Frecuencia Cardíaca'),
        );
        expect(state.alertasActivas.first.valor, equals(110));

        final history = container.read(historialAlarmasProvider);
        expect(history, hasLength(1));
        expect(history.first.metricas, contains('Frecuencia Cardíaca'));
      });
    });

    test('monitorearValores with multiple alerts accumulates them', () async {
      fakeAsync((async) {
        final container = createContainer();
        container.listen(notificadorAlarmaProvider, (_, __) {});
        container.listen(historialAlarmasProvider, (_, __) {});
        async.elapse(const Duration(milliseconds: 50));

        final notifier = container.read(notificadorAlarmaProvider.notifier);
        notifier.monitorearValores(fc: 110, ppg: 50, co2: 900);

        final state = container.read(notificadorAlarmaProvider);
        expect(state.alarmaActiva, isTrue);
        expect(state.alertasActivas, hasLength(3));
      });
    });

    test(
      'silenciarAlarma silences sound but keeps visual alarm running',
      () async {
        fakeAsync((async) {
          final container = createContainer();
          container.listen(notificadorAlarmaProvider, (_, __) {});
          async.elapse(const Duration(milliseconds: 50));

          final notifier = container.read(notificadorAlarmaProvider.notifier);
          notifier.monitorearValores(fc: 110, ppg: 98, co2: 500);

          var state = container.read(notificadorAlarmaProvider);
          expect(state.alarmaActiva, isTrue);
          expect(state.sonidoSilenciadoTemporalmente, isFalse);

          notifier.silenciarAlarma();

          state = container.read(notificadorAlarmaProvider);
          expect(state.alarmaActiva, isTrue);
          expect(state.sonidoSilenciadoTemporalmente, isTrue);
        });
      },
    );

    test('countdown timer decrements and auto-clears', () async {
      fakeAsync((async) {
        final container = createContainer();
        container.listen(notificadorAlarmaProvider, (_, __) {});
        container.listen(historialAlarmasProvider, (_, __) {});
        async.elapse(const Duration(milliseconds: 50));

        final notifier = container.read(notificadorAlarmaProvider.notifier);
        notifier.monitorearValores(fc: 110, ppg: 98, co2: 500);

        var state = container.read(notificadorAlarmaProvider);
        expect(state.alarmaActiva, isTrue);
        expect(state.segundosRestantes, equals(15));

        async.elapse(const Duration(seconds: 8));
        state = container.read(notificadorAlarmaProvider);
        expect(state.alarmaActiva, isTrue);
        expect(state.segundosRestantes, equals(7));

        async.elapse(const Duration(seconds: 7));
        state = container.read(notificadorAlarmaProvider);
        expect(state.alarmaActiva, isFalse);
        expect(state.segundosRestantes, equals(0));
      });
    });

    test('actualizarUmbrales persists to SharedPreferences', () async {
      final container = createContainer();
      container.listen(notificadorAlarmaProvider, (_, __) {});
      final notifier = container.read(notificadorAlarmaProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 50));

      await notifier.actualizarUmbrales(
        fcMin: 55,
        fcMax: 105,
        ppgMin: 50,
        co2Max: 850,
      );

      final state = container.read(notificadorAlarmaProvider);
      expect(state.umbrales.fcMin, equals(55));
      expect(state.umbrales.fcMax, equals(105));
      expect(state.umbrales.ppgMin, equals(50));
      expect(state.umbrales.co2Max, equals(850));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('umbral_fc_min'), equals(55));
      expect(prefs.getInt('umbral_fc_max'), equals(105));
      expect(prefs.getInt('umbral_ppg_min'), equals(50));
      expect(prefs.getInt('umbral_co2_max'), equals(850));
    });

    test(
      'cambiarHabilitacion(false) disables monitoring and clears alarm',
      () async {
        fakeAsync((async) {
          final container = createContainer();
          container.listen(notificadorAlarmaProvider, (_, __) {});
          container.listen(historialAlarmasProvider, (_, __) {});
          async.elapse(const Duration(milliseconds: 50));

          final notifier = container.read(notificadorAlarmaProvider.notifier);
          notifier.monitorearValores(fc: 110, ppg: 98, co2: 500);

          var state = container.read(notificadorAlarmaProvider);
          expect(state.alarmaActiva, isTrue);

          notifier.cambiarHabilitacion(false);

          state = container.read(notificadorAlarmaProvider);
          expect(state.alarmaActiva, isFalse);
          expect(state.habilitada, isFalse);
        });
      },
    );

    test(
      'alarma histéresis - FC mantiene alerta al retornar levemente al rango normal',
      () async {
        fakeAsync((async) {
          final container = createContainer();
          container.listen(notificadorAlarmaProvider, (_, __) {});
          async.elapse(const Duration(milliseconds: 50));

          final notifier = container.read(notificadorAlarmaProvider.notifier);

          // 1. Traspasar umbral superior de FC (fcMax = 100) -> Debe activarse la alarma
          notifier.monitorearValores(fc: 101, ppg: 98, co2: 500);
          var state = container.read(notificadorAlarmaProvider);
          expect(state.alarmaActiva, isTrue);
          expect(
            state.alertasActivas.any((a) => a.metrica == 'Frecuencia Cardíaca'),
            isTrue,
          );

          // 2. Retornar levemente a un valor normal pero dentro del margen de histéresis (ej: 99 BPM)
          // -> Debe mantenerse activa
          notifier.monitorearValores(fc: 99, ppg: 98, co2: 500);
          state = container.read(notificadorAlarmaProvider);
          expect(state.alarmaActiva, isTrue);

          // 3. Bajar por debajo del margen de histéresis (ej: 96 BPM)
          notifier.monitorearValores(fc: 96, ppg: 98, co2: 500);
          state = container.read(notificadorAlarmaProvider);
          expect(
            state.alarmaActiva,
            isTrue,
          ); // Sigue activa porque el ciclo de 15s no finalizó

          // 4. Avanzar el tiempo para que expire el ciclo de 15s
          async.elapse(const Duration(seconds: 15));
          state = container.read(notificadorAlarmaProvider);
          expect(
            state.alarmaActiva,
            isFalse,
          ); // Ya se limpia porque expiró el ciclo con valores normales
        });
      },
    );

    test(
      'alarma histéresis - CO2 mantiene alerta al retornar levemente al rango normal',
      () async {
        fakeAsync((async) {
          final container = createContainer();
          container.listen(notificadorAlarmaProvider, (_, __) {});
          async.elapse(const Duration(milliseconds: 50));

          final notifier = container.read(notificadorAlarmaProvider.notifier);

          // 1. Traspasar umbral superior de CO2 (co2Max = 800) -> Debe activarse la alarma
          notifier.monitorearValores(fc: 75, ppg: 98, co2: 805);
          var state = container.read(notificadorAlarmaProvider);
          expect(state.alarmaActiva, isTrue);
          expect(
            state.alertasActivas.any((a) => a.metrica == 'Dióxido de Carbono'),
            isTrue,
          );

          // 2. Retornar levemente a un valor normal pero dentro del margen de histéresis (ej: 790 ppm)
          // -> Debe mantenerse activa
          notifier.monitorearValores(fc: 75, ppg: 98, co2: 790);
          state = container.read(notificadorAlarmaProvider);
          expect(state.alarmaActiva, isTrue);

          // 3. Bajar por debajo del margen de histéresis (ej: 775 ppm)
          notifier.monitorearValores(fc: 75, ppg: 98, co2: 775);
          state = container.read(notificadorAlarmaProvider);
          expect(
            state.alarmaActiva,
            isTrue,
          ); // Sigue activa porque el ciclo de 15s no finalizó

          // 4. Avanzar el tiempo para que expire el ciclo de 15s
          async.elapse(const Duration(seconds: 15));
          state = container.read(notificadorAlarmaProvider);
          expect(
            state.alarmaActiva,
            isFalse,
          ); // Ya se limpia porque expiró el ciclo con valores normales
        });
      },
    );

    test(
      'alarma mantiene visualización activa por periodo completo de 15s al normalizarse',
      () async {
        fakeAsync((async) {
          final container = createContainer();
          container.listen(notificadorAlarmaProvider, (_, __) {});
          async.elapse(const Duration(milliseconds: 50));

          final notifier = container.read(notificadorAlarmaProvider.notifier);
          notifier.monitorearValores(fc: 110, ppg: 98, co2: 500);

          var state = container.read(notificadorAlarmaProvider);
          expect(state.alarmaActiva, isTrue);
          expect(state.segundosRestantes, equals(15));

          // Avanzar 5 segundos e intentar normalizar los signos
          async.elapse(const Duration(seconds: 5));
          notifier.monitorearValores(fc: 75, ppg: 98, co2: 500);
          state = container.read(notificadorAlarmaProvider);
          expect(state.alarmaActiva, isTrue); // Sigue activa
          expect(state.segundosRestantes, equals(10));

          // Avanzar 10 segundos más (total 15s desde el disparo inicial) para finalizar el ciclo
          async.elapse(const Duration(seconds: 10));
          state = container.read(notificadorAlarmaProvider);
          expect(
            state.alarmaActiva,
            isFalse,
          ); // Ya se limpia al final del ciclo
        });
      },
    );

    test(
      'descartarAlarma limpia inmediatamente el estado de la alarma',
      () async {
        fakeAsync((async) {
          final container = createContainer();
          container.listen(notificadorAlarmaProvider, (_, __) {});
          async.elapse(const Duration(milliseconds: 50));

          final notifier = container.read(notificadorAlarmaProvider.notifier);
          notifier.monitorearValores(fc: 110, ppg: 98, co2: 500);

          var state = container.read(notificadorAlarmaProvider);
          expect(state.alarmaActiva, isTrue);

          notifier.descartarAlarma();

          state = container.read(notificadorAlarmaProvider);
          expect(state.alarmaActiva, isFalse);
          expect(state.segundosRestantes, equals(0));
          expect(state.alertasActivas, isEmpty);
        });
      },
    );
  });
}
