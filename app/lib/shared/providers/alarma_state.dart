import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'historial_alarmas_provider.dart';
import 'vital_signs_provider.dart';

part 'alarma_state.g.dart';

@immutable
class UmbralesAlerta {
  final int fcMin;
  final int fcMax;
  final int ppgMin;
  final int co2Max;

  const UmbralesAlerta({
    required this.fcMin,
    required this.fcMax,
    required this.ppgMin,
    required this.co2Max,
  });

  factory UmbralesAlerta.defecto() {
    return const UmbralesAlerta(fcMin: 60, fcMax: 100, ppgMin: 60, co2Max: 800);
  }

  UmbralesAlerta copiarCon({int? fcMin, int? fcMax, int? ppgMin, int? co2Max}) {
    return UmbralesAlerta(
      fcMin: fcMin ?? this.fcMin,
      fcMax: fcMax ?? this.fcMax,
      ppgMin: ppgMin ?? this.ppgMin,
      co2Max: co2Max ?? this.co2Max,
    );
  }
}

@immutable
class AlertaCritica {
  final String metrica;
  final int valor;

  const AlertaCritica(this.metrica, this.valor);
}

@immutable
class EstadoAlarma {
  final UmbralesAlerta umbrales;
  final bool alarmaActiva;
  final int segundosRestantes;
  final List<AlertaCritica> alertasActivas;
  final bool habilitada;
  final bool sonidoHabilitado;
  final String sonidoSeleccionado;
  final bool sonidoSilenciadoTemporalmente;

  const EstadoAlarma({
    required this.umbrales,
    required this.alarmaActiva,
    required this.segundosRestantes,
    required this.alertasActivas,
    this.habilitada = true,
    this.sonidoHabilitado = true,
    this.sonidoSeleccionado = 'alarma_clasica',
    this.sonidoSilenciadoTemporalmente = false,
  });

  factory EstadoAlarma.inicial() {
    return EstadoAlarma(
      umbrales: UmbralesAlerta.defecto(),
      alarmaActiva: false,
      segundosRestantes: 0,
      alertasActivas: const [],
      habilitada: true,
      sonidoHabilitado: true,
      sonidoSeleccionado: 'alarma_clasica',
      sonidoSilenciadoTemporalmente: false,
    );
  }

  EstadoAlarma copiarCon({
    UmbralesAlerta? umbrales,
    bool? alarmaActiva,
    int? segundosRestantes,
    List<AlertaCritica>? alertasActivas,
    bool? habilitada,
    bool? sonidoHabilitado,
    String? sonidoSeleccionado,
    bool? sonidoSilenciadoTemporalmente,
  }) {
    return EstadoAlarma(
      umbrales: umbrales ?? this.umbrales,
      alarmaActiva: alarmaActiva ?? this.alarmaActiva,
      segundosRestantes: segundosRestantes ?? this.segundosRestantes,
      alertasActivas: alertasActivas ?? this.alertasActivas,
      habilitada: habilitada ?? this.habilitada,
      sonidoHabilitado: sonidoHabilitado ?? this.sonidoHabilitado,
      sonidoSeleccionado: sonidoSeleccionado ?? this.sonidoSeleccionado,
      sonidoSilenciadoTemporalmente:
          sonidoSilenciadoTemporalmente ?? this.sonidoSilenciadoTemporalmente,
    );
  }
}

@riverpod
class NotificadorAlarma extends _$NotificadorAlarma {
  Timer? _timerRegresivo;
  SharedPreferences? _prefs;

  bool _hayValoresCriticosActuales() {
    try {
      final signos = ref.read(notificadorSignosVitalesProvider);
      final u = state.umbrales;

      final fc = signos.frecuenciaCardiaca;
      final ppg = signos.ppgFrecuenciaCardiaca;
      final co2 = signos.nivelCo2;

      // 1. FC
      bool fcEnAlerta = false;
      final tieneFcAlerta = state.alertasActivas.any(
        (a) => a.metrica == 'Frecuencia Cardíaca',
      );
      if (tieneFcAlerta) {
        if (fc < (u.fcMin + 3) || fc > (u.fcMax - 3)) {
          fcEnAlerta = true;
        }
      } else {
        if (fc < u.fcMin || fc > u.fcMax) {
          fcEnAlerta = true;
        }
      }

      // 2. PPG
      bool ppgEnAlerta = false;
      final tienePpgAlerta = state.alertasActivas.any(
        (a) => a.metrica == 'Frecuencia de Pulso (PPG)',
      );
      if (tienePpgAlerta) {
        if (ppg < (u.ppgMin + 3)) {
          ppgEnAlerta = true;
        }
      } else {
        if (ppg < u.ppgMin) {
          ppgEnAlerta = true;
        }
      }

      // 3. CO2
      bool co2EnAlerta = false;
      final tieneCo2Alerta = state.alertasActivas.any(
        (a) => a.metrica == 'Dióxido de Carbono',
      );
      if (tieneCo2Alerta) {
        if (co2 > (u.co2Max - 20)) {
          co2EnAlerta = true;
        }
      } else {
        if (co2 > u.co2Max) {
          co2EnAlerta = true;
        }
      }

      return fcEnAlerta || ppgEnAlerta || co2EnAlerta;
    } catch (_) {}
    return false;
  }

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
      final ppgMin = _prefs?.getInt('umbral_ppg_min') ?? 60;
      final co2Max = _prefs?.getInt('umbral_co2_max') ?? 800;
      final habilitada = _prefs?.getBool('alarma_habilitada') ?? true;
      final sonidoHabilitado =
          _prefs?.getBool('alarma_sonido_habilitado') ?? true;
      final sonidoSeleccionado =
          _prefs?.getString('alarma_sonido_seleccionado') ?? 'alarma_clasica';

      state = state.copiarCon(
        habilitada: habilitada,
        sonidoHabilitado: sonidoHabilitado,
        sonidoSeleccionado: sonidoSeleccionado,
        umbrales: UmbralesAlerta(
          fcMin: fcMin,
          fcMax: fcMax,
          ppgMin: ppgMin,
          co2Max: co2Max,
        ),
      );
    } catch (e) {
      debugPrint('Error cargando SharedPreferences: $e');
    }
  }

  Future<void> cambiarHabilitacion(bool valor) async {
    state = state.copiarCon(habilitada: valor);
    if (!valor) {
      _limpiarAlarma();
    }
    await _prefs?.setBool('alarma_habilitada', valor);
  }

  Future<void> cambiarHabilitacionSonido(bool valor) async {
    state = state.copiarCon(sonidoHabilitado: valor);
    await _prefs?.setBool('alarma_sonido_habilitado', valor);
  }

  Future<void> cambiarSonidoSeleccionado(String sonido) async {
    state = state.copiarCon(sonidoSeleccionado: sonido);
    await _prefs?.setString('alarma_sonido_seleccionado', sonido);
  }

  Future<void> actualizarUmbrales({
    int? fcMin,
    int? fcMax,
    int? ppgMin,
    int? co2Max,
  }) async {
    actualizarUmbralesMemoria(
      fcMin: fcMin,
      fcMax: fcMax,
      ppgMin: ppgMin,
      co2Max: co2Max,
    );
    await guardarUmbralesEnDisco();
  }

  void actualizarUmbralesMemoria({
    int? fcMin,
    int? fcMax,
    int? ppgMin,
    int? co2Max,
  }) {
    final nuevosUmbrales = state.umbrales.copiarCon(
      fcMin: fcMin,
      fcMax: fcMax,
      ppgMin: ppgMin,
      co2Max: co2Max,
    );
    state = state.copiarCon(umbrales: nuevosUmbrales);

    // Verificar si con los nuevos umbrales, los valores fisiológicos actuales ya son normales
    _verificarValoresActuales();
  }

  void _verificarValoresActuales() {
    if (!state.habilitada) return;
    try {
      final signos = ref.read(notificadorSignosVitalesProvider);
      monitorearValores(
        fc: signos.frecuenciaCardiaca,
        ppg: signos.ppgFrecuenciaCardiaca,
        co2: signos.nivelCo2,
      );
    } catch (_) {
      // Ignorar si el proveedor de signos vitales no está inicializado
    }
  }

  Future<void> guardarUmbralesEnDisco() async {
    final u = state.umbrales;
    await _prefs?.setInt('umbral_fc_min', u.fcMin);
    await _prefs?.setInt('umbral_fc_max', u.fcMax);
    await _prefs?.setInt('umbral_ppg_min', u.ppgMin);
    await _prefs?.setInt('umbral_co2_max', u.co2Max);
  }

  /// Evalúa si los valores actuales están fuera de los umbrales.
  /// Se ejecuta cada vez que el simulador o WS actualiza los datos.
  void monitorearValores({
    required int fc,
    required int ppg,
    required int co2,
  }) {
    if (!state.habilitada) return;

    final u = state.umbrales;
    final nuevasAlertas = <AlertaCritica>[];

    // Constantes de histéresis
    const fcHysteresis = 3;
    const ppgHysteresis = 3;
    const co2Hysteresis = 20;

    // 1. Evaluar Frecuencia Cardíaca (FC)
    bool fcEnAlerta = false;
    final tieneFcAlerta = state.alertasActivas.any(
      (a) => a.metrica == 'Frecuencia Cardíaca',
    );
    if (tieneFcAlerta) {
      if (fc < (u.fcMin + fcHysteresis) || fc > (u.fcMax - fcHysteresis)) {
        fcEnAlerta = true;
      }
    } else {
      if (fc < u.fcMin || fc > u.fcMax) {
        fcEnAlerta = true;
      }
    }
    if (fcEnAlerta) {
      nuevasAlertas.add(AlertaCritica('Frecuencia Cardíaca', fc));
    }

    // 2. Evaluar PPG (Frecuencia de Pulso)
    bool ppgEnAlerta = false;
    final tienePpgAlerta = state.alertasActivas.any(
      (a) => a.metrica == 'Frecuencia de Pulso (PPG)',
    );
    if (tienePpgAlerta) {
      if (ppg < (u.ppgMin + ppgHysteresis)) {
        ppgEnAlerta = true;
      }
    } else {
      if (ppg < u.ppgMin) {
        ppgEnAlerta = true;
      }
    }
    if (ppgEnAlerta) {
      nuevasAlertas.add(AlertaCritica('Frecuencia de Pulso (PPG)', ppg));
    }

    // 3. Evaluar CO2
    bool co2EnAlerta = false;
    final tieneCo2Alerta = state.alertasActivas.any(
      (a) => a.metrica == 'Dióxido de Carbono',
    );
    if (tieneCo2Alerta) {
      if (co2 > (u.co2Max - co2Hysteresis)) {
        co2EnAlerta = true;
      }
    } else {
      if (co2 > u.co2Max) {
        co2EnAlerta = true;
      }
    }
    if (co2EnAlerta) {
      nuevasAlertas.add(AlertaCritica('Dióxido de Carbono', co2));
    }

    final estabaActiva = state.alarmaActiva;

    if (nuevasAlertas.isNotEmpty) {
      if (!estabaActiva) {
        _dispararAlarma(nuevasAlertas);
      } else {
        // Si ya estaba activa, verificamos si hay alertas de sensores que se sumaron recién
        final metricasPrevias = state.alertasActivas
            .map((a) => a.metrica)
            .toSet();
        final alertasNuevasParaLog = nuevasAlertas
            .where((a) => !metricasPrevias.contains(a.metrica))
            .toList();

        if (alertasNuevasParaLog.isNotEmpty) {
          // Registrar en el historial persistente de la app la(s) nueva(s) alerta(s)
          ref
              .read(historialAlarmasProvider.notifier)
              .registrarAlarma(alertasNuevasParaLog);
        }

        // Actualizamos la lista de alertas (por si cambió o se agregaron más)
        state = state.copiarCon(alertasActivas: nuevasAlertas);
      }
    }
  }

  void _dispararAlarma(List<AlertaCritica> alertas) {
    _timerRegresivo?.cancel();
    state = state.copiarCon(
      alarmaActiva: true,
      segundosRestantes: 15,
      alertasActivas: alertas,
      sonidoSilenciadoTemporalmente: false,
    );

    // Registrar en el historial persistente de la app
    ref.read(historialAlarmasProvider.notifier).registrarAlarma(alertas);

    _timerRegresivo = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.segundosRestantes > 1) {
        state = state.copiarCon(segundosRestantes: state.segundosRestantes - 1);
      } else {
        // Si al terminar el ciclo de 15s persisten lecturas críticas,
        // reiniciamos el temporizador a 15s silenciosamente en vez de apagar y reencender
        if (_hayValoresCriticosActuales()) {
          state = state.copiarCon(segundosRestantes: 15);
        } else {
          _timerRegresivo?.cancel();
          _limpiarAlarma();
        }
      }
    });
  }

  void _limpiarAlarma() {
    _timerRegresivo?.cancel();
    state = state.copiarCon(
      alarmaActiva: false,
      segundosRestantes: 0,
      alertasActivas: const [],
      sonidoSilenciadoTemporalmente: false,
    );
  }

  /// Descarta manualmente la alarma activa.
  void descartarAlarma() {
    _limpiarAlarma();
  }

  /// Silencia el sonido de la alarma actual temporalmente sin desactivar la alarma visual ni detener la cuenta regresiva.
  void silenciarAlarma() {
    state = state.copiarCon(sonidoSilenciadoTemporalmente: true);
  }

  /// Reactiva el sonido de la alarma silenciada temporalmente.
  void desactivarSilencioTemporal() {
    state = state.copiarCon(sonidoSilenciadoTemporalmente: false);
  }
}
