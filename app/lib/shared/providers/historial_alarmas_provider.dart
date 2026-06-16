import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'alarma_state.dart';

part 'historial_alarmas_provider.g.dart';

@immutable
class RegistroAlarma {
  final String id;
  final DateTime fecha;
  final List<String> metricas;
  final Map<String, int> valores;

  const RegistroAlarma({
    required this.id,
    required this.fecha,
    required this.metricas,
    required this.valores,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fecha': fecha.toIso8601String(),
      'metricas': metricas,
      'valores': valores,
    };
  }

  factory RegistroAlarma.fromJson(Map<String, dynamic> json) {
    return RegistroAlarma(
      id: json['id'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      metricas: List<String>.from(json['metricas'] as List),
      valores: Map<String, int>.from(json['valores'] as Map),
    );
  }
}

@riverpod
class HistorialAlarmas extends _$HistorialAlarmas {
  static const _historyKey = 'historial_alarmas_json';
  SharedPreferences? _prefs;

  @override
  List<RegistroAlarma> build() {
    _cargarHistorial();
    return [];
  }

  Future<void> _cargarHistorial() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final listJson = _prefs?.getStringList(_historyKey);
      if (listJson != null) {
        state =
            listJson
                .map(
                  (item) => RegistroAlarma.fromJson(
                    json.decode(item) as Map<String, dynamic>,
                  ),
                )
                .toList()
              ..sort(
                (a, b) => b.fecha.compareTo(a.fecha),
              ); // El más reciente primero
      }
    } catch (e) {
      debugPrint('Error cargando historial de alarmas: $e');
    }
  }

  Future<void> registrarAlarma(List<AlertaCritica> alertas) async {
    if (alertas.isEmpty) return;

    final nuevoRegistro = RegistroAlarma(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fecha: DateTime.now(),
      metricas: alertas.map((a) => a.metrica).toList(),
      valores: {for (var a in alertas) a.metrica: a.valor},
    );

    state = [nuevoRegistro, ...state];

    _prefs ??= await SharedPreferences.getInstance();
    final listJson = state.map((r) => json.encode(r.toJson())).toList();
    await _prefs?.setStringList(_historyKey, listJson);
  }

  Future<void> limpiarHistorial() async {
    state = [];
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.remove(_historyKey);
  }
}
