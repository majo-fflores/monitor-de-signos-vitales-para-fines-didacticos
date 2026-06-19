import 'package:datavital_flutter/features/dashboard/widgets/co2_chart.dart';
import 'package:datavital_flutter/shared/providers/vital_signs_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_helpers.dart';

class MockVitalSignsNotifier extends VitalSignsNotifier {
  final VitalSignsState _state;
  MockVitalSignsNotifier(this._state);

  @override
  VitalSignsState build() => _state;

  @override
  void startSimulation() {}
}

void main() {
  group('Co2Chart Widget Tests', () {
    testWidgets('should render CO2 gauge and labels in normal state', (
      tester,
    ) async {
      final mockState = VitalSignsState.inicial().copiarCon(
        co2Level: 450,
        isCo2Active: true,
      );

      await tester.pumpWidget(
        createTestableWidget(
          overrides: [
            vitalSignsNotifierProvider.overrideWith(
              () => MockVitalSignsNotifier(mockState),
            ),
          ],
          child: const Co2Chart(),
        ),
      );

      expect(find.text('Respiración del Paciente (CO2)'), findsOneWidget);
      expect(find.text('SENSOR DESCONECTADO'), findsNothing);
    });

    testWidgets('should render warning message when sensor is disconnected', (
      tester,
    ) async {
      final mockState = VitalSignsState.inicial().copiarCon(
        co2Level: 0,
        isCo2Active: false,
      );

      await tester.pumpWidget(
        createTestableWidget(
          overrides: [
            vitalSignsNotifierProvider.overrideWith(
              () => MockVitalSignsNotifier(mockState),
            ),
          ],
          child: const Co2Chart(),
        ),
      );

      expect(find.text('SENSOR DESCONECTADO'), findsOneWidget);
    });
  });
}
