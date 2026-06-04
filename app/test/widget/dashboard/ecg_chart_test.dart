import 'package:datavital_flutter/features/dashboard/widgets/ecg_chart.dart';
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
  group('GraficoEcg Widget Tests', () {
    testWidgets('should render ECG title and LineChart', (tester) async {
      final mockState = EstadoSignosVitales.inicial().copiarCon(
        ecgDatos: [const PuntoBiometrico(0, 50), const PuntoBiometrico(100, 60)],
        ecgActivo: true,
      );

      await tester.pumpWidget(
        createTestableWidget(
          overrides: [
            notificadorSignosVitalesProvider.overrideWith(() => MockVitalSignsNotifier(mockState)),
          ],
          child: const GraficoEcg(),
        ),
      );

      expect(find.text('Frecuencia Cardíaca (ECG)'), findsOneWidget);
      expect(find.byType(LineChart), findsOneWidget);
      expect(find.text('SENSOR DESCONECTADO'), findsNothing);
    });

    testWidgets('should render warning message when ECG is disconnected', (tester) async {
      final mockState = EstadoSignosVitales.inicial().copiarCon(
        ecgDatos: [],
        ecgActivo: false,
      );

      await tester.pumpWidget(
        createTestableWidget(
          overrides: [
            notificadorSignosVitalesProvider.overrideWith(() => MockVitalSignsNotifier(mockState)),
          ],
          child: const GraficoEcg(),
        ),
      );

      expect(find.text('SENSOR DESCONECTADO'), findsOneWidget);
    });
  });
}
