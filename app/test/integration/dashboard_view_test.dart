import 'package:datavital_flutter/core/models/measurement.dart';
import 'package:datavital_flutter/core/models/session.dart';
import 'package:datavital_flutter/core/models/session_summary.dart';
import 'package:datavital_flutter/core/models/ws_packet.dart';
import 'package:datavital_flutter/core/services/audio_service.dart';
import 'package:datavital_flutter/core/services/measurement_api_service.dart';
import 'package:datavital_flutter/core/services/session_api_service.dart';
import 'package:datavital_flutter/core/services/websocket_service.dart';
import 'package:datavital_flutter/features/dashboard/views/dashboard_view.dart';
import 'package:datavital_flutter/shared/providers/connection_provider.dart';
import 'package:datavital_flutter/shared/providers/session_provider.dart';
import 'package:datavital_flutter/shared/providers/user_provider.dart';
import 'package:datavital_flutter/shared/providers/vital_signs_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/mock_providers.dart';
import '../helpers/test_data.dart';

class MockSessionApiService extends Mock implements SessionApiService {}

class MockMeasurementApiService extends Mock implements MeasurementApiService {}

class MockUsersNotifier extends UsersNotifier {
  final UsersState _state;
  MockUsersNotifier(this._state);

  @override
  UsersState build() => _state;
}

class MockDashboardVitalSignsNotifier extends VitalSignsNotifier {
  final VitalSignsState _state;
  MockDashboardVitalSignsNotifier(this._state);

  @override
  VitalSignsState build() => _state;

  @override
  void startSimulation() {}

  @override
  void startWithWebSocket(Stream<WsPacket> stream) {}
}

class MockConnectionNotifier extends ConnectionNotifier {
  final BackendConnectionState _state;
  final WebSocketService _mockWs;

  MockConnectionNotifier(this._state, this._mockWs);

  @override
  BackendConnectionState build() => _state;

  @override
  WebSocketService get wsService => _mockWs;
}

void main() {
  group('DashboardView Integration Tests', () {
    late MockAudioService mockAudio;
    late MockWebSocketService mockWebSocketService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockAudio = MockAudioService();
      mockWebSocketService = MockWebSocketService();
      AudioService.instance = mockAudio;
      when(() => mockAudio.startAlarm(any())).thenAnswer((_) async {});
      when(() => mockAudio.stopAlarm()).thenAnswer((_) async {});
    });

    testWidgets(
      'should start recording, capture periodic ticks, stop recording, and save session',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;

        final user = TestData.user1;
        final usersState = UsersState.inicial().copiarCon(
          isLoading: false,
          users: [user],
          activeUser: user,
        );

        final vitalSignsState = VitalSignsState.inicial().copiarCon(
          heartRate: 75,
          co2Level: 450,
        );

        final connectionState = const BackendConnectionState(
          wsStatus: ConnectionStatus.disconnected,
          wsUrl: 'ws://localhost',
          isLoading: false,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              usersNotifierProvider.overrideWith(
                () => MockUsersNotifier(usersState),
              ),
              connectionNotifierProvider.overrideWith(
                () => MockConnectionNotifier(
                  connectionState,
                  mockWebSocketService,
                ),
              ),
              vitalSignsNotifierProvider.overrideWith(
                () => MockDashboardVitalSignsNotifier(vitalSignsState),
              ),
              sessionApiServiceProvider.overrideWithValue(
                FakeSessionApiService(),
              ),
              measurementApiServiceProvider.overrideWithValue(
                FakeMeasurementApiService(),
              ),
            ],
            child: const MaterialApp(home: Scaffold(body: DashboardView())),
          ),
        );

        // Render view
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // 1. Verify "GRABAR SESIÓN" button exists and tap it
        final startBtn = find.text('GRABAR SESIÓN');
        expect(startBtn, findsOneWidget);
        await tester.tap(startBtn);
        await tester.pump();

        // 2. Advance time to trigger recording ticks (3 seconds)
        await tester.pump(const Duration(seconds: 1));
        await tester.pump(const Duration(seconds: 1));
        await tester.pump(const Duration(seconds: 1));

        // 3. Verify recording status (should show "DETENER (00:03)")
        final stopBtn = find.textContaining('DETENER');
        expect(stopBtn, findsOneWidget);

        // 4. Tap "DETENER"
        await tester.tap(stopBtn);
        await tester.pumpAndSettle(); // Dialog animation

        // 5. Verify Dialog is shown
        expect(find.text('Guardar Medición'), findsOneWidget);
        expect(find.text('3 s'), findsOneWidget);

        // 6. Enter clinical notes
        await tester.enterText(
          find.widgetWithText(TextField, 'Notas y Observaciones Clínicas'),
          'Patient is healthy',
        );
        await tester.pump();

        // 7. Tap "Guardar"
        final saveBtn = find.widgetWithText(FilledButton, 'Guardar');
        await tester.tap(saveBtn);
        await tester.pumpAndSettle();

        // 8. Verify the dialog is dismissed and a success SnackBar or action has run
        expect(find.text('Guardar Medición'), findsNothing);
        expect(
          find.text('Sesión de medición guardada con éxito'),
          findsOneWidget,
        );

        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      },
    );
  });
}

class FakeSessionApiService implements SessionApiService {
  @override
  String get baseUrl => '';

  @override
  http.Client get client => http.Client();

  @override
  Future<Session> createSession(int userId) async {
    return Session(id: 42, userId: userId, startTime: DateTime.now());
  }

  @override
  Future<Session> getSession(int id) async {
    return Session(id: id, userId: 1, startTime: DateTime.now());
  }

  @override
  Future<List<Session>> getSessionsByUser(int userId) async {
    return [];
  }

  @override
  Future<void> endSession(int id, {String notes = ''}) async {}

  @override
  Future<void> deleteSession(int id) async {}

  @override
  Future<List<SessionWithSummary>> getSessionSummaries(int userId) async {
    return [];
  }

  @override
  Future<SessionSummary> getSessionSummary(int sessionId) async {
    return SessionSummary(
      sessionId: sessionId,
      notes: '',
      avgBpm: 75.0,
      minBpm: 60.0,
      maxBpm: 90.0,
      avgEcg: 0.0,
      minEcg: -1.0,
      maxEcg: 1.0,
      avgAir: 450.0,
      minAir: 400.0,
      maxAir: 500.0,
      alertCount: 0,
    );
  }

  @override
  Future<String?> exportSessionCsv(int sessionId) async {
    return '';
  }
}

class FakeMeasurementApiService implements MeasurementApiService {
  @override
  String get baseUrl => '';

  @override
  http.Client get client => http.Client();

  @override
  Future<Measurement> saveMeasurement(
    String tipo,
    int sessionId,
    List<Sample> samples,
  ) async {
    return Measurement(
      id: 1,
      sessionId: sessionId,
      samples: samples,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<List<Measurement>> getMeasurementsByUser(
    String tipo,
    int userId,
  ) async {
    return [];
  }

  @override
  Future<List<Measurement>> getMeasurementsBySession(
    String tipo,
    int sessionId,
  ) async {
    return [];
  }

  @override
  Future<void> deleteMeasurement(String tipo, int id) async {}
}
