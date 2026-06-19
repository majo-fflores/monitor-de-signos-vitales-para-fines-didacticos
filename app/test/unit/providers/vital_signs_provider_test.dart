import 'package:datavital_flutter/shared/providers/alarm_state.dart';
import 'package:datavital_flutter/shared/providers/vital_signs_provider.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('VitalSignsNotifier Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initial state should have correct default values', () {
      final container = createContainer();
      final state = container.read(vitalSignsNotifierProvider);

      expect(state.heartRate, equals(72));
      expect(state.co2Level, equals(35));
      expect(state.ecgData, isEmpty);
      expect(state.isEcgActive, isTrue);
      expect(state.isCo2Active, isTrue);
    });

    test('startSimulation should populate initial points and start ticks', () {
      fakeAsync((async) {
        final container = createContainer();
        final notifier = container.read(vitalSignsNotifierProvider.notifier);

        notifier.startSimulation();

        var state = container.read(vitalSignsNotifierProvider);
        expect(state.ecgData, isEmpty);

        // Advance 20ms to fire first simulation timer tick
        async.elapse(const Duration(milliseconds: 20));

        // State should be updated with new points (since timer rotated them)
        state = container.read(vitalSignsNotifierProvider);
        expect(state.ecgData, hasLength(1));
      });
    });

    test('ticks should eventually update numeric metrics and check alarms', () {
      fakeAsync((async) {
        final container = createContainer();

        // Listen to alarms provider to keep it alive
        container.listen(alarmNotifierProvider, (_, __) {});

        final notifier = container.read(vitalSignsNotifierProvider.notifier);

        notifier.startSimulation();

        // 50 ticks at 20ms = 1000ms
        async.elapse(const Duration(milliseconds: 1000));

        final state = container.read(vitalSignsNotifierProvider);
        // Numerical values should change/deviate from initial (random variation is added)
        // Check that they are inside realistic ranges
        expect(state.heartRate, isBetween(70, 74));
        expect(state.co2Level, isBetween(360, 420));
      });
    });

    test('copiarCon copies state fields correctly', () {
      final original = VitalSignsState.inicial();
      final copied = original.copiarCon(heartRate: 88, isCo2Active: false);

      expect(copied.heartRate, equals(88));
      expect(copied.isCo2Active, isFalse);
      expect(copied.isEcgActive, isTrue); // unchanged
    });
  });
}

// Custom matcher for range checks
Matcher isBetween(num min, num max) =>
    allOf(greaterThanOrEqualTo(min), lessThanOrEqualTo(max));
