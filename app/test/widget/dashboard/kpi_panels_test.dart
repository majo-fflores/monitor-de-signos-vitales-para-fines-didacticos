import 'package:datavital_flutter/features/dashboard/widgets/kpi_panels.dart';
import 'package:datavital_flutter/features/dashboard/widgets/vital_kpi_card.dart';
import 'package:datavital_flutter/shared/providers/vital_signs_provider.dart';
import 'package:flutter/material.dart';
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
  group('KpiPanels Widget Tests', () {
    testWidgets('should render all 4 TarjetaKpiVital widgets', (tester) async {
      final mockState = EstadoSignosVitales.inicial().copiarCon(
        frecuenciaCardiaca: 75,
        nivelSpo2: 98,
        ppgFrecuenciaCardiaca: 76,
        nivelCo2: 450,
      );

      // Set a desktop size to test the row layout
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        createTestableWidget(
          overrides: [
            notificadorSignosVitalesProvider.overrideWith(() => MockVitalSignsNotifier(mockState)),
          ],
          child: const KpiPanels(esMobile: false),
        ),
      );

      expect(find.byType(TarjetaKpiVital), findsNWidgets(4));
      expect(find.text('75'), findsOneWidget);
      expect(find.text('98'), findsOneWidget);
      expect(find.text('76'), findsOneWidget);
      expect(find.text('450'), findsOneWidget);

      // Clean up physicalSize changes
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('should render grid layout on mobile screens', (tester) async {
      final mockState = EstadoSignosVitales.inicial().copiarCon(
        frecuenciaCardiaca: 75,
        nivelSpo2: 98,
        ppgFrecuenciaCardiaca: 76,
        nivelCo2: 450,
      );

      // Set a mobile size
      tester.view.physicalSize = const Size(500, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        createTestableWidget(
          overrides: [
            notificadorSignosVitalesProvider.overrideWith(() => MockVitalSignsNotifier(mockState)),
          ],
          child: const KpiPanels(esMobile: true),
        ),
      );

      expect(find.byType(TarjetaKpiVital), findsNWidgets(4));
      // Verifies that Column is used as layout
      expect(find.byType(Column), findsAny);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
