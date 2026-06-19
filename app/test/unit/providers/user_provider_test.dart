import 'package:datavital_flutter/shared/providers/user_provider.dart';
import 'package:datavital_flutter/shared/utils/local_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/mock_providers.dart';
import '../../helpers/test_data.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('UserProvider Tests', () {
    late MockUserApiService mockApiService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockApiService = MockUserApiService();
      when(() => mockApiService.getUsers()).thenAnswer((_) async => []);
    });

    test('initial state has isLoading: true', () {
      final container = createContainer(
        overrides: [userApiServiceProvider.overrideWithValue(mockApiService)],
      );
      final state = container.read(usersNotifierProvider);

      expect(state.isLoading, isTrue);
      expect(state.users, isEmpty);
      expect(state.activeUser, isNull);
    });

    test(
      'should load users from UserApiService on init and set isLoading to false',
      () async {
        final user = TestData.user1;
        when(() => mockApiService.getUsers()).thenAnswer((_) async => [user]);

        final container = createContainer(
          overrides: [userApiServiceProvider.overrideWithValue(mockApiService)],
        );
        container.listen(usersNotifierProvider, (_, __) {});

        // Wait for _cargarUsers to finish
        await Future.delayed(const Duration(milliseconds: 50));

        final state = container.read(usersNotifierProvider);
        expect(state.isLoading, isFalse);
        expect(state.users, hasLength(1));
        expect(state.users.first.id, equals(user.id));
        expect(state.activeUser, isNull); // forces re-login on startup
        verify(() => mockApiService.getUsers()).called(1);
      },
    );

    test(
      'createUser should add user to list and select it as active',
      () async {
        final user = TestData.user1;
        when(
          () => mockApiService.createUser(
            name: any(named: 'name'),
            email: any(named: 'email'),
            dni: any(named: 'dni'),
          ),
        ).thenAnswer((_) async => user);

        final container = createContainer(
          overrides: [userApiServiceProvider.overrideWithValue(mockApiService)],
        );
        container.listen(usersNotifierProvider, (_, __) {});

        await Future.delayed(const Duration(milliseconds: 50));

        final notifier = container.read(usersNotifierProvider.notifier);
        await notifier.createUser(
          name: user.name,
          email: user.email,
          dni: 12345678,
        );

        final state = container.read(usersNotifierProvider);
        expect(state.users, hasLength(1));
        expect(state.users.first.name, equals(user.name));
        expect(state.activeUser, equals(state.users.first));

        final activeId = await LocalStorage.getActiveUserId();
        expect(activeId, equals(state.users.first.id));
        verify(
          () => mockApiService.createUser(
            name: user.name,
            email: user.email,
            dni: 12345678,
          ),
        ).called(1);
      },
    );

    test('selectUser should update active user', () async {
      final user = TestData.user1;
      when(() => mockApiService.getUsers()).thenAnswer((_) async => [user]);

      final container = createContainer(
        overrides: [userApiServiceProvider.overrideWithValue(mockApiService)],
      );
      container.listen(usersNotifierProvider, (_, __) {});
      final notifier = container.read(usersNotifierProvider.notifier);

      await Future.delayed(const Duration(milliseconds: 50));

      notifier.selectUser(user);

      final state = container.read(usersNotifierProvider);
      expect(state.activeUser, equals(user));

      final activeId = await LocalStorage.getActiveUserId();
      expect(activeId, equals(user.id));
    });

    test('changeUser should deselect active user', () async {
      final user = TestData.user1;
      final container = createContainer(
        overrides: [userApiServiceProvider.overrideWithValue(mockApiService)],
      );
      container.listen(usersNotifierProvider, (_, __) {});
      final notifier = container.read(usersNotifierProvider.notifier);

      await Future.delayed(const Duration(milliseconds: 50));

      notifier.selectUser(user);
      expect(container.read(usersNotifierProvider).activeUser, equals(user));

      notifier.changeUser();

      expect(container.read(usersNotifierProvider).activeUser, isNull);
      final activeId = await LocalStorage.getActiveUserId();
      expect(activeId, isNull);
    });

    test(
      'deleteUser should remove user from list, delete data, and clear active selection',
      () async {
        final user1 = TestData.user1;
        final user2 = TestData.user2;
        when(
          () => mockApiService.getUsers(),
        ).thenAnswer((_) async => [user1, user2]);
        when(() => mockApiService.deleteUser(any())).thenAnswer((_) async {});

        final container = createContainer(
          overrides: [userApiServiceProvider.overrideWithValue(mockApiService)],
        );
        container.listen(usersNotifierProvider, (_, __) {});
        final notifier = container.read(usersNotifierProvider.notifier);

        await Future.delayed(const Duration(milliseconds: 50));

        // Select user1 as active
        notifier.selectUser(user1);
        expect(container.read(usersNotifierProvider).activeUser, equals(user1));

        // Delete user1
        await notifier.deleteUser(user1.id);

        final state = container.read(usersNotifierProvider);
        expect(state.users, hasLength(1));
        expect(state.users.first.id, equals(user2.id));
        expect(state.activeUser, isNull); // cleared because it was active

        final activeId = await LocalStorage.getActiveUserId();
        expect(activeId, isNull);
        verify(() => mockApiService.deleteUser(user1.id)).called(1);
      },
    );
  });
}
