import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'alarma_state.g.dart';

@immutable
class UmbralesAlerta {
  final int fcMin;
  final int fcMax;
  final int spo2Min;
  final int co2Max;

  const UmbralesAlerta({
    required this.fcMin,
    required this.fcMax,
    required this.spo2Min,
    required this.co2Max,
  });

  factory UmbralesAlerta.defecto() {
    return const UmbralesAlerta(
      fcMin: 60,
      fcMax: 100,
      spo2Min: 95,
      co2Max: 800,
    );
  }

  UmbralesAlerta copiarCon({
    int? fcMin,
    int? fcMax,
    int? spo2Min,
    int? co2Max,
  }) {
    return UmbralesAlerta(
      fcMin: fcMin ?? this.fcMin,
      fcMax: fcMax ?? this.fcMax,
      spo2Min: spo2Min ?? this.spo2Min,
      co2Max: co2Max ?? this.co2Max,
    );
  }
}

@immutable
class EstadoAlarma {
  final UmbralesAlerta umbrales;
  final bool alarmaActiva;
  final int segundosRestantes;
  final String? metricaCritica;
  final int? valorCritico;

  const EstadoAlarma({
    required this.umbrales,
    required this.alarmaActiva,
    required this.segundosRestantes,
    this.metricaCritica,
    this.valorCritico,
  });

  factory EstadoAlarma.inicial() {
    return EstadoAlarma(
      umbrales: UmbralesAlerta.defecto(),
      alarmaActiva: false,
      segundosRestantes: 0,
    );
  }

  EstadoAlarma copiarCon({
    UmbralesAlerta? umbrales,
    bool? alarmaActiva,
    int? segundosRestantes,
    String? metricaCritica,
    int? valorCritico,
  }) {
    return EstadoAlarma(
      umbrales: umbrales ?? this.umbrales,
      alarmaActiva: alarmaActiva ?? this.alarmaActiva,
      segundosRestantes: segundosRestantes ?? this.segundosRestantes,
      metricaCritica: metricaCritica ?? this.metricaCritica,
      valorCritico: valorCritico ?? this.valorCritico,
    );
  }
}

@riverpod
class NotificadorAlarma extends _$NotificadorAlarma {
  Timer? _timerRegresivo;
  SharedPreferences? _prefs;

  @override
  EstadoAlarma build() {
    _cargarUmbrales();
    ref.onDispose(() {
      _timerRegresivo?.cancel();
    });
    return EstadoAlarma.inicial();
  }

  Future<void> _cargarUmbrales() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final fcMin = _prefs?.getInt('umbral_fc_min') ?? 60;
      final fcMax = _prefs?.getInt('umbral_fc_max') ?? 100;
      final spo2Min = _prefs?.getInt('umbral_spo2_min') ?? 95;
      final co2Max = _prefs?.getInt('umbral_co2_max') ?? 800;

      state = state.copiarCon(
        umbrales: UmbralesAlerta(
          fcMin: fcMin,
          fcMax: fcMax,
          spo2Min: spo2Min,
          co2Max: co2Max,
        ),
      );
    } catch (e) {
      debugPrint('Error cargando SharedPreferences: $e');
    }
  }

  Future<void> actualizarUmbrales({
    int? fcMin,
    int? fcMax,
    int? spo2Min,
    int? co2Max,
  }) async {
    final nuevosUmbrales = state.umbrales.copiarCon(
      fcMin: fcMin,
      fcMax: fcMax,
      spo2Min: spo2Min,
      co2Max: co2Max,
    );

    state = state.copiarCon(umbrales: nuevosUmbrales);

    // Persistencia local (con vista a sincronizar vía HTTP/REST en Go en el futuro)
    if (fcMin != null) await _prefs?.setInt('umbral_fc_min', fcMin);
    if (fcMax != null) await _prefs?.setInt('umbral_fc_max', fcMax);
    if (spo2Min != null) await _prefs?.setInt('umbral_spo2_min', spo2Min);
    if (co2Max != null) await _prefs?.setInt('umbral_co2_max', co2Max);
  }

  /// Evalúa si los valores actuales están fuera de los umbrales.
  /// Se ejecuta cada vez que el simulador actualiza los datos.
  void monitorearValores({
    required int fc,
    required int spo2,
    required int co2,
  }) {
    // Si la alarma ya está corriendo el ciclo de 30 segundos, no volvemos a disparar
    if (state.alarmaActiva && state.segundosRestantes > 0) return;

    final u = state.umbrales;
    String? metrica;
    int? valor;

    if (fc < u.fcMin || fc > u.fcMax) {
      metrica = 'Frecuencia Cardíaca';
      valor = fc;
    } else if (spo2 < u.spo2Min) {
      metrica = 'Saturación de Oxígeno';
      valor = spo2;
    } else if (co2 > u.co2Max) {
      metrica = 'Dióxido de Carbono';
      valor = co2;
    }

    if (metrica != null) {
      _dispararAlarma(metrica, valor!);
    }
  }

  void _dispararAlarma(String metrica, int valor) {
    _timerRegresivo?.cancel();
    state = state.copiarCon(
      alarmaActiva: true,
      segundosRestantes: 30,
      metricaCritica: metrica,
      valorCritico: valor,
    );

    _timerRegresivo = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.segundosRestantes > 1) {
        state = state.copiarCon(
          segundosRestantes: state.segundosRestantes - 1,
        );
      } else {
        _timerRegresivo?.cancel();
        state = state.copiarCon(
          alarmaActiva: false,
          segundosRestantes: 0,
          metricaCritica: null,
          valorCritico: null,
        );
      }
    });
  }

  /// Cancela o silencia la alarma antes de los 30 segundos si el operador lo requiere
  void silenciarAlarma() {
    _timerRegresivo?.cancel();
    state = state.copiarCon(
      alarmaActiva: false,
      segundosRestantes: 0,
      metricaCritica: null,
      valorCritico: null,
    );
  }
}
