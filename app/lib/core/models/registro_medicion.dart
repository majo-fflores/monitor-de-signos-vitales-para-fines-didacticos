import 'package:flutter/foundation.dart';
import 'measurement.dart';
import 'session.dart';
import 'session_summary.dart';

/// Registro de una medición biométrica realizada durante una sesión de monitoreo.
/// Captura un snapshot de los valores de los biosensores en un instante dado.
@immutable
class RegistroMedicion {
  final String id;
  final String usuarioId;
  final DateTime fechaRegistro;
  final int duracionSegundos;
  final int frecuenciaCardiaca;
  final int minFrecuenciaCardiaca;
  final int maxFrecuenciaCardiaca;
  final int nivelCo2;
  final int minCo2;
  final int maxCo2;
  final int alertasDisparadas;
  final String notasClinicas;

  const RegistroMedicion({
    required this.id,
    required this.usuarioId,
    required this.fechaRegistro,
    required this.duracionSegundos,
    required this.frecuenciaCardiaca,
    required this.minFrecuenciaCardiaca,
    required this.maxFrecuenciaCardiaca,
    required this.nivelCo2,
    required this.minCo2,
    required this.maxCo2,
    required this.alertasDisparadas,
    required this.notasClinicas,
  });

  /// Crea un nuevo registro de medición con ID generado automáticamente.
  factory RegistroMedicion.crear({
    required String usuarioId,
    required int duracionSegundos,
    required int frecuenciaCardiaca,
    int minFrecuenciaCardiaca = 0,
    int maxFrecuenciaCardiaca = 0,
    required int nivelCo2,
    int minCo2 = 0,
    int maxCo2 = 0,
    int alertasDisparadas = 0,
    String notasClinicas = '',
  }) {
    final ahora = DateTime.now();
    final id = '${ahora.millisecondsSinceEpoch}_${usuarioId.hashCode.abs()}';
    return RegistroMedicion(
      id: id,
      usuarioId: usuarioId,
      fechaRegistro: ahora,
      duracionSegundos: duracionSegundos,
      frecuenciaCardiaca: frecuenciaCardiaca,
      minFrecuenciaCardiaca: minFrecuenciaCardiaca,
      maxFrecuenciaCardiaca: maxFrecuenciaCardiaca,
      nivelCo2: nivelCo2,
      minCo2: minCo2,
      maxCo2: maxCo2,
      alertasDisparadas: alertasDisparadas,
      notasClinicas: notasClinicas,
    );
  }

  /// Crea un RegistroMedicion a partir del resumen batch del backend.
  factory RegistroMedicion.fromSessionWithSummary(SessionWithSummary data) {
    final session = data.session;
    final duracion = (session.endTime ?? DateTime.now())
        .difference(session.startTime)
        .inSeconds;

    return RegistroMedicion(
      id: session.id.toString(),
      usuarioId: session.userId.toString(),
      fechaRegistro: session.startTime,
      duracionSegundos: duracion > 0 ? duracion : 0,
      frecuenciaCardiaca: data.avgBpm.round(),
      minFrecuenciaCardiaca: data.minBpm.round(),
      maxFrecuenciaCardiaca: data.maxBpm.round(),
      nivelCo2: data.avgAir.round(),
      minCo2: data.minAir.round(),
      maxCo2: data.maxAir.round(),
      alertasDisparadas: data.alertCount,
      notasClinicas: session.notes,
    );
  }

  /// Crea un RegistroMedicion a partir de una sesión y mediciones obtenidas del backend.
  factory RegistroMedicion.fromBackendSession(
    Session session, {
    List<Measurement>? bpm,
    List<Measurement>? air,
    String? notasClinicas,
  }) {
    final bpmValues =
        bpm?.expand((m) => m.datos).map((s) => s.value).toList() ?? [];
    final fcProm = bpmValues.isEmpty
        ? 70
        : (bpmValues.reduce((a, b) => a + b) / bpmValues.length).round();

    int fcMin = bpmValues.isEmpty
        ? 0
        : bpmValues.reduce((a, b) => a < b ? a : b).round();
    int fcMax = bpmValues.isEmpty
        ? 0
        : bpmValues.reduce((a, b) => a > b ? a : b).round();

    final airValues =
        air?.expand((m) => m.datos).map((s) => s.value).toList() ?? [];
    final co2Prom = airValues.isEmpty
        ? 350
        : (airValues.reduce((a, b) => a + b) / airValues.length).round();

    int co2Min = airValues.isEmpty
        ? 0
        : airValues.reduce((a, b) => a < b ? a : b).round();
    int co2Max = airValues.isEmpty
        ? 0
        : airValues.reduce((a, b) => a > b ? a : b).round();

    int alertas = 0;
    for (var val in bpmValues) {
      if (val < 60 || val > 100) alertas++;
    }
    for (var val in airValues) {
      if (val > 1000) alertas++;
    }

    final duracion = (session.endTime ?? DateTime.now())
        .difference(session.startTime)
        .inSeconds;

    return RegistroMedicion(
      id: session.id.toString(),
      usuarioId: session.userId.toString(),
      fechaRegistro: session.startTime,
      duracionSegundos: duracion > 0 ? duracion : 0,
      frecuenciaCardiaca: fcProm,
      minFrecuenciaCardiaca: fcMin,
      maxFrecuenciaCardiaca: fcMax,
      nivelCo2: co2Prom,
      minCo2: co2Min,
      maxCo2: co2Max,
      alertasDisparadas: alertas,
      notasClinicas: notasClinicas ?? '',
    );
  }

  /// Deserializa desde un Map JSON.
  factory RegistroMedicion.fromJson(Map<String, dynamic> json) {
    return RegistroMedicion(
      id: json['id'] as String,
      usuarioId: json['usuarioId'] as String,
      fechaRegistro: DateTime.parse(json['fechaRegistro'] as String),
      duracionSegundos: json['duracionSegundos'] as int,
      frecuenciaCardiaca: json['frecuenciaCardiaca'] as int? ?? 0,
      minFrecuenciaCardiaca: json['minFrecuenciaCardiaca'] as int? ?? 0,
      maxFrecuenciaCardiaca: json['maxFrecuenciaCardiaca'] as int? ?? 0,
      nivelCo2: json['nivelCo2'] as int? ?? 0,
      minCo2: json['minCo2'] as int? ?? 0,
      maxCo2: json['maxCo2'] as int? ?? 0,
      alertasDisparadas: json['alertasDisparadas'] as int? ?? 0,
      notasClinicas: json['notasClinicas'] as String? ?? '',
    );
  }

  /// Serializa a Map JSON para persistencia.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'fechaRegistro': fechaRegistro.toIso8601String(),
      'duracionSegundos': duracionSegundos,
      'frecuenciaCardiaca': frecuenciaCardiaca,
      'minFrecuenciaCardiaca': minFrecuenciaCardiaca,
      'maxFrecuenciaCardiaca': maxFrecuenciaCardiaca,
      'nivelCo2': nivelCo2,
      'minCo2': minCo2,
      'maxCo2': maxCo2,
      'alertasDisparadas': alertasDisparadas,
      'notasClinicas': notasClinicas,
    };
  }

  /// Duración formateada legible (e.g. "2m 30s", "1h 5m").
  String get duracionFormateada {
    if (duracionSegundos < 60) return '${duracionSegundos}s';
    final minutos = duracionSegundos ~/ 60;
    final segs = duracionSegundos % 60;
    if (minutos < 60) return '${minutos}m ${segs}s';
    final horas = minutos ~/ 60;
    final mins = minutos % 60;
    return '${horas}h ${mins}m';
  }

  /// Fecha formateada legible (e.g. "26/05/2026 15:30").
  String get fechaFormateada {
    return '${fechaRegistro.day.toString().padLeft(2, '0')}/'
        '${fechaRegistro.month.toString().padLeft(2, '0')}/'
        '${fechaRegistro.year} '
        '${fechaRegistro.hour.toString().padLeft(2, '0')}:'
        '${fechaRegistro.minute.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is RegistroMedicion && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
