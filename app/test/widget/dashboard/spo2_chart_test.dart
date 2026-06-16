import 'package:datavital_flutter/features/dashboard/widgets/spo2_chart.dart';
import 'package:datavital_flutter/shared/providers/vital_signs_provider.dart';
import 'package:fl_chart/fl_chart.dart';
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
  group('GraficoSpo2 Widget Tests', () {
    testWidgets('should render SpO2 title and LineChart', (tester) async {
      final mockState = EstadoSignosVitales.inicial().copiarCon(
        spo2Datos: [
          const PuntoBiometrico(0, 98),
          const PuntoBiometrico(100, 97),
        ],
        spo2Activo: true,
      );

      await tester.pumpWidget(
        createTestableWidget(
          overrides: [
            notificadorSignosVitalesProvider.overrideWith(
              () => MockVitalSignsNotifier(mockState),
            ),
          ],
          child: const GraficoSpo2(),
        ),
      );

      expect(find.text('Saturación de Oxígeno (SpO2)'), findsOneWidget);
      expect(find.byType(LineChart), findsOneWidget);
      expect(find.text('SENSOR DESCONECTADO'), findsNothing);
    });

    testWidgets('should render warning message when SpO2 is disconnected', (
      tester,
    ) async {
      final mockState = EstadoSignosVitales.inicial().copiarCon(
        spo2Datos: [],
        spo2Activo: false,
      );

      await tester.pumpWidget(
        createTestableWidget(
          overrides: [
            notificadorSignosVitalesProvider.overrideWith(
              () => MockVitalSignsNotifier(mockState),
            ),
          ],
          child: const GraficoSpo2(),
        ),
      );

      expect(find.text('SENSOR DESCONECTADO'), findsOneWidget);
    });
  });
}
