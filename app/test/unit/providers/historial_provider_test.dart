import 'package:datavital_flutter/core/models/measurement.dart';
import 'package:datavital_flutter/core/models/registro_medicion.dart';
import 'package:datavital_flutter/core/models/session.dart';
import 'package:datavital_flutter/core/models/session_summary.dart';
import 'package:datavital_flutter/core/services/measurement_api_service.dart';
import 'package:datavital_flutter/core/services/session_api_service.dart';
import 'package:datavital_flutter/shared/providers/historial_provider.dart';
import 'package:datavital_flutter/shared/providers/session_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_data.dart';
import '../../helpers/test_helpers.dart';

class FakeSessionApiService implements SessionApiService {
  @override
  String get baseUrl => '';
  @override
  http.Client get client => throw UnimplementedError();

  final List<Session> sessions = [];

  @override
  Future<Session> crearSesion(int userId) async {
    final session = Session(
      id: sessions.length + 1,
      userId: userId,
      startTime: DateTime.now(),
    );
    sessions.add(session);
    return session;
  }

  @override
  Future<Session> obtenerSesion(int id) async {
    return sessions.firstWhere((s) => s.id == id);
  }

  @override
  Future<List<Session>> obtenerSesionesDeUsuario(int userId) async {
    return sessions.where((s) => s.userId == userId).toList();
  }

  @override
  Future<void> finalizarSesion(int id, {String notes = ''}) async {
    final idx = sessions.indexWhere((s) => s.id == id);
    if (idx != -1) {
      final s = sessions[idx];
      sessions[idx] = Session(
        id: s.id,
        userId: s.userId,
        startTime: s.startTime,
        endTime: DateTime.now(),
        notes: notes,
      );
    }
  }

  @override
  Future<void> eliminarSesion(int id) async {
    sessions.removeWhere((s) => s.id == id);
  }

  @override
  Future<List<SessionWithSummary>> obtenerResumenesSesiones(int userId) async {
    return sessions.where((s) => s.userId == userId).map((s) {
      return SessionWithSummary(
        session: s,
        avgBpm: 75.0,
        minBpm: 60.0,
        maxBpm: 90.0,
        avgEcg: 75.0,
        minEcg: -1.0,
        maxEcg: 1.0,
        avgAir: 400.0,
        minAir: 380.0,
        maxAir: 450.0,
        alertCount: 0,
      );
    }).toList();
  }

  @override
  Future<SessionSummary> obtenerResumenSesion(int sessionId) async {
    final s = sessions.firstWhere((s) => s.id == sessionId);
    return SessionSummary(
      sessionId: s.id,
      notes: s.notes,
      avgBpm: 75.0,
      minBpm: 60.0,
      maxBpm: 90.0,
      avgEcg: 75.0,
      minEcg: -1.0,
      maxEcg: 1.0,
      avgAir: 400.0,
      minAir: 380.0,
      maxAir: 450.0,
      alertCount: 0,
    );
  }

  @override
  Future<String> exportarSesionCsv(int sessionId) async {
    return '';
  }
}

class FakeMeasurementApiService implements MeasurementApiService {
  @override
  String get baseUrl => '';
  @override
  http.Client get client => throw UnimplementedError();

  final List<Measurement> measurements = [];

  @override
  Future<Measurement> guardarMedicion(
    String tipo,
    int sessionId,
    List<Sample> datos,
  ) async {
    final m = Measurement(
      id: measurements.length + 1,
      sessionId: sessionId,
      datos: datos,
      createdAt: DateTime.now(),
    );
    measurements.add(m);
    return m;
  }

  @override
  Future<List<Measurement>> obtenerMedicionesPorSesion(
    String tipo,
    int sessionId,
  ) async {
    return measurements.where((m) => m.sessionId == sessionId).toList();
  }

  @override
  Future<List<Measurement>> obtenerMedicionesPorUsuario(
    String tipo,
    int userId,
  ) async {
    return measurements;
  }

  @override
  Future<void> eliminarMedicion(String tipo, int id) async {
    measurements.removeWhere((m) => m.id == id);
  }
}

void main() {
  group('HistorialProvider Tests', () {
    late FakeSessionApiService fakeSessionApi;
    late FakeMeasurementApiService fakeMeasurementApi;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      fakeSessionApi = FakeSessionApiService();
      fakeMeasurementApi = FakeMeasurementApiService();
    });

    test('initial state is initial', () {
      final container = createContainer(
        overrides: [
          sessionApiServiceProvider.overrideWith((ref) => fakeSessionApi),
          measurementApiServiceProvider.overrideWith(
            (ref) => fakeMeasurementApi,
          ),
        ],
      );
      final state = container.read(notificadorHistorialProvider);

      expect(state.registros, isEmpty);
      expect(state.cargando, isFalse);
      expect(state.usuarioIdCargado, isNull);
    });

    test('cargarHistorial should load and sort records by date desc', () async {
      final sessOld = Session(
        id: 1,
        userId: 1,
        startTime: DateTime(2026, 6, 1),
        endTime: DateTime(2026, 6, 1, 0, 0, 10),
      );
      final sessNew = Session(
        id: 2,
        userId: 1,
        startTime: DateTime(2026, 6, 2),
        endTime: DateTime(2026, 6, 2, 0, 0, 10),
      );
      fakeSessionApi.sessions.addAll([sessOld, sessNew]);

      fakeMeasurementApi.measurements.addAll([
        Measurement(
          id: 1,
          sessionId: 1,
          datos: [const Sample(timestamp: 1, value: 70)],
          createdAt: DateTime.now(),
        ),
        Measurement(
          id: 2,
          sessionId: 2,
          datos: [const Sample(timestamp: 1, value: 80)],
          createdAt: DateTime.now(),
        ),
      ]);

      final container = createContainer(
        overrides: [
          sessionApiServiceProvider.overrideWith((ref) => fakeSessionApi),
          measurementApiServiceProvider.overrideWith(
            (ref) => fakeMeasurementApi,
          ),
        ],
      );
      final notifier = container.read(notificadorHistorialProvider.notifier);

      await notifier.cargarHistorial('1');

      final state = container.read(notificadorHistorialProvider);
      expect(state.cargando, isFalse);
      expect(state.usuarioIdCargado, equals('1'));
      expect(state.registros, hasLength(2));
      expect(state.registros[0].id, equals('2'));
      expect(state.registros[1].id, equals('1'));
    });

    test('guardarRegistro should add to state', () async {
      final container = createContainer(
        overrides: [
          sessionApiServiceProvider.overrideWith((ref) => fakeSessionApi),
          measurementApiServiceProvider.overrideWith(
            (ref) => fakeMeasurementApi,
          ),
        ],
      );
      final notifier = container.read(notificadorHistorialProvider.notifier);

      final reg = TestData.registro1;
      await notifier.guardarRegistro(reg);

      var state = container.read(notificadorHistorialProvider);
      expect(state.registros, hasLength(1));
      expect(state.registros.first, equals(reg));
    });

    test('eliminarRegistro should filter out and update storage', () async {
      final container = createContainer(
        overrides: [
          sessionApiServiceProvider.overrideWith((ref) => fakeSessionApi),
          measurementApiServiceProvider.overrideWith(
            (ref) => fakeMeasurementApi,
          ),
        ],
      );
      final notifier = container.read(notificadorHistorialProvider.notifier);

      final sess1 = Session(id: 10, userId: 1, startTime: DateTime.now());
      fakeSessionApi.sessions.add(sess1);

      final reg1 = RegistroMedicion(
        id: '10',
        usuarioId: '1',
        fechaRegistro: DateTime.now(),
        duracionSegundos: 10,
        frecuenciaCardiaca: 70,
        minFrecuenciaCardiaca: 60,
        maxFrecuenciaCardiaca: 90,
        nivelCo2: 400,
        minCo2: 380,
        maxCo2: 450,
        alertasDisparadas: 0,
        notasClinicas: '',
      );

      await notifier.guardarRegistro(reg1);
      expect(
        container.read(notificadorHistorialProvider).registros,
        hasLength(1),
      );

      await notifier.eliminarRegistro('10', '1');

      final state = container.read(notificadorHistorialProvider);
      expect(state.registros, isEmpty);
      expect(fakeSessionApi.sessions, isEmpty);
    });

    test('limpiar should reset state to initial', () async {
      final container = createContainer(
        overrides: [
          sessionApiServiceProvider.overrideWith((ref) => fakeSessionApi),
          measurementApiServiceProvider.overrideWith(
            (ref) => fakeMeasurementApi,
          ),
        ],
      );
      final notifier = container.read(notificadorHistorialProvider.notifier);

      await notifier.guardarRegistro(TestData.registro1);
      expect(
        container.read(notificadorHistorialProvider).registros,
        isNotEmpty,
      );

      notifier.limpiar();

      final state = container.read(notificadorHistorialProvider);
      expect(state.registros, isEmpty);
      expect(state.usuarioIdCargado, isNull);
    });
  });
}
