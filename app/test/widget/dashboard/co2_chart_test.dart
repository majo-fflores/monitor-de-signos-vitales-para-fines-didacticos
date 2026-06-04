import 'package:datavital_flutter/features/dashboard/widgets/co2_chart.dart';
import 'package:datavital_flutter/shared/providers/vital_signs_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_helpers.dart';

class MockVitalSignsNotifier extends NotificadorSignosVitales {
  final EstadoSignosVitales _state;
  MockVitalSignsNotifier(this._state);

  @override
  EstadoSignosVitales build() => _state;

  @override
  void iniciarSimulacion() {}
}

void main() {
  group('GraficoCo2 Widget Tests', () {
    testWidgets('should render CO2 gauge and labels in normal state', (tester) async {
      final mockState = EstadoSignosVitales.inicial().copiarCon(
        nivelCo2: 450,
        co2Activo: true,
      );

      await tester.pumpWidget(
        createTestableWidget(
          overrides: [
            notificadorSignosVitalesProvider.overrideWith(() => MockVitalSignsNotifier(mockState)),
          ],
          child: const GraficoCo2(),
        ),
      );

      expect(find.text('450'), findsOneWidget);
      expect(find.text('EXCELENTE'), findsAny);
      expect(find.text('SENSOR DESCONECTADO'), findsNothing);
    });

    testWidgets('should render warning message when sensor is disconnected', (tester) async {
      final mockState = EstadoSignosVitales.inicial().copiarCon(
        nivelCo2: 0,
        co2Activo: false,
      );

      await tester.pumpWidget(
        createTestableWidget(
          overrides: [
            notificadorSignosVitalesProvider.overrideWith(() => MockVitalSignsNotifier(mockState)),
          ],
          child: const GraficoCo2(),
        ),
      );

      expect(find.text('SENSOR DESCONECTADO'), findsOneWidget);
    });
  });
}
