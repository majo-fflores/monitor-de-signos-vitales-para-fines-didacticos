import 'package:flutter/foundation.dart';

/// Modelo de Sesión compatible con el backend Go.
@immutable
class Session {
  final int id;
  final int userId;
  final DateTime startTime;
  final DateTime? endTime;
  final String notes;

  const Session({
    required this.id,
    required this.userId,
    required this.startTime,
    this.endTime,
    this.notes = '',
  });

  /// Crea una instancia a partir del JSON devuelto por el backend.
  factory Session.fromBackendJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      startTime: DateTime.parse(json['start_time'] as String).toLocal(),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String).toLocal()
          : null,
      notes: json['notes'] as String? ?? '',
    );
  }

  /// Convierte la instancia a un Map compatible con el backend.
  Map<String, dynamic> toBackendJson() {
    return {
      'id': id,
      'user_id': userId,
      'start_time': startTime.toUtc().toIso8601String(),
      if (endTime != null) 'end_time': endTime!.toUtc().toIso8601String(),
      'notes': notes,
    };
  }

  /// Indica si la sesión ha finalizado.
  bool get isFinished => endTime != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Session && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
