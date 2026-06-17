import 'package:flutter/foundation.dart';
import 'session.dart';

/// Modelo que representa una sesión con su resumen asociado (para endpoint por lotes).
@immutable
class SessionWithSummary {
  final Session session;
  final double minBpm;
  final double maxBpm;
  final double avgBpm;
  final double minEcg;
  final double maxEcg;
  final double avgEcg;
  final double minAir;
  final double maxAir;
  final double avgAir;
  final int alertCount;

  const SessionWithSummary({
    required this.session,
    required this.minBpm,
    required this.maxBpm,
    required this.avgBpm,
    required this.minEcg,
    required this.maxEcg,
    required this.avgEcg,
    required this.minAir,
    required this.maxAir,
    required this.avgAir,
    required this.alertCount,
  });

  /// Factory para construir a partir del JSON devuelto por el backend.
  factory SessionWithSummary.fromJson(Map<String, dynamic> json) {
    return SessionWithSummary(
      session: Session.fromBackendJson(json),
      minBpm: (json['min_bpm'] as num?)?.toDouble() ?? 0.0,
      maxBpm: (json['max_bpm'] as num?)?.toDouble() ?? 0.0,
      avgBpm: (json['avg_bpm'] as num?)?.toDouble() ?? 0.0,
      minEcg: (json['min_ecg'] as num?)?.toDouble() ?? 0.0,
      maxEcg: (json['max_ecg'] as num?)?.toDouble() ?? 0.0,
      avgEcg: (json['avg_ecg'] as num?)?.toDouble() ?? 0.0,
      minAir: (json['min_air'] as num?)?.toDouble() ?? 0.0,
      maxAir: (json['max_air'] as num?)?.toDouble() ?? 0.0,
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
  final double minBpm;
  final double maxBpm;
  final double avgBpm;
  final double minEcg;
  final double maxEcg;
  final double avgEcg;
  final double minAir;
  final double maxAir;
  final double avgAir;
  final int alertCount;

  const SessionSummary({
    required this.sessionId,
    required this.notes,
    required this.minBpm,
    required this.maxBpm,
    required this.avgBpm,
    required this.minEcg,
    required this.maxEcg,
    required this.avgEcg,
    required this.minAir,
    required this.maxAir,
    required this.avgAir,
    required this.alertCount,
  });

  factory SessionSummary.fromJson(Map<String, dynamic> json) {
    return SessionSummary(
      sessionId: json['session_id'] as int? ?? 0,
      notes: json['notes'] as String? ?? '',
      minBpm: (json['min_bpm'] as num?)?.toDouble() ?? 0.0,
      maxBpm: (json['max_bpm'] as num?)?.toDouble() ?? 0.0,
      avgBpm: (json['avg_bpm'] as num?)?.toDouble() ?? 0.0,
      minEcg: (json['min_ecg'] as num?)?.toDouble() ?? 0.0,
      maxEcg: (json['max_ecg'] as num?)?.toDouble() ?? 0.0,
      avgEcg: (json['avg_ecg'] as num?)?.toDouble() ?? 0.0,
      minAir: (json['min_air'] as num?)?.toDouble() ?? 0.0,
      maxAir: (json['max_air'] as num?)?.toDouble() ?? 0.0,
      avgAir: (json['avg_air'] as num?)?.toDouble() ?? 0.0,
      alertCount: json['alert_count'] as int? ?? 0,
    );
  }
}
