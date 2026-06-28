import 'package:flutter/foundation.dart';

/// Modelo inmutable que mapea exactamente el paquete JSON del backend WebSocket.
/// Estructura: {"type": "bpm"|"spo2"|"ecg", "value": 82.5, "timestamp": 1748383032000}
@immutable
class WsPacket {
  final String type;
  final double value;
  final int timestamp;
  final bool? alert;

  const WsPacket({
    required this.type,
    required this.value,
    required this.timestamp,
    this.alert,
  });

  /// Factory constructor de mínima asignación para parsing rápido.
  factory WsPacket.fromJson(Map<String, dynamic> json) => WsPacket(
    type: json['type'] as String,
    value: (json['value'] as num).toDouble(),
    timestamp: (json['timestamp'] as num).toInt(),
    alert: json['alerta'] as bool?,
  );
}
