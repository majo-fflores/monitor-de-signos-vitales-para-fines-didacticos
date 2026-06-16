import 'package:flutter/foundation.dart';

/// Punto de muestra individual enviado o recibido del backend.
@immutable
class Sample {
  final int timestamp;
  final double value;

  const Sample({required this.timestamp, required this.value});

  factory Sample.fromJson(Map<String, dynamic> json) {
    return Sample(
      timestamp: json['timestamp'] as int,
      value: (json['value'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'timestamp': timestamp, 'value': value};
  }
}

/// Contenedor de mediciones para una sesión en particular.
@immutable
class Measurement {
  final int id;
  final int sessionId;
  final List<Sample> datos;
  final DateTime createdAt;

  const Measurement({
    required this.id,
    required this.sessionId,
    required this.datos,
    required this.createdAt,
  });

  factory Measurement.fromJson(Map<String, dynamic> json) {
    var list = json['datos'] as List? ?? [];
    List<Sample> samplesList = list
        .map((i) => Sample.fromJson(i as Map<String, dynamic>))
        .toList();

    return Measurement(
      id: json['id'] as int,
      sessionId: json['session_id'] as int,
      datos: samplesList,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'datos': datos.map((d) => d.toJson()).toList(),
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }
}
