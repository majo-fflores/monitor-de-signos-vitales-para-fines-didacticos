import 'package:flutter/foundation.dart';

/// Punto de muestra individual enviado o recibido del backend.
@immutable
class Sample {
  final int timestamp;
  final double value;
  final bool? alert;

  const Sample({required this.timestamp, required this.value, this.alert});

  factory Sample.fromJson(Map<String, dynamic> json) {
    return Sample(
      timestamp: json['timestamp'] as int,
      value: (json['value'] as num).toDouble(),
      alert: json['alerta'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'value': value,
      if (alert != null) 'alerta': alert,
    };
  }
}

/// Contenedor de mediciones para una sesión en particular.
@immutable
class Measurement {
  final int id;
  final int sessionId;
  final List<Sample> samples;
  final DateTime createdAt;

  const Measurement({
    required this.id,
    required this.sessionId,
    required this.samples,
    required this.createdAt,
  });

  factory Measurement.fromJson(Map<String, dynamic> json) {
    var list = json['samples'] as List? ?? json['datos'] as List? ?? [];
    List<Sample> samplesList = list
        .map((i) => Sample.fromJson(i as Map<String, dynamic>))
        .toList();

    return Measurement(
      id: json['id'] as int,
      sessionId: json['session_id'] as int,
      samples: samplesList,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'samples': samples.map((d) => d.toJson()).toList(),
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }
}
