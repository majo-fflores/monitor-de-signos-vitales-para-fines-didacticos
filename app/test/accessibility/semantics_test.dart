import 'package:datavital_flutter/core/services/websocket_service.dart';
import 'package:datavital_flutter/features/dashboard/widgets/dashboard_header.dart';
import 'package:datavital_flutter/features/dashboard/widgets/vital_kpi_card.dart';
import 'package:datavital_flutter/shared/providers/connection_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('Semantics Accessibility Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets(
      'DashboardHeader should have correct semantic labels for recording buttons',
      (tester) async {
        // Enable semantics
        final SemanticsHandle semantics = tester.ensureSemantics();

        // 1. Render DashboardHeader in initial state (not recording)
        await tester.pumpWidget(
          createTestableWidget(
            child: DashboardHeader(
              isDark: true,
              hasActiveUser: true,
              isRecording: false,
              formattedTime: '00:00',
              connectionState: const BackendConnectionState(
                wsStatus: ConnectionStatus.disconnected,
                wsUrl: 'ws://localhost',
                isLoading: false,
              ),
              onStartRecording: () {},
              onStopRecording: () {},
            ),
          ),
        );

        // Verify the start recording button has the button semantic flag and correct label
        final startBtnFinder = find.byType(FilledButton);
        expect(startBtnFinder, findsOneWidget);

        final startNode = tester.getSemantics(startBtnFinder);
        final startData = startNode.getSemanticsData();
        expect(startData.label, 'GRABAR SESIÓN');
        expect(startData.flagsCollection.isButton, isTrue);
        expect(startData.hasAction(SemanticsAction.tap), isTrue);

        // 2. Render DashboardHeader in recording state
        await tester.pumpWidget(
          createTestableWidget(
            child: DashboardHeader(
              isDark: true,
              hasActiveUser: true,
              isRecording: true,
              formattedTime: '00:05',
              connectionState: const BackendConnectionState(
                wsStatus: ConnectionStatus.disconnected,
                wsUrl: 'ws://localhost',
                isLoading: false,
              ),
              onStartRecording: () {},
              onStopRecording: () {},
            ),
          ),
        );

        // Verify the stop recording button has the button semantic flag and correct label
        final stopBtnFinder = find.byType(OutlinedButton);
        expect(stopBtnFinder, findsOneWidget);

        final stopNode = tester.getSemantics(stopBtnFinder);
        final stopData = stopNode.getSemanticsData();
        expect(stopData.label, 'DETENER (00:05)');
        expect(stopData.flagsCollection.isButton, isTrue);
        expect(stopData.hasAction(SemanticsAction.tap), isTrue);

        semantics.dispose();
      },
    );

    testWidgets(
      'VitalKpiCard should expose values and labels to screen readers',
      (tester) async {
        final SemanticsHandle semantics = tester.ensureSemantics();

        await tester.pumpWidget(
          createTestableWidget(
            child: const VitalKpiCard(
              title: 'Frecuencia Cardíaca',
              value: '72',
              unit: 'LPM',
              accentColor: Colors.red,
            ),
          ),
        );

        // Verify semantic tree contains the card label and value clearly readable
        expect(
          find.bySemanticsLabel('FRECUENCIA CARDÍACA (LPM)'),
          findsOneWidget,
        );
        expect(find.bySemanticsLabel('72'), findsOneWidget);

        semantics.dispose();
      },
    );
  });
}
