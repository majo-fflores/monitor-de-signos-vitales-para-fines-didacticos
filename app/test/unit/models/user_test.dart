import 'package:datavital_flutter/core/models/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('User Model Tests', () {
    test('User.crear should generate a unique ID and correct fields', () {
      final user = User.crear(name: 'John Doe', email: 'john@example.com');

      expect(user.id, isNotEmpty);
      expect(user.name, equals('John Doe'));
      expect(user.email, equals('john@example.com'));
      expect(
        user.createdAt.isBefore(DateTime.now().add(const Duration(seconds: 1))),
        isTrue,
      );
    });

    test('fromJson and toJson should be a faithful roundtrip', () {
      final original = User(
        id: 'user_123',
        name: 'Jane Smith',
        email: 'jane@example.com',
        dni: 12345678,
        createdAt: DateTime(2026, 6, 1, 10, 30),
      );

      final json = original.toJson();
      final deserialized = User.fromJson(json);

      expect(deserialized.id, equals(original.id));
      expect(deserialized.name, equals(original.name));
      expect(deserialized.email, equals(original.email));
      expect(deserialized.dni, equals(original.dni));
      expect(deserialized.createdAt, equals(original.createdAt));
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

        final user = User.fromBackendJson(backendJson);
        expect(user.id, equals('42'));
        expect(user.name, equals('Bob Ross'));
        expect(user.email, equals('bob@joyofpainting.com'));
        expect(user.dni, equals(12345678));
        expect(
          user.createdAt.toIso8601String(),
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
        'name': 'No Email User',
        'email': null,
        'createdAt': DateTime.now().toIso8601String(),
      };

      final user = User.fromJson(json);
      expect(user.email, equals(''));
    });

    group('initials getter', () {
      test('should return uppercase first letters for multiple names', () {
        final user = User(
          id: '1',
          name: 'john fitzgerald kennedy',
          email: '',
          createdAt: DateTime.now(),
        );
        // "john" -> 'J', "fitzgerald" -> 'F'
        expect(user.initials, equals('JF'));
      });

      test('should return first letter uppercase for single name', () {
        final user = User(
          id: '1',
          name: 'alice',
          email: '',
          createdAt: DateTime.now(),
        );
        expect(user.initials, equals('A'));
      });

      test('should return ? for empty name', () {
        final user = User(
          id: '1',
          name: '   ',
          email: '',
          createdAt: DateTime.now(),
        );
        expect(user.initials, equals('?'));
      });
    });

    test('equality should be based on ID only', () {
      final userA = User(
        id: 'same_id',
        name: 'User A',
        email: 'a@example.com',
        createdAt: DateTime.now(),
      );

      final userB = User(
        id: 'same_id',
        name: 'User B',
        email: 'b@example.com',
        createdAt: DateTime.now(),
      );

      final userC = User(
        id: 'diff_id',
        name: 'User A',
        email: 'a@example.com',
        createdAt: DateTime.now(),
      );

      expect(userA, equals(userB));
      expect(userA.hashCode, equals(userB.hashCode));
      expect(userA, isNot(equals(userC)));
    });
  });
}
