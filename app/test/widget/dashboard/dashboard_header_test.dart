import 'package:datavital_flutter/core/services/websocket_service.dart';
import 'package:datavital_flutter/features/dashboard/widgets/dashboard_header.dart';
import 'package:datavital_flutter/shared/providers/connection_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('DashboardHeader Widget Tests', () {
    const defaultCon = BackendConnectionState(
      wsStatus: ConnectionStatus.disconnected,
      wsUrl: 'ws://test',
      isLoading: false,
    );

    testWidgets('should render titles correctly', (tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          child: DashboardHeader(
            isDark: true,
            hasActiveUser: false,
            isRecording: false,
            formattedTime: '00:00',
            connectionState: defaultCon,
            onStartRecording: () {},
            onStopRecording: () {},
          ),
        ),
      );

      expect(find.text('Dashboard de Bioseñales'), findsOneWidget);
      expect(
        find.text('Visualización en tiempo real de sensores.'),
        findsOneWidget,
      );
      expect(find.text('GRABAR SESIÓN'), findsNothing);
    });

    testWidgets(
      'should show grab button when has active user and not recording',
      (tester) async {
        bool startCalled = false;

        await tester.pumpWidget(
          createTestableWidget(
            child: DashboardHeader(
              isDark: true,
              hasActiveUser: true,
              isRecording: false,
              formattedTime: '00:00',
              connectionState: defaultCon,
              onStartRecording: () {
                startCalled = true;
              },
              onStopRecording: () {},
            ),
          ),
        );

        final button = find.text('GRABAR SESIÓN');
        expect(button, findsOneWidget);

        await tester.tap(button);
        expect(startCalled, isTrue);
      },
    );

    testWidgets('should show stop button when recording', (tester) async {
      bool stopCalled = false;

      await tester.pumpWidget(
        createTestableWidget(
          child: DashboardHeader(
            isDark: true,
            hasActiveUser: true,
            isRecording: true,
            formattedTime: '01:45',
            connectionState: defaultCon,
            onStartRecording: () {},
            onStopRecording: () {
              stopCalled = true;
            },
          ),
        ),
      );

      final button = find.text('DETENER (01:45)');
      expect(button, findsOneWidget);

      await tester.tap(button);
      expect(stopCalled, isTrue);
    });
  });
}
