import 'package:datavital_flutter/features/settings/widgets/display_preferences_card.dart';
import 'package:datavital_flutter/shared/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_helpers.dart';

class MockThemeNotifier extends ThemeNotifier {
  final ThemeMode _state;
  MockThemeNotifier(this._state);

  @override
  ThemeMode build() => _state;

  ThemeMode? changedTheme;

  @override
  Future<void> cambiarTema(ThemeMode modo) async {
    changedTheme = modo;
  }
}

void main() {
  group('DisplayPreferencesCard Widget Tests', () {
    testWidgets('should render titles and SegmentedButton on wide screen', (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;

      final themeNotifier = MockThemeNotifier(ThemeMode.system);

      await tester.pumpWidget(
        createTestableWidget(
          overrides: [
            themeNotifierProvider.overrideWith(() => themeNotifier),
          ],
          child: const DisplayPreferencesCard(
            subtitleColor: Colors.grey,
            borderColor: Colors.blue,
          ),
        ),
      );

      expect(find.text('Preferencias de Visualización'), findsOneWidget);
      expect(find.text('Tema de la Aplicación'), findsOneWidget);

      expect(find.text('Modo Claro'), findsOneWidget);
      expect(find.text('Modo Oscuro'), findsOneWidget);
      expect(find.text('Sistema'), findsOneWidget);

      await tester.tap(find.text('Modo Claro'));
      await tester.pump();

      expect(themeNotifier.changedTheme, equals(ThemeMode.light));

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
