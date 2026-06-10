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

    test('monitorearValores with normal readings does not trigger alarm', () async {
      final container = createContainer();
      container.listen(notificadorAlarmaProvider, (_, __) {});
      await Future.delayed(const Duration(milliseconds: 50));

      final notifier = container.read(notificadorAlarmaProvider.notifier);
      notifier.monitorearValores(fc: 75, ppg: 98, co2: 500);

      final state = container.read(notificadorAlarmaProvider);
      expect(state.alarmaActiva, isFalse);
      expect(state.alertasActivas, isEmpty);
    });

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
        expect(state.segundosRestantes, equals(30));
        expect(state.alertasActivas, hasLength(1));
        expect(state.alertasActivas.first.metrica, equals('Frecuencia Cardíaca'));
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

    test('silenciarAlarma silences sound but keeps visual alarm running', () async {
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
    });

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
        expect(state.segundosRestantes, equals(30));

        async.elapse(const Duration(seconds: 15));
        state = container.read(notificadorAlarmaProvider);
        expect(state.alarmaActiva, isTrue);
        expect(state.segundosRestantes, equals(15));

        async.elapse(const Duration(seconds: 15));
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

      await notifier.actualizarUmbrales(fcMin: 55, fcMax: 105, ppgMin: 50, co2Max: 850);

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

    test('cambiarHabilitacion(false) disables monitoring and clears alarm', () async {
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
    });
  });
}
