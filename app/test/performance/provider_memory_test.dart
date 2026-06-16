import 'package:datavital_flutter/shared/providers/alarma_state.dart';
import 'package:datavital_flutter/shared/providers/vital_signs_provider.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ProviderMemory Performance Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('should clean up all simulation timers and prevent leaks on dispose', () {
      fakeAsync((async) {
        final container = ProviderContainer();

        // Trigger loading of vital signs provider and connections
        final notifier = container.read(
          notificadorSignosVitalesProvider.notifier,
        );

        // Start simulation which schedules periodic timers
        notifier.iniciarSimulacion();

        // Let some ticks execute
        async.elapse(const Duration(milliseconds: 100));

        // Verify that there are pending timers scheduled in the fake async zone
        expect(
          async.pendingTimers.length,
          greaterThan(0),
          reason: 'Active simulation should have pending timers',
        );

        // Dispose the container which triggers ref.onDispose and cleanup
        container.dispose();

        // Verify that all timers are canceled and no pending timers remain
        expect(
          async.pendingTimers.length,
          equals(0),
          reason:
              'Disposing container should cancel all simulation timers to prevent memory leaks',
        );
      });
    });

    test('should clean up all alarm timers on dispose', () {
      fakeAsync((async) {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Listen to the provider to keep it alive (prevent auto-dispose)
        container.listen(notificadorAlarmaProvider, (_, __) {});

        final alarmNotifier = container.read(
          notificadorAlarmaProvider.notifier,
        );
        // Let async initialization of SharedPreferences finish
        async.elapse(const Duration(milliseconds: 100));

        // Monitorear critical values to trigger/fire the alarm count-down timer
        alarmNotifier.monitorearValores(fc: 120, ppg: 90, co2: 1200);

        // Let count-down start
        async.elapse(const Duration(seconds: 2));

        // Check if there is a pending timer for count-down
        expect(
          async.pendingTimers.length,
          greaterThan(0),
          reason: 'Triggered alarms should have an active count-down timer',
        );

        // Dispose container
        container.dispose();

        // Check that alarm countdown timers are cleaned up
        expect(
          async.pendingTimers.length,
          equals(0),
          reason: 'Disposing container should cancel alarm timers',
        );
      });
    });
  });
}
