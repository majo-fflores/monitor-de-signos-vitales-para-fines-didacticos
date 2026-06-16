import 'package:datavital_flutter/features/dashboard/widgets/wave_charts.dart';
import 'package:datavital_flutter/shared/providers/vital_signs_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChartUpdateBenchmark Performance Tests', () {
    testWidgets('high-frequency rendering benchmark', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Render the WaveCharts widget
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: WaveCharts())),
        ),
      );
      await tester.pumpAndSettle();

      final notifier = container.read(
        notificadorSignosVitalesProvider.notifier,
      );

      final stopwatch = Stopwatch()..start();

      // Simulate 50 high-frequency sensor packet data updates
      const int iterations = 50;
      for (int i = 0; i < iterations; i++) {
        // We simulate a frame-by-frame data injection
        final now = DateTime.now().millisecondsSinceEpoch.toDouble();
        final ecgDatos = List<PuntoBiometrico>.of(
          container.read(notificadorSignosVitalesProvider).ecgDatos,
        );
        if (ecgDatos.length >= 100) {
          ecgDatos.removeAt(0);
        }
        ecgDatos.add(PuntoBiometrico(now, i % 2 == 0 ? 40.0 : -10.0));

        // Inject new state
        notifier.state = container
            .read(notificadorSignosVitalesProvider)
            .copiarCon(ecgDatos: ecgDatos, frecuenciaCardiaca: 70 + (i % 5));

        // Re-render
        await tester.pump();
      }

      stopwatch.stop();
      final totalMs = stopwatch.elapsedMilliseconds;
      final avgMsPerFrame = totalMs / iterations;

      debugPrint('Benchmark results:');
      debugPrint('Total time for $iterations updates: ${totalMs}ms');
      debugPrint(
        'Average time per update/render: ${avgMsPerFrame.toStringAsFixed(2)}ms',
      );

      // Assert that rendering takes a reasonable amount of time (e.g. less than 40ms per frame in testing environment)
      expect(
        avgMsPerFrame,
        lessThan(40.0),
        reason: 'Average update time per frame should be low',
      );

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
