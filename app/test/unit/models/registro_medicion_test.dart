import 'package:datavital_flutter/core/models/registro_medicion.dart';
import 'package:datavital_flutter/core/models/session.dart';
import 'package:datavital_flutter/core/models/session_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RegistroMedicion Model Tests', () {
    test(
      'RegistroMedicion.crear should generate unique ID and default fields',
      () {
        final reg = RegistroMedicion.crear(
          usuarioId: 'user_123',
          duracionSegundos: 30,
          frecuenciaCardiaca: 80,
          ppgFrecuenciaCardiaca: 82,
          nivelSpo2: 97,
          nivelCo2: 450,
        );

        expect(reg.id, isNotEmpty);
        expect(reg.usuarioId, equals('user_123'));
        expect(reg.duracionSegundos, equals(30));
        expect(reg.frecuenciaCardiaca, equals(80));
        expect(reg.ppgFrecuenciaCardiaca, equals(82));
        expect(reg.nivelSpo2, equals(97));
        expect(reg.nivelCo2, equals(450));
        expect(reg.alertasDisparadas, equals(0));
        expect(reg.notasClinicas, isEmpty);
      },
    );

    test(
      'RegistroMedicion.fromSessionWithSummary should construct correctly',
      () {
        final session = Session(
          id: 42,
          userId: 9,
          startTime: DateTime(2026, 6, 11, 10, 0, 0),
          endTime: DateTime(2026, 6, 11, 10, 5, 0),
          notes: 'Session notes test',
        );
        final summary = SessionWithSummary(
          session: session,
          avgBpm: 78.4,
          minBpm: 60.0,
          maxBpm: 120.0,
          avgEcg: -0.12,
          minEcg: -1.0,
          maxEcg: 1.0,
          avgSpo2: 98.0,
          minSpo2: 95.0,
          maxSpo2: 100.0,
          avgAir: 450.2,
          minAir: 400.0,
          maxAir: 500.0,
          alertCount: 3,
        );

        final reg = RegistroMedicion.fromSessionWithSummary(summary);

        expect(reg.id, equals('42'));
        expect(reg.usuarioId, equals('9'));
        expect(reg.fechaRegistro, equals(session.startTime));
        expect(reg.duracionSegundos, equals(300)); // 5 minutes in seconds
        expect(reg.frecuenciaCardiaca, equals(78)); // round of 78.4
        expect(reg.ppgFrecuenciaCardiaca, equals(78));
        expect(reg.nivelSpo2, equals(0)); // ignored SpO2
        expect(reg.nivelCo2, equals(450)); // round of 450.2
        expect(reg.alertasDisparadas, equals(3));
        expect(reg.notasClinicas, equals('Session notes test'));
      },
    );

    test('fromJson and toJson should perform a faithful roundtrip', () {
      final original = RegistroMedicion(
        id: 'reg_xyz',
        usuarioId: 'user_456',
        fechaRegistro: DateTime(2026, 6, 4, 15, 30),
        duracionSegundos: 150,
        frecuenciaCardiaca: 75,
        minFrecuenciaCardiaca: 60,
        maxFrecuenciaCardiaca: 90,
        ppgFrecuenciaCardiaca: 76,
        minPpgFrecuenciaCardiaca: 60,
        maxPpgFrecuenciaCardiaca: 90,
        nivelSpo2: 99,
        minSpo2: 95,
        maxSpo2: 100,
        nivelCo2: 390,
        minCo2: 350,
        maxCo2: 400,
        alertasDisparadas: 1,
        notasClinicas: 'Patient was slightly agitated',
      );

      final json = original.toJson();
      final deserialized = RegistroMedicion.fromJson(json);

      expect(deserialized.id, equals(original.id));
      expect(deserialized.usuarioId, equals(original.usuarioId));
      expect(deserialized.fechaRegistro, equals(original.fechaRegistro));
      expect(deserialized.duracionSegundos, equals(original.duracionSegundos));
      expect(
        deserialized.frecuenciaCardiaca,
        equals(original.frecuenciaCardiaca),
      );
      expect(
        deserialized.ppgFrecuenciaCardiaca,
        equals(original.ppgFrecuenciaCardiaca),
      );
      expect(deserialized.nivelSpo2, equals(original.nivelSpo2));
      expect(deserialized.nivelCo2, equals(original.nivelCo2));
      expect(
        deserialized.alertasDisparadas,
        equals(original.alertasDisparadas),
      );
      expect(deserialized.notasClinicas, equals(original.notasClinicas));
    });

    test('fromJson with optional fields missing should use defaults', () {
      final json = {
        'id': 'reg_def',
        'usuarioId': 'user_def',
        'fechaRegistro': DateTime.now().toIso8601String(),
        'duracionSegundos': 10,
        'frecuenciaCardiaca': 70,
        'nivelSpo2': 98,
        'nivelCo2': 400,
        // missing: ppgFrecuenciaCardiaca, alertasDisparadas, notasClinicas
      };

      final reg = RegistroMedicion.fromJson(json);
      expect(
        reg.ppgFrecuenciaCardiaca,
        equals(70),
      ); // falls back to frecuenciaCardiaca
      expect(reg.alertasDisparadas, equals(0));
      expect(reg.notasClinicas, equals(''));
    });

    group('duracionFormateada getter', () {
      test('should format less than 60 seconds', () {
        final reg = RegistroMedicion.crear(
          usuarioId: '1',
          duracionSegundos: 45,
          frecuenciaCardiaca: 0,
          ppgFrecuenciaCardiaca: 0,
          nivelSpo2: 0,
          nivelCo2: 0,
        );
        expect(reg.duracionFormateada, equals('45s'));
      });

      test('should format minutes and seconds', () {
        final reg = RegistroMedicion.crear(
          usuarioId: '1',
          duracionSegundos: 125,
          frecuenciaCardiaca: 0,
          ppgFrecuenciaCardiaca: 0,
          nivelSpo2: 0,
          nivelCo2: 0,
        );
        expect(reg.duracionFormateada, equals('2m 5s'));
      });

      test('should format hours and minutes', () {
        final reg = RegistroMedicion.crear(
          usuarioId: '1',
          duracionSegundos: 3725,
          frecuenciaCardiaca: 0,
          ppgFrecuenciaCardiaca: 0,
          nivelSpo2: 0,
          nivelCo2: 0,
        );
        // 3725 seconds = 1 hour, 2 minutes, 5 seconds
        // get duracionFormateada returns hours and minutes for > 3600 seconds
        expect(reg.duracionFormateada, equals('1h 2m'));
      });
    });

    test('fechaFormateada getter should format date correctly', () {
      final reg = RegistroMedicion(
        id: '1',
        usuarioId: '1',
        fechaRegistro: DateTime(2026, 6, 4, 9, 5),
        duracionSegundos: 0,
        frecuenciaCardiaca: 0,
        minFrecuenciaCardiaca: 0,
        maxFrecuenciaCardiaca: 0,
        ppgFrecuenciaCardiaca: 0,
        minPpgFrecuenciaCardiaca: 0,
        maxPpgFrecuenciaCardiaca: 0,
        nivelSpo2: 0,
        minSpo2: 0,
        maxSpo2: 0,
        nivelCo2: 0,
        minCo2: 0,
        maxCo2: 0,
        alertasDisparadas: 0,
        notasClinicas: '',
      );
      expect(reg.fechaFormateada, equals('04/06/2026 09:05'));
    });

    test('equality should be based on ID only', () {
      final regA = RegistroMedicion(
        id: 'same_reg',
        usuarioId: 'user1',
        fechaRegistro: DateTime.now(),
        duracionSegundos: 10,
        frecuenciaCardiaca: 70,
        minFrecuenciaCardiaca: 0,
        maxFrecuenciaCardiaca: 0,
        ppgFrecuenciaCardiaca: 70,
        minPpgFrecuenciaCardiaca: 0,
        maxPpgFrecuenciaCardiaca: 0,
        nivelSpo2: 98,
        minSpo2: 0,
        maxSpo2: 0,
        nivelCo2: 400,
        minCo2: 0,
        maxCo2: 0,
        alertasDisparadas: 0,
        notasClinicas: '',
      );
      final regB = RegistroMedicion(
        id: 'same_reg',
        usuarioId: 'user2',
        fechaRegistro: DateTime.now(),
        duracionSegundos: 20,
        frecuenciaCardiaca: 80,
        minFrecuenciaCardiaca: 0,
        maxFrecuenciaCardiaca: 0,
        ppgFrecuenciaCardiaca: 80,
        minPpgFrecuenciaCardiaca: 0,
        maxPpgFrecuenciaCardiaca: 0,
        nivelSpo2: 99,
        minSpo2: 0,
        maxSpo2: 0,
        nivelCo2: 500,
        minCo2: 0,
        maxCo2: 0,
        alertasDisparadas: 2,
        notasClinicas: 'diff',
      );

      expect(regA, equals(regB));
      expect(regA.hashCode, equals(regB.hashCode));
    });
  });
}
