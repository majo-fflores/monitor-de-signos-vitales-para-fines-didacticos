import 'package:datavital_flutter/core/models/measurement_record.dart';
import 'package:datavital_flutter/core/models/user.dart';
import 'package:datavital_flutter/core/models/ws_packet.dart';

class TestData {
  static final user1 = User(
    id: 'user_123',
    name: 'John Doe',
    email: 'john@example.com',
    createdAt: DateTime(2026, 6, 1, 12, 0),
  );

  static final user2 = User(
    id: 'user_456',
    name: 'Jane Smith',
    email: 'jane@example.com',
    createdAt: DateTime(2026, 6, 2, 12, 0),
  );

  static final registro1 = MeasurementRecord(
    id: 'reg_1',
    userId: 'user_123',
    registeredAt: DateTime(2026, 6, 4, 10, 0),
    durationSeconds: 45,
    heartRate: 72,
    minHeartRate: 60,
    maxHeartRate: 90,
    co2Level: 380,
    minCo2: 350,
    maxCo2: 400,
    alertsTriggered: 0,
    clinicalNotes: 'Normal state',
  );

  static final registroCritico = MeasurementRecord(
    id: 'reg_critico',
    userId: 'user_123',
    registeredAt: DateTime(2026, 6, 4, 10, 5),
    durationSeconds: 120,
    heartRate: 110,
    minHeartRate: 90,
    maxHeartRate: 130,
    co2Level: 900,
    minCo2: 800,
    maxCo2: 1000,
    alertsTriggered: 3,
    clinicalNotes: 'Critical patient readings',
  );

  static final wsPacketEcg = WsPacket(
    type: 'ecg',
    value: 0.5,
    timestamp: 1748383032000,
  );

  static final wsPacketBpm = WsPacket(
    type: 'bpm',
    value: 75.0,
    timestamp: 1748383032200,
  );

  static final wsPacketCo2 = WsPacket(
    type: 'co2',
    value: 400.0,
    timestamp: 1748383032300,
  );
}
