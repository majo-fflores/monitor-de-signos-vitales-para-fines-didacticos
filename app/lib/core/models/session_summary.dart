import 'package:flutter/foundation.dart';
import 'session.dart';

/// Modelo que representa una sesión con su resumen asociado (para endpoint por lotes).
@immutable
class SessionWithSummary {
  final Session session;
  final double avgBpm;
  final double avgEcg;
  final double avgSpo2;
  final double avgAir;
  final int alertCount;

  const SessionWithSummary({
    required this.session,
    required this.avgBpm,
    required this.avgEcg,
    required this.avgSpo2,
    required this.avgAir,
    required this.alertCount,
  });

  /// Factory para construir a partir del JSON devuelto por el backend.
  factory SessionWithSummary.fromJson(Map<String, dynamic> json) {
    return SessionWithSummary(
      session: Session.fromBackendJson(json),
      avgBpm: (json['avg_bpm'] as num?)?.toDouble() ?? 0.0,
      avgEcg: (json['avg_ecg'] as num?)?.toDouble() ?? 0.0,
      avgSpo2: (json['avg_spo2'] as num?)?.toDouble() ?? 0.0,
      avgAir: (json['avg_air'] as num?)?.toDouble() ?? 0.0,
      alertCount: json['alert_count'] as int? ?? 0,
    );
  }
}

/// Modelo que representa el resumen individual de una sesión (GET /sessions/:id/summary).
@immutable
class SessionSummary {
  final int sessionId;
  final String notes;
  final double avgBpm;
  final double avgEcg;
  final double avgSpo2;
  final double avgAir;
  final int alertCount;

  const SessionSummary({
    required this.sessionId,
    required this.notes,
    required this.avgBpm,
    required this.avgEcg,
    required this.avgSpo2,
    required this.avgAir,
    required this.alertCount,
  });

  factory SessionSummary.fromJson(Map<String, dynamic> json) {
    return SessionSummary(
      sessionId: json['session_id'] as int? ?? 0,
      notes: json['notes'] as String? ?? '',
      avgBpm: (json['avg_bpm'] as num?)?.toDouble() ?? 0.0,
      avgEcg: (json['avg_ecg'] as num?)?.toDouble() ?? 0.0,
      avgSpo2: (json['avg_spo2'] as num?)?.toDouble() ?? 0.0,
      avgAir: (json['avg_air'] as num?)?.toDouble() ?? 0.0,
      alertCount: json['alert_count'] as int? ?? 0,
    );
  }
}
