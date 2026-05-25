import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'alarma_state.dart';

part 'vital_signs_provider.g.dart';

/// Punto de datos para las series de fl_chart.
/// Mapea de manera directa el tipo conceptual de Zustand { name, value: [x, y] }.
@immutable
class PuntoBiometrico {
  final double x;
  final double y;

  const PuntoBiometrico(this.x, this.y);
}

/// Estado inmutable de signos vitales (Zustand: VitalSignsState).
@immutable
class EstadoSignosVitales {
  final List<PuntoBiometrico> ecgDatos;
  final List<PuntoBiometrico> spo2Datos;
  final List<PuntoBiometrico> pcgDatos;
  final int frecuenciaCardiaca;
  final int nivelSpo2;
  final int nivelCo2;
  final int amplitudAcustica;

  const EstadoSignosVitales({
    required this.ecgDatos,
    required this.spo2Datos,
    required this.pcgDatos,
    required this.frecuenciaCardiaca,
    required this.nivelSpo2,
    required this.nivelCo2,
    required this.amplitudAcustica,
  });

  factory EstadoSignosVitales.inicial() {
    return const EstadoSignosVitales(
      ecgDatos: [],
      spo2Datos: [],
      pcgDatos: [],
      frecuenciaCardiaca: 72,
      nivelSpo2: 98,
      nivelCo2: 35,
      amplitudAcustica: 12,
    );
  }

  EstadoSignosVitales copiarCon({
    List<PuntoBiometrico>? ecgDatos,
    List<PuntoBiometrico>? spo2Datos,
    List<PuntoBiometrico>? pcgDatos,
    int? frecuenciaCardiaca,
    int? nivelSpo2,
    int? nivelCo2,
    int? amplitudAcustica,
  }) {
    return EstadoSignosVitales(
      ecgDatos: ecgDatos ?? this.ecgDatos,
      spo2Datos: spo2Datos ?? this.spo2Datos,
      pcgDatos: pcgDatos ?? this.pcgDatos,
      frecuenciaCardiaca: frecuenciaCardiaca ?? this.frecuenciaCardiaca,
      nivelSpo2: nivelSpo2 ?? this.nivelSpo2,
      nivelCo2: nivelCo2 ?? this.nivelCo2,
      amplitudAcustica: amplitudAcustica ?? this.amplitudAcustica,
    );
  }
}

/// Notifier reactivo que simula los sensores en tiempo real de forma matemática.
/// Reemplazo directo con Riverpod del store de Zustand (useVitalSignsStore).
@riverpod
class NotificadorSignosVitales extends _$NotificadorSignosVitales {
  Timer? _timer;
  double _anguloEcg = 0.0;
  double _anguloSpo2 = 0.0;
  final math.Random _random = math.Random();

  @override
  EstadoSignosVitales build() {
    // Al destruirse el notifier o desmontarse el dashboard, liberamos recursos
    ref.onDispose(() {
      detenerSimulacion();
    });
    return EstadoSignosVitales.inicial();
  }

  void iniciarSimulacion() {
    if (_timer != null) return;

    final ahora = DateTime.now().millisecondsSinceEpoch.toDouble();
    final ecgInicial = <PuntoBiometrico>[];
    final spo2Inicial = <PuntoBiometrico>[];
    final pcgInicial = <PuntoBiometrico>[];

    // Poblamos la ventana inicial de 100 puntos (equivalente a 10s con intervalos de 100ms)
    double t = ahora;
    for (int i = 0; i < 100; i++) {
      ecgInicial.add(PuntoBiometrico(t, 0.0));
      spo2Inicial.add(PuntoBiometrico(t, 50.0));
      pcgInicial.add(PuntoBiometrico(t, 0.0));
      t += 100;
    }

    state = state.copiarCon(
      ecgDatos: ecgInicial,
      spo2Datos: spo2Inicial,
      pcgDatos: pcgInicial,
    );

    // Bucle de simulación en tiempo real blando cada 100ms
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final tActual = DateTime.now().millisecondsSinceEpoch.toDouble();

      // 1. Simulación matemática de ECG (Onda rítmica con pico QRS)
      _anguloEcg += 0.5;
      final baseEcg = math.sin(_anguloEcg) * 10;
      final qrs = _random.nextDouble() > 0.92 ? 80.0 : 0.0;
      final valorEcg = baseEcg + qrs;

      // 2. Simulación SpO2 (Onda pletismográfica dicrota)
      _anguloSpo2 += 0.25;
      final valorSpo2 = (math.sin(_anguloSpo2) * 30) + (math.cos(_anguloSpo2 * 2) * 10) + 50;

      // 3. Simulación LM386 (Fonocardiograma / Señal acústica de audio)
      // Generamos un pulso rápido acústico sincronizado parcialmente con el ciclo
      final esLatidoSonido = _anguloEcg % (2 * math.pi) < 1.0;
      final valorPcg = esLatidoSonido 
          ? (math.sin(_anguloEcg * 10) * (30 + _random.nextInt(40))) 
          : (math.sin(_anguloEcg * 2) * (2 + _random.nextInt(3)));
      final nuevaAmplitud = esLatidoSonido ? 65 + _random.nextInt(20) : 10 + _random.nextInt(5);

      // 4. Fluctuaciones leves de los KPIs
      final nuevaFrecuencia = 70 + _random.nextInt(5); // 70-74 lpm
      final nuevoSpo2 = 97 + _random.nextInt(4); // 97-100%
      // El CO2 fluctúa entre 350 ppm y 450 ppm (valores normales en ambiente)
      // A veces simula un pico de alerta para testing (1 de cada 150 ticks supera 800 ppm si no hay alarma activa)
      final nuevoCo2 = _random.nextDouble() > 0.99 
          ? 850 + _random.nextInt(100) 
          : 350 + _random.nextInt(50);

      // Desplazamos las colas para mantener ventana fija (shift de arrays)
      final nuevosEcg = List<PuntoBiometrico>.from(state.ecgDatos);
      if (nuevosEcg.isNotEmpty) nuevosEcg.removeAt(0);
      nuevosEcg.add(PuntoBiometrico(tActual, valorEcg));

      final nuevosSpo2 = List<PuntoBiometrico>.from(state.spo2Datos);
      if (nuevosSpo2.isNotEmpty) nuevosSpo2.removeAt(0);
      nuevosSpo2.add(PuntoBiometrico(tActual, valorSpo2));

      final nuevosPcg = List<PuntoBiometrico>.from(state.pcgDatos);
      if (nuevosPcg.isNotEmpty) nuevosPcg.removeAt(0);
      nuevosPcg.add(PuntoBiometrico(tActual, valorPcg));

      state = state.copiarCon(
        ecgDatos: nuevosEcg,
        spo2Datos: nuevosSpo2,
        pcgDatos: nuevosPcg,
        frecuenciaCardiaca: nuevaFrecuencia,
        nivelSpo2: nuevoSpo2,
        nivelCo2: nuevoCo2,
        amplitudAcustica: nuevaAmplitud,
      );

      // Monitorear valores a través del gestor de alarmas
      ref.read(notificadorAlarmaProvider.notifier).monitorearValores(
        fc: nuevaFrecuencia,
        spo2: nuevoSpo2,
        co2: nuevoCo2,
      );
    });
  }

  void detenerSimulacion() {
    _timer?.cancel();
    _timer = null;
  }
}
