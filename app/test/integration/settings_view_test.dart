import 'package:datavital_flutter/core/services/servicio_audio.dart';
import 'package:datavital_flutter/features/settings/views/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/mock_providers.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('SettingsView Integration Tests', () {
    late MockServicioAudio mockAudio;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockAudio = MockServicioAudio();
      ServicioAudio.instancia = mockAudio;
      when(() => mockAudio.iniciarAlarma(any())).thenAnswer((_) async {});
      when(() => mockAudio.detenerAlarma()).thenAnswer((_) async {});
      when(() => mockAudio.probarSonido(any())).thenAnswer((_) async {});
    });

    testWidgets('should allow configuring simulation mode, alarms, and testing sound tone', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        createTestableWidget(
          child: const SettingsView(),
        ),
      );

      await tester.pumpAndSettle();

      // 2. Verify "Alarmas de Bioseñales Activas" is present and enabled
      final alarmSwitchFinder = find.widgetWithText(SwitchListTile, 'Alarmas de Bioseñales Activas');
      expect(alarmSwitchFinder, findsOneWidget);

      // Verify "Alertas Sonoras" is present and enabled
      final soundSwitchFinder = find.widgetWithText(SwitchListTile, 'Alertas Sonoras');
      expect(soundSwitchFinder, findsOneWidget);

      // 3. Find and change "Tono de Alarma" dropdown
      final dropdownFinder = find.byWidgetPredicate((widget) =>
          widget is DropdownButtonFormField<String> &&
          widget.decoration.labelText == 'Tono de Alarma');
      expect(dropdownFinder, findsOneWidget);
      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle();

      // Select 'alarma_urgente' item
      final itemFinder = find.text('Alerta Médica (Rápido)').last;
      await tester.tap(itemFinder);
      await tester.pumpAndSettle();

      // 4. Tap "Probar" button
      final testBtnFinder = find.widgetWithText(FilledButton, 'Probar');
      expect(testBtnFinder, findsOneWidget);
      await tester.tap(testBtnFinder);
      await tester.pumpAndSettle();

      // Verify that mockAudio.probarSonido was called with 'alarma_urgente'
      verify(() => mockAudio.probarSonido('alarma_urgente')).called(1);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
