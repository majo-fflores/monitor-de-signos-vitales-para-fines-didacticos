import 'package:datavital_flutter/shared/utils/local_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LocalStorage Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('saveActiveUser should store and remove active user ID', () async {
      // Initially null
      var activeId = await LocalStorage.getActiveUserId();
      expect(activeId, isNull);

      // Save ID
      await LocalStorage.saveActiveUser('user_123');
      activeId = await LocalStorage.getActiveUserId();
      expect(activeId, equals('user_123'));

      // Save null to remove
      await LocalStorage.saveActiveUser(null);
      activeId = await LocalStorage.getActiveUserId();
      expect(activeId, isNull);
    });
  });
}
