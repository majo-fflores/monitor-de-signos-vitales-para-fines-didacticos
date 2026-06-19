import 'dart:convert';
import 'package:datavital_flutter/core/services/user_api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri());
  });

  group('UserApiService Tests', () {
    late MockHttpClient client;
    late UserApiService service;

    setUp(() {
      client = MockHttpClient();
      service = UserApiService(baseUrl: 'http://test.local', client: client);
    });

    test(
      'getUsers should fetch and return list of users on success (200)',
      () async {
        final backendResponse = jsonEncode([
          {
            'id': 1,
            'name': 'Alice',
            'email': 'alice@example.com',
            'created_at': '2026-06-04T12:00:00Z',
          },
          {
            'id': 2,
            'name': 'Bob',
            'email': 'bob@example.com',
            'created_at': '2026-06-04T13:00:00Z',
          },
        ]);

        when(
          () => client.get(any()),
        ).thenAnswer((_) async => http.Response(backendResponse, 200));

        final result = await service.getUsers();

        expect(result, hasLength(2));
        expect(result[0].id, equals('1'));
        expect(result[0].name, equals('Alice'));
        expect(result[0].email, equals('alice@example.com'));
        expect(result[1].id, equals('2'));
        expect(result[1].name, equals('Bob'));
      },
    );

    test('getUsers should throw exception on error (500)', () async {
      when(
        () => client.get(any()),
      ).thenAnswer((_) async => http.Response('Server Error', 500));

      expect(() => service.getUsers(), throwsException);
    });

    test(
      'createUser should post and return new user on success (201)',
      () async {
        final backendResponse = jsonEncode({
          'id': 3,
          'name': 'Charlie',
          'email': 'charlie@example.com',
          'dni': 12345678,
          'created_at': '2026-06-04T14:00:00Z',
        });

        when(
          () => client.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => http.Response(backendResponse, 201));

        final result = await service.createUser(
          name: 'Charlie',
          email: 'charlie@example.com',
          dni: 12345678,
        );

        expect(result.id, equals('3'));
        expect(result.name, equals('Charlie'));
        expect(result.email, equals('charlie@example.com'));
        expect(result.dni, equals(12345678));
      },
    );

    test(
      'createUser should throw exception with error message on bad request (400)',
      () async {
        final backendResponse = jsonEncode({'error': 'El email ya existe'});

        when(
          () => client.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => http.Response(backendResponse, 400));

        expect(
          () => service.createUser(
            name: 'Charlie',
            email: 'charlie@example.com',
            dni: 12345678,
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('El email ya existe'),
            ),
          ),
        );
      },
    );

    test(
      'getUserById should fetch and return specific user on success (200)',
      () async {
        final backendResponse = jsonEncode({
          'id': 5,
          'name': 'David',
          'email': 'david@example.com',
          'created_at': '2026-06-04T15:00:00Z',
        });

        when(
          () => client.get(any()),
        ).thenAnswer((_) async => http.Response(backendResponse, 200));

        final result = await service.getUserById('5');

        expect(result.id, equals('5'));
        expect(result.name, equals('David'));
        expect(result.email, equals('david@example.com'));
      },
    );
  });
}
