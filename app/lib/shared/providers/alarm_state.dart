import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'alarm_history_provider.dart';
import 'vital_signs_provider.dart';

part 'alarm_state.g.dart';

@immutable
class AlertThresholds {
  final int bpmMin;
  final int bpmMax;
  final int co2Max;

  const AlertThresholds({
    required this.bpmMin,
    required this.bpmMax,
    required this.co2Max,
  });

  factory AlertThresholds.defecto() {
    return const AlertThresholds(bpmMin: 60, bpmMax: 100, co2Max: 3500);
  }

  AlertThresholds copiarCon({int? bpmMin, int? bpmMax, int? co2Max}) {
    return AlertThresholds(
      bpmMin: bpmMin ?? this.bpmMin,
      bpmMax: bpmMax ?? this.bpmMax,
      co2Max: co2Max ?? this.co2Max,
    );
  }
}

@immutable
class CriticalAlert {
  final String metric;
  final int value;

  const CriticalAlert(this.metric, this.value);
}

@immutable
class AlarmState {
  final AlertThresholds thresholds;
  final bool alarmActive;
  final int secondsRemaining;
  final List<CriticalAlert> activeAlerts;
  final bool isEnabled;
  final bool isSoundEnabled;
  final String selectedSound;
  final bool isSoundTemporarilyMuted;

  const AlarmState({
    required this.thresholds,
    required this.alarmActive,
    required this.secondsRemaining,
    required this.activeAlerts,
    this.isEnabled = true,
    this.isSoundEnabled = true,
    this.selectedSound = 'alarma_clasica',
    this.isSoundTemporarilyMuted = false,
  });

  factory AlarmState.inicial() {
    return AlarmState(
      thresholds: AlertThresholds.defecto(),
      alarmActive: false,
      secondsRemaining: 0,
      activeAlerts: const [],
      isEnabled: true,
      isSoundEnabled: true,
      selectedSound: 'alarma_clasica',
      isSoundTemporarilyMuted: false,
    );
  }

  AlarmState copiarCon({
    AlertThresholds? thresholds,
    bool? alarmActive,
    int? secondsRemaining,
    List<CriticalAlert>? activeAlerts,
    bool? isEnabled,
    bool? isSoundEnabled,
    String? selectedSound,
    bool? isSoundTemporarilyMuted,
  }) {
    return AlarmState(
      thresholds: thresholds ?? this.thresholds,
      alarmActive: alarmActive ?? this.alarmActive,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      activeAlerts: activeAlerts ?? this.activeAlerts,
      isEnabled: isEnabled ?? this.isEnabled,
      isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
      selectedSound: selectedSound ?? this.selectedSound,
      isSoundTemporarilyMuted:
          isSoundTemporarilyMuted ?? this.isSoundTemporarilyMuted,
    );
  }
}

@riverpod
class AlarmNotifier extends _$AlarmNotifier {
  Timer? _countdownTimer;
  SharedPreferences? _prefs;

  bool _hasCurrentCriticalValues() {
    try {
      final signs = ref.read(vitalSignsNotifierProvider);
      final u = state.thresholds;

      final fc = signs.heartRate;

      // 1. FC
      bool fcEnAlerta = false;
      if (fc != 0) {
        final tieneFcAlerta = state.activeAlerts.any(
          (a) => a.metric == 'Frecuencia Cardíaca',
        );
        if (tieneFcAlerta) {
          if (fc < (u.bpmMin + 3) || fc > (u.bpmMax - 3)) {
            fcEnAlerta = true;
          }
        } else {
          if (fc < u.bpmMin || fc > u.bpmMax) {
            fcEnAlerta = true;
          }
        }
      }

      return fcEnAlerta;
    } catch (_) {}
    return false;
  }

  @override
  AlarmState build() {
    _loadThresholds();
    ref.onDispose(() {
      _countdownTimer?.cancel();
    });
    return AlarmState.inicial();
  }

  Future<void> _loadThresholds() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final bpmMin = _prefs?.getInt('umbral_fc_min') ?? 60;
      final bpmMax = _prefs?.getInt('umbral_fc_max') ?? 100;
      final co2Max = _prefs?.getInt('umbral_co2_max') ?? 3500;
      final isEnabled = _prefs?.getBool('alarma_habilitada') ?? true;
      final isSoundEnabled =
          _prefs?.getBool('alarma_sonido_habilitado') ?? true;
      final selectedSound =
          _prefs?.getString('alarma_sonido_seleccionado') ?? 'alarma_clasica';

      state = state.copiarCon(
        isEnabled: isEnabled,
        isSoundEnabled: isSoundEnabled,
        selectedSound: selectedSound,
        thresholds: AlertThresholds(
          bpmMin: bpmMin,
          bpmMax: bpmMax,
          co2Max: co2Max,
        ),
      );
    } catch (e) {
      debugPrint('Error cargando SharedPreferences: $e');
    }
  }

  Future<void> toggleEnabled(bool value) async {
    state = state.copiarCon(isEnabled: value);
    if (!value) {
      _clearAlarm();
    }
    await _prefs?.setBool('alarma_habilitada', value);
  }

  Future<void> toggleSoundEnabled(bool value) async {
    state = state.copiarCon(isSoundEnabled: value);
    await _prefs?.setBool('alarma_sonido_habilitado', value);
  }

  Future<void> changeSelectedSound(String sound) async {
    state = state.copiarCon(selectedSound: sound);
    await _prefs?.setString('alarma_sonido_seleccionado', sound);
  }

  Future<void> updateThresholds({int? bpmMin, int? bpmMax, int? co2Max}) async {
    updateThresholdsInMemory(bpmMin: bpmMin, bpmMax: bpmMax, co2Max: co2Max);
    await saveThresholdsToDisk();
  }

  void updateThresholdsInMemory({int? bpmMin, int? bpmMax, int? co2Max}) {
    final nuevosUmbrales = state.thresholds.copiarCon(
      bpmMin: bpmMin,
      bpmMax: bpmMax,
      co2Max: co2Max,
    );
    state = state.copiarCon(thresholds: nuevosUmbrales);

    // Verificar si con los nuevos umbrales, los valores fisiológicos actuales ya son normales
    _verifyCurrentValues();
  }

  void _verifyCurrentValues() {
    if (!state.isEnabled) return;
    try {
      final signs = ref.read(vitalSignsNotifierProvider);
      monitorValues(fc: signs.heartRate, co2: signs.co2Level);
    } catch (_) {
      // Ignorar si el proveedor de signos vitales no está inicializado
    }
  }

  Future<void> saveThresholdsToDisk() async {
    final u = state.thresholds;
    await _prefs?.setInt('umbral_fc_min', u.bpmMin);
    await _prefs?.setInt('umbral_fc_max', u.bpmMax);
    await _prefs?.setInt('umbral_co2_max', u.co2Max);
  }

  /// Evalúa si los valores actuales están fuera de los umbrales.
  /// Se ejecuta cada vez que el simulador o WS actualiza los datos.
  void monitorValues({required int fc, required int co2}) {
    if (!state.isEnabled) return;

    final u = state.thresholds;
    final nuevasAlertas = <CriticalAlert>[];

    // Constantes de histéresis
    const fcHysteresis = 3;

    // 1. Evaluar Frecuencia Cardíaca (FC)
    bool fcEnAlerta = false;
    if (fc != 0) {
      final tieneFcAlerta = state.activeAlerts.any(
        (a) => a.metric == 'Frecuencia Cardíaca',
      );
      if (tieneFcAlerta) {
        if (fc < (u.bpmMin + fcHysteresis) || fc > (u.bpmMax - fcHysteresis)) {
          fcEnAlerta = true;
        }
      } else {
        if (fc < u.bpmMin || fc > u.bpmMax) {
          fcEnAlerta = true;
        }
      }
    }
    if (fcEnAlerta) {
      nuevasAlertas.add(CriticalAlert('Frecuencia Cardíaca', fc));
    }

    // 2. Evaluar CO2
    bool co2EnAlerta = false;
    if (co2 != 0) {
      final tieneCo2Alerta = state.activeAlerts.any(
        (a) => a.metric == 'Dióxido de Carbono',
      );
      if (tieneCo2Alerta) {
        if (co2 > (u.co2Max - 50)) {
          // hysteresis para CO2
          co2EnAlerta = true;
        }
      } else {
        if (co2 > u.co2Max) {
          co2EnAlerta = true;
        }
      }
    }
    if (co2EnAlerta) {
      nuevasAlertas.add(CriticalAlert('Dióxido de Carbono', co2));
    }
    final estabaActiva = state.alarmActive;

    if (nuevasAlertas.isNotEmpty) {
      if (!estabaActiva) {
        _triggerAlarm(nuevasAlertas);
      } else {
        // Si ya estaba activa, verificamos si hay alertas de sensores que se sumaron recién
        final metricasPrevias = state.activeAlerts.map((a) => a.metric).toSet();
        final alertasNuevasParaLog = nuevasAlertas
            .where((a) => !metricasPrevias.contains(a.metric))
            .toList();

        if (alertasNuevasParaLog.isNotEmpty) {
          // Registrar en el historial persistente de la app la(s) nueva(s) alerta(s)
          ref
              .read(alarmHistoryProvider.notifier)
              .recordAlarm(alertasNuevasParaLog);
        }

        // Actualizamos la lista de alertas (por si cambió o se agregaron más)
        state = state.copiarCon(activeAlerts: nuevasAlertas);
      }
    }
  }

  void _triggerAlarm(List<CriticalAlert> alertas) {
    _countdownTimer?.cancel();
    state = state.copiarCon(
      alarmActive: true,
      secondsRemaining: 15,
      activeAlerts: alertas,
      isSoundTemporarilyMuted: false,
    );

    // Registrar en el historial persistente de la app
    ref.read(alarmHistoryProvider.notifier).recordAlarm(alertas);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.secondsRemaining > 1) {
        state = state.copiarCon(secondsRemaining: state.secondsRemaining - 1);
      } else {
        // Si al terminar el ciclo de 15s persisten lecturas críticas,
        // reiniciamos el temporizador a 15s silenciosamente en vez de apagar y reencender
        if (_hasCurrentCriticalValues()) {
          state = state.copiarCon(secondsRemaining: 15);
        } else {
          _countdownTimer?.cancel();
          _clearAlarm();
        }
      }
    });
  }

  void _clearAlarm() {
    _countdownTimer?.cancel();
    state = state.copiarCon(
      alarmActive: false,
      secondsRemaining: 0,
      activeAlerts: const [],
      isSoundTemporarilyMuted: false,
    );
  }

  /// Descarta manualmente la alarma activa.
  void discardAlarm() {
    _clearAlarm();
  }

  /// Silencia el sonido de la alarma actual temporalmente sin desactivar la alarma visual ni detener la cuenta regresiva.
  void muteAlarm() {
    state = state.copiarCon(isSoundTemporarilyMuted: true);
  }

  /// Reactiva el sonido de la alarma silenciada temporalmente.
  void unmuteAlarm() {
    state = state.copiarCon(isSoundTemporarilyMuted: false);
  }
}
