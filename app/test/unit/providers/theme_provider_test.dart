import 'package:datavital_flutter/shared/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('ThemeProvider Tests', () {
    test('initial state should be ThemeMode.system by default', () {
      SharedPreferences.setMockInitialValues({});
      final container = createContainer();
      final theme = container.read(themeNotifierProvider);

      expect(theme, equals(ThemeMode.system));
    });

    test(
      'should load theme mode string from SharedPreferences on init',
      () async {
        SharedPreferences.setMockInitialValues({'tema_modo_str': 'light'});

        final container = createContainer();
        // Listen to keep provider alive
        container.listen(themeNotifierProvider, (_, __) {});

        // Wait for unawaited _initPrefs to finish
        await Future.delayed(const Duration(milliseconds: 50));

        final theme = container.read(themeNotifierProvider);
        expect(theme, equals(ThemeMode.light));
      },
    );

    test(
      'should load legacy bool theme on init if string mode not set',
      () async {
        SharedPreferences.setMockInitialValues({'tema_oscuro': true});

        final container = createContainer();
        // Listen to keep provider alive
        container.listen(themeNotifierProvider, (_, __) {});

        // Wait for unawaited _initPrefs to finish
        await Future.delayed(const Duration(milliseconds: 50));

        final theme = container.read(themeNotifierProvider);
        expect(theme, equals(ThemeMode.dark));
      },
    );

    test('changeTheme should update state and persist value', () async {
      SharedPreferences.setMockInitialValues({});
      final container = createContainer();
      // Listen to keep provider alive
      container.listen(themeNotifierProvider, (_, __) {});
      final notifier = container.read(themeNotifierProvider.notifier);

      // Wait for unawaited _initPrefs to finish
      await Future.delayed(const Duration(milliseconds: 50));

      await notifier.changeTheme(ThemeMode.light);
      expect(container.read(themeNotifierProvider), equals(ThemeMode.light));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('tema_modo_str'), equals('light'));
    });

    test('toggleTheme should toggle between light and dark', () async {
      SharedPreferences.setMockInitialValues({});
      final container = createContainer();
      // Listen to keep provider alive
      container.listen(themeNotifierProvider, (_, __) {});
      final notifier = container.read(themeNotifierProvider.notifier);

      // Wait for unawaited _initPrefs to finish
      await Future.delayed(const Duration(milliseconds: 50));

      // Initially ThemeMode.system -> AlternarTema should toggle to ThemeMode.dark
      await notifier.toggleTheme();
      expect(container.read(themeNotifierProvider), equals(ThemeMode.dark));

      // Alternar from dark should toggle to light
      await notifier.toggleTheme();
      expect(container.read(themeNotifierProvider), equals(ThemeMode.light));
    });
  });
}
