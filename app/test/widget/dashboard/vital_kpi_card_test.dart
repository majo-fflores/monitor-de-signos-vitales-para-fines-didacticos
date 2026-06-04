import 'package:datavital_flutter/features/dashboard/widgets/vital_kpi_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('TarjetaKpiVital Widget Tests', () {
    testWidgets('should render title, value and unit correctly', (tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          child: const TarjetaKpiVital(
            titulo: 'ECG',
            valor: '72',
            unidad: 'bpm',
            colorAcento: Colors.green,
          ),
        ),
      );

      expect(find.text('ECG'), findsOneWidget);
      expect(find.text('72'), findsOneWidget);
      expect(find.text('bpm'), findsOneWidget);
    });

    testWidgets('should render dual fields when valorSecundario is provided', (tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          child: const TarjetaKpiVital(
            titulo: 'SpO2',
            valor: '98',
            unidad: '%',
            colorAcento: Colors.blue,
            tituloSecundario: 'PPG',
            valorSecundario: '75',
            unidadSecundaria: 'bpm',
          ),
        ),
      );

      expect(find.text('SPO2'), findsOneWidget);
      expect(find.text('PPG'), findsOneWidget);
      expect(find.text('98'), findsOneWidget);
      expect(find.text('75'), findsOneWidget);
      expect(find.text('%'), findsOneWidget);
      expect(find.text('bpm'), findsOneWidget);
    });
  });
}
