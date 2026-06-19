import 'package:datavital_flutter/features/dashboard/widgets/co2_gauge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('Co2Gauge Widget Tests', () {
    testWidgets('should render value and unit correctly', (tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          child: const Co2Gauge(
            value: 450.0,
            accentColor: Colors.amber,
            size: 200.0,
            isDark: true,
          ),
        ),
      );

      expect(find.text('450'), findsOneWidget);
      expect(find.text('ppm CO₂'), findsOneWidget);
    });

    testWidgets('should adapt to size responsively', (tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          child: const Co2Gauge(
            value: 800.0,
            accentColor: Colors.amber,
            size: 150.0,
            isDark: false,
          ),
        ),
      );

      // Find the specific SizedBox wrapping our Co2Gauge
      final sizedBoxFinder = find.byWidgetPredicate(
        (widget) =>
            widget is SizedBox &&
            widget.width == 150.0 &&
            widget.height == 150.0,
      );
      expect(sizedBoxFinder, findsOneWidget);
    });
  });
}
