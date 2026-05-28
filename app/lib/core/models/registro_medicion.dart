import 'package:flutter/foundation.dart';

/// Registro de una medición biométrica realizada durante una sesión de monitoreo.
/// Captura un snapshot de los valores de los biosensores en un instante dado.
@immutable
class RegistroMedicion {
  final String id;
  final String usuarioId;
  final DateTime fechaRegistro;
  final int duracionSegundos;
  final int frecuenciaCardiaca;
  final int ppgFrecuenciaCardiaca;
  final int nivelSpo2;
  final int nivelCo2;
  final int alertasDisparadas;
  final String notasClinicas;

  const RegistroMedicion({
    required this.id,
    required this.usuarioId,
    required this.fechaRegistro,
    required this.duracionSegundos,
    required this.frecuenciaCardiaca,
    required this.ppgFrecuenciaCardiaca,
    required this.nivelSpo2,
    required this.nivelCo2,
    required this.alertasDisparadas,
    required this.notasClinicas,
  });

  /// Crea un nuevo registro de medición con ID generado automáticamente.
  factory RegistroMedicion.crear({
    required String usuarioId,
    required int duracionSegundos,
    required int frecuenciaCardiaca,
    required int ppgFrecuenciaCardiaca,
    required int nivelSpo2,
    required int nivelCo2,
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
      ppgFrecuenciaCardiaca: ppgFrecuenciaCardiaca,
      nivelSpo2: nivelSpo2,
      nivelCo2: nivelCo2,
      alertasDisparadas: alertasDisparadas,
      notasClinicas: notasClinicas,
    );
  }

  /// Deserializa desde un Map JSON.
  factory RegistroMedicion.fromJson(Map<String, dynamic> json) {
    return RegistroMedicion(
      id: json['id'] as String,
      usuarioId: json['usuarioId'] as String,
      fechaRegistro: DateTime.parse(json['fechaRegistro'] as String),
      duracionSegundos: json['duracionSegundos'] as int,
      frecuenciaCardiaca: json['frecuenciaCardiaca'] as int,
      ppgFrecuenciaCardiaca: json['ppgFrecuenciaCardiaca'] as int? ?? (json['frecuenciaCardiaca'] as int? ?? 72),
      nivelSpo2: json['nivelSpo2'] as int,
      nivelCo2: json['nivelCo2'] as int,
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
      'ppgFrecuenciaCardiaca': ppgFrecuenciaCardiaca,
      'nivelSpo2': nivelSpo2,
      'nivelCo2': nivelCo2,
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
