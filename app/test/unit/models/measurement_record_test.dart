import 'package:datavital_flutter/core/models/measurement_record.dart';
import 'package:datavital_flutter/core/models/session.dart';
import 'package:datavital_flutter/core/models/session_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MeasurementRecord Model Tests', () {
    test(
      'MeasurementRecord.crear should generate unique ID and default fields',
      () {
        final reg = MeasurementRecord.crear(
          userId: 'user_123',
          durationSeconds: 30,
          heartRate: 80,
          co2Level: 450,
        );

        expect(reg.id, isNotEmpty);
        expect(reg.userId, equals('user_123'));
        expect(reg.durationSeconds, equals(30));
        expect(reg.heartRate, equals(80));
        expect(reg.co2Level, equals(450));
        expect(reg.alertsTriggered, equals(0));
        expect(reg.clinicalNotes, isEmpty);
      },
    );

    test(
      'MeasurementRecord.fromSessionWithSummary should construct correctly',
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
          avgAir: 450.2,
          minAir: 400.0,
          maxAir: 500.0,
          alertCount: 3,
        );

        final reg = MeasurementRecord.fromSessionWithSummary(summary);

        expect(reg.id, equals('42'));
        expect(reg.userId, equals('9'));
        expect(reg.registeredAt, equals(session.startTime));
        expect(reg.durationSeconds, equals(300)); // 5 minutes in seconds
        expect(reg.heartRate, equals(78)); // round of 78.4
        expect(reg.co2Level, equals(450)); // round of 450.2
        expect(reg.alertsTriggered, equals(3));
        expect(reg.clinicalNotes, equals('Session notes test'));
      },
    );

    test('fromJson and toJson should perform a faithful roundtrip', () {
      final original = MeasurementRecord(
        id: 'reg_xyz',
        userId: 'user_456',
        registeredAt: DateTime(2026, 6, 4, 15, 30),
        durationSeconds: 150,
        heartRate: 75,
        minHeartRate: 60,
        maxHeartRate: 90,
        co2Level: 390,
        minCo2: 350,
        maxCo2: 400,
        alertsTriggered: 1,
        clinicalNotes: 'Patient was slightly agitated',
      );

      final json = original.toJson();
      final deserialized = MeasurementRecord.fromJson(json);

      expect(deserialized.id, equals(original.id));
      expect(deserialized.userId, equals(original.userId));
      expect(deserialized.registeredAt, equals(original.registeredAt));
      expect(deserialized.durationSeconds, equals(original.durationSeconds));
      expect(deserialized.heartRate, equals(original.heartRate));
      expect(deserialized.co2Level, equals(original.co2Level));
      expect(deserialized.alertsTriggered, equals(original.alertsTriggered));
      expect(deserialized.clinicalNotes, equals(original.clinicalNotes));
    });

    test('fromJson with optional fields missing should use defaults', () {
      final json = {
        'id': 'reg_def',
        'userId': 'user_def',
        'registeredAt': DateTime.now().toIso8601String(),
        'durationSeconds': 10,
        'heartRate': 70,
        'co2Level': 400,
        // missing: alertsTriggered, clinicalNotes
      };

      final reg = MeasurementRecord.fromJson(json);
      expect(reg.alertsTriggered, equals(0));
      expect(reg.clinicalNotes, equals(''));
    });

    group('formattedDuration getter', () {
      test('should format less than 60 seconds', () {
        final reg = MeasurementRecord.crear(
          userId: '1',
          durationSeconds: 45,
          heartRate: 0,
          co2Level: 0,
        );
        expect(reg.formattedDuration, equals('45s'));
      });

      test('should format minutes and seconds', () {
        final reg = MeasurementRecord.crear(
          userId: '1',
          durationSeconds: 125,
          heartRate: 0,
          co2Level: 0,
        );
        expect(reg.formattedDuration, equals('2m 5s'));
      });

      test('should format hours and minutes', () {
        final reg = MeasurementRecord.crear(
          userId: '1',
          durationSeconds: 3725,
          heartRate: 0,
          co2Level: 0,
        );
        // 3725 seconds = 1 hour, 2 minutes, 5 seconds
        // get formattedDuration returns hours and minutes for > 3600 seconds
        expect(reg.formattedDuration, equals('1h 2m'));
      });
    });

    test('formattedDate getter should format date correctly', () {
      final reg = MeasurementRecord(
        id: '1',
        userId: '1',
        registeredAt: DateTime(2026, 6, 4, 9, 5),
        durationSeconds: 0,
        heartRate: 0,
        minHeartRate: 0,
        maxHeartRate: 0,
        co2Level: 0,
        minCo2: 0,
        maxCo2: 0,
        alertsTriggered: 0,
        clinicalNotes: '',
      );
      expect(reg.formattedDate, equals('04/06/2026 09:05'));
    });

    test('equality should be based on ID only', () {
      final regA = MeasurementRecord(
        id: 'same_reg',
        userId: 'user1',
        registeredAt: DateTime.now(),
        durationSeconds: 10,
        heartRate: 70,
        minHeartRate: 0,
        maxHeartRate: 0,
        co2Level: 400,
        minCo2: 0,
        maxCo2: 0,
        alertsTriggered: 0,
        clinicalNotes: '',
      );
      final regB = MeasurementRecord(
        id: 'same_reg',
        userId: 'user2',
        registeredAt: DateTime.now(),
        durationSeconds: 20,
        heartRate: 80,
        minHeartRate: 0,
        maxHeartRate: 0,
        co2Level: 500,
        minCo2: 0,
        maxCo2: 0,
        alertsTriggered: 2,
        clinicalNotes: 'diff',
      );

      expect(regA, equals(regB));
      expect(regA.hashCode, equals(regB.hashCode));
    });
  });
}
