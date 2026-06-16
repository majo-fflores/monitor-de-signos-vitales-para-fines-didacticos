import 'package:datavital_flutter/core/models/usuario.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Usuario Model Tests', () {
    test('Usuario.crear should generate a unique ID and correct fields', () {
      final user = Usuario.crear(nombre: 'John Doe', email: 'john@example.com');

      expect(user.id, isNotEmpty);
      expect(user.nombre, equals('John Doe'));
      expect(user.email, equals('john@example.com'));
      expect(
        user.creadoEn.isBefore(DateTime.now().add(const Duration(seconds: 1))),
        isTrue,
      );
    });

    test('fromJson and toJson should be a faithful roundtrip', () {
      final original = Usuario(
        id: '123',
        nombre: 'Jane Smith',
        email: 'jane@example.com',
        dni: 12345678,
        creadoEn: DateTime(2026, 6, 1, 10, 30),
      );

      final json = original.toJson();
      final deserialized = Usuario.fromJson(json);

      expect(deserialized.id, equals(original.id));
      expect(deserialized.nombre, equals(original.nombre));
      expect(deserialized.email, equals(original.email));
      expect(deserialized.dni, equals(original.dni));
      expect(deserialized.creadoEn, equals(original.creadoEn));
    });

    test(
      'fromBackendJson and toBackendJson should correctly parse and serialize backend data',
      () {
        final backendJson = {
          'id': 42,
          'name': 'Bob Ross',
          'email': 'bob@joyofpainting.com',
          'dni': 12345678,
          'created_at': '2026-06-04T12:00:00.000Z',
        };

        final user = Usuario.fromBackendJson(backendJson);
        expect(user.id, equals('42'));
        expect(user.nombre, equals('Bob Ross'));
        expect(user.email, equals('bob@joyofpainting.com'));
        expect(user.dni, equals(12345678));
        expect(
          user.creadoEn.toIso8601String(),
          startsWith('2026-06-04T12:00:00'),
        );

        final toBackend = user.toBackendJson();
        expect(toBackend['name'], equals('Bob Ross'));
        expect(toBackend['email'], equals('bob@joyofpainting.com'));
        expect(toBackend['dni'], equals(12345678));
        expect(toBackend.containsKey('id'), isFalse);
      },
    );

    test('fromJson with null email should fall back to empty string', () {
      final json = {
        'id': 'user_abc',
        'nombre': 'No Email User',
        'email': null,
        'creadoEn': DateTime.now().toIso8601String(),
      };

      final user = Usuario.fromJson(json);
      expect(user.email, equals(''));
    });

    group('iniciales getter', () {
      test('should return uppercase first letters for multiple names', () {
        final user = Usuario(
          id: '1',
          nombre: 'john fitzgerald kennedy',
          email: '',
          creadoEn: DateTime.now(),
        );
        // "john" -> 'J', "fitzgerald" -> 'F'
        expect(user.iniciales, equals('JF'));
      });

      test('should return first letter uppercase for single name', () {
        final user = Usuario(
          id: '1',
          nombre: 'alice',
          email: '',
          creadoEn: DateTime.now(),
        );
        expect(user.iniciales, equals('A'));
      });

      test('should return ? for empty name', () {
        final user = Usuario(
          id: '1',
          nombre: '   ',
          email: '',
          creadoEn: DateTime.now(),
        );
        expect(user.iniciales, equals('?'));
      });
    });

    test('equality should be based on ID only', () {
      final userA = Usuario(
        id: 'same_id',
        nombre: 'User A',
        email: 'a@example.com',
        creadoEn: DateTime.now(),
      );

      final userB = Usuario(
        id: 'same_id',
        nombre: 'User B',
        email: 'b@example.com',
        creadoEn: DateTime.now(),
      );

      final userC = Usuario(
        id: 'diff_id',
        nombre: 'User A',
        email: 'a@example.com',
        creadoEn: DateTime.now(),
      );

      expect(userA, equals(userB));
      expect(userA.hashCode, equals(userB.hashCode));
      expect(userA, isNot(equals(userC)));
    });
  });
}
