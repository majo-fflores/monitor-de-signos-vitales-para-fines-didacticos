import 'package:flutter/foundation.dart';
import 'measurement.dart';
import 'session.dart';
import 'session_summary.dart';

/// Registro de una medición biométrica realizada durante una sesión de monitoreo.
/// Captura un snapshot de los valores de los biosensores en un instante dado.
@immutable
class MeasurementRecord {
  final String id;
  final String userId;
  final DateTime registeredAt;
  final int durationSeconds;
  final int heartRate;
  final int minHeartRate;
  final int maxHeartRate;
  final int co2Level;
  final int minCo2;
  final int maxCo2;
  final int alertsTriggered;
  final String clinicalNotes;

  const MeasurementRecord({
    required this.id,
    required this.userId,
    required this.registeredAt,
    required this.durationSeconds,
    required this.heartRate,
    required this.minHeartRate,
    required this.maxHeartRate,
    required this.co2Level,
    required this.minCo2,
    required this.maxCo2,
    required this.alertsTriggered,
    required this.clinicalNotes,
  });

  /// Crea un nuevo registro de medición con ID generado automáticamente.
  factory MeasurementRecord.crear({
    required String userId,
    required int durationSeconds,
    required int heartRate,
    int minHeartRate = 0,
    int maxHeartRate = 0,
    required int co2Level,
    int minCo2 = 0,
    int maxCo2 = 0,
    int alertsTriggered = 0,
    String clinicalNotes = '',
  }) {
    final ahora = DateTime.now();
    final id = '${ahora.millisecondsSinceEpoch}_${userId.hashCode.abs()}';
    return MeasurementRecord(
      id: id,
      userId: userId,
      registeredAt: ahora,
      durationSeconds: durationSeconds,
      heartRate: heartRate,
      minHeartRate: minHeartRate,
      maxHeartRate: maxHeartRate,
      co2Level: co2Level,
      minCo2: minCo2,
      maxCo2: maxCo2,
      alertsTriggered: alertsTriggered,
      clinicalNotes: clinicalNotes,
    );
  }

  /// Crea un MeasurementRecord a partir del resumen batch del backend.
  factory MeasurementRecord.fromSessionWithSummary(SessionWithSummary data) {
    final session = data.session;
    final duracion = (session.endTime ?? DateTime.now())
        .difference(session.startTime)
        .inSeconds;

    return MeasurementRecord(
      id: session.id.toString(),
      userId: session.userId.toString(),
      registeredAt: session.startTime,
      durationSeconds: duracion > 0 ? duracion : 0,
      heartRate: data.avgBpm.round(),
      minHeartRate: data.minBpm.round(),
      maxHeartRate: data.maxBpm.round(),
      co2Level: data.avgAir.round(),
      minCo2: data.minAir.round(),
      maxCo2: data.maxAir.round(),
      alertsTriggered: data.alertCount,
      clinicalNotes: session.notes,
    );
  }

  /// Crea un MeasurementRecord a partir de una sesión y mediciones obtenidas del backend.
  factory MeasurementRecord.fromBackendSession(
    Session session, {
    List<Measurement>? bpm,
    List<Measurement>? air,
    String? clinicalNotes,
    int? bpmMin,
    int? bpmMax,
    int? co2Max,
  }) {
    final bpmValues =
        bpm?.expand((m) => m.samples).map((s) => s.value).toList() ?? [];
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
        air?.expand((m) => m.samples).map((s) => s.value).toList() ?? [];
    final co2Prom = airValues.isEmpty
        ? 350
        : (airValues.reduce((a, b) => a + b) / airValues.length).round();

    int co2Min = airValues.isEmpty
        ? 0
        : airValues.reduce((a, b) => a < b ? a : b).round();
    int co2MaxVal = airValues.isEmpty
        ? 0
        : airValues.reduce((a, b) => a > b ? a : b).round();

    final thresholdBpmMin = bpmMin ?? 60;
    final thresholdBpmMax = bpmMax ?? 100;
    final thresholdCo2Max = co2Max ?? 1600;

    int alertas = 0;
    for (var val in bpmValues) {
      if (val < thresholdBpmMin || val > thresholdBpmMax) alertas++;
    }
    for (var val in airValues) {
      if (val > thresholdCo2Max) alertas++;
    }

    final duracion = (session.endTime ?? DateTime.now())
        .difference(session.startTime)
        .inSeconds;

    return MeasurementRecord(
      id: session.id.toString(),
      userId: session.userId.toString(),
      registeredAt: session.startTime,
      durationSeconds: duracion > 0 ? duracion : 0,
      heartRate: fcProm,
      minHeartRate: fcMin,
      maxHeartRate: fcMax,
      co2Level: co2Prom,
      minCo2: co2Min,
      maxCo2: co2MaxVal,
      alertsTriggered: alertas,
      clinicalNotes: clinicalNotes ?? '',
    );
  }

  /// Deserializa desde un Map JSON.
  factory MeasurementRecord.fromJson(Map<String, dynamic> json) {
    return MeasurementRecord(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? json['usuarioId'] as String? ?? '',
      registeredAt: DateTime.parse(
        json['registeredAt'] as String? ?? json['fechaRegistro'] as String,
      ),
      durationSeconds:
          json['durationSeconds'] as int? ??
          json['duracionSegundos'] as int? ??
          0,
      heartRate:
          json['heartRate'] as int? ?? json['frecuenciaCardiaca'] as int? ?? 0,
      minHeartRate:
          json['minHeartRate'] as int? ??
          json['minFrecuenciaCardiaca'] as int? ??
          0,
      maxHeartRate:
          json['maxHeartRate'] as int? ??
          json['maxFrecuenciaCardiaca'] as int? ??
          0,
      co2Level: json['co2Level'] as int? ?? json['nivelCo2'] as int? ?? 0,
      minCo2: json['minCo2'] as int? ?? json['minCo2'] as int? ?? 0,
      maxCo2: json['maxCo2'] as int? ?? json['maxCo2'] as int? ?? 0,
      alertsTriggered:
          json['alertsTriggered'] as int? ??
          json['alertasDisparadas'] as int? ??
          0,
      clinicalNotes:
          json['clinicalNotes'] as String? ??
          json['notasClinicas'] as String? ??
          '',
    );
  }

  /// Serializa a Map JSON para persistencia.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'registeredAt': registeredAt.toIso8601String(),
      'durationSeconds': durationSeconds,
      'heartRate': heartRate,
      'minHeartRate': minHeartRate,
      'maxHeartRate': maxHeartRate,
      'co2Level': co2Level,
      'minCo2': minCo2,
      'maxCo2': maxCo2,
      'alertsTriggered': alertsTriggered,
      'clinicalNotes': clinicalNotes,
    };
  }

  /// Duración formateada legible (e.g. "2m 30s", "1h 5m").
  String get formattedDuration {
    if (durationSeconds < 60) return '${durationSeconds}s';
    final minutos = durationSeconds ~/ 60;
    final segs = durationSeconds % 60;
    if (minutos < 60) return '${minutos}m ${segs}s';
    final horas = minutos ~/ 60;
    final mins = minutos % 60;
    return '${horas}h ${mins}m';
  }

  /// Fecha formateada legible (e.g. "26/05/2026 15:30").
  String get formattedDate {
    return '${registeredAt.day.toString().padLeft(2, '0')}/'
        '${registeredAt.month.toString().padLeft(2, '0')}/'
        '${registeredAt.year} '
        '${registeredAt.hour.toString().padLeft(2, '0')}:'
        '${registeredAt.minute.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MeasurementRecord && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
