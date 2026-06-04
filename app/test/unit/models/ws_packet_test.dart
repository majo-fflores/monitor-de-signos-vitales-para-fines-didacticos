import 'package:datavital_flutter/core/models/ws_packet.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WsPacket Model Tests', () {
    test('fromJson should convert integer values to double', () {
      final json = {
        'type': 'bpm',
        'value': 80, // integer
        'timestamp': 1748383032000,
      };

      final packet = WsPacket.fromJson(json);

      expect(packet.type, equals('bpm'));
      expect(packet.value, equals(80.0));
      expect(packet.value, isA<double>());
      expect(packet.timestamp, equals(1748383032000));
    });

    test('fromJson should preserve double values', () {
      final json = {
        'type': 'ecg',
        'value': 1.25, // double
        'timestamp': 1748383032000,
      };

      final packet = WsPacket.fromJson(json);

      expect(packet.type, equals('ecg'));
      expect(packet.value, equals(1.25));
      expect(packet.timestamp, equals(1748383032000));
    });

    test('fromJson works with all known types', () {
      final types = ['ecg', 'spo2', 'bpm', 'co2', 'air'];
      for (final type in types) {
        final json = {
          'type': type,
          'value': 50,
          'timestamp': 1000,
        };
        final packet = WsPacket.fromJson(json);
        expect(packet.type, equals(type));
      }
    });
  });
}
