import 'package:datavital_flutter/features/dashboard/widgets/vital_kpi_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('VitalKpiCard Widget Tests', () {
    testWidgets('should render title, value and unit correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestableWidget(
          child: const VitalKpiCard(
            title: 'ECG',
            value: '72',
            unit: 'bpm',
            accentColor: Colors.green,
          ),
        ),
      );

      expect(find.text('ECG (BPM)'), findsOneWidget);
      expect(find.text('72'), findsOneWidget);
    });

    testWidgets('should render dual fields when secondaryValue is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestableWidget(
          child: const VitalKpiCard(
            title: 'SpO2',
            value: '98',
            unit: '%',
            accentColor: Colors.blue,
            secondaryTitle: 'PPG',
            secondaryValue: '75',
            secondaryUnit: 'bpm',
          ),
        ),
      );

      expect(find.text('SPO2 (%)'), findsOneWidget);
      expect(find.text('PPG (BPM)'), findsOneWidget);
      expect(find.text('98'), findsOneWidget);
      expect(find.text('75'), findsOneWidget);
    });
  });
}
