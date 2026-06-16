import 'package:flutter/foundation.dart';

/// Modelo inmutable de usuario del sistema.
/// Se persiste localmente vía SharedPreferences como JSON serializado.
@immutable
class Usuario {
  final String id;
  final String nombre;
  final String email;
  final int? dni;
  final DateTime creadoEn;

  const Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    this.dni,
    required this.creadoEn,
  });

  /// Genera un ID único basado en timestamp + hash del nombre.
  factory Usuario.crear({
    required String nombre,
    required String email,
    int? dni,
  }) {
    final ahora = DateTime.now();
    final id = '${ahora.millisecondsSinceEpoch}_${nombre.hashCode.abs()}';
    return Usuario(
      id: id,
      nombre: nombre,
      email: email,
      dni: dni,
      creadoEn: ahora,
    );
  }

  /// Deserializa desde un Map JSON.
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      email: json['email'] as String? ?? '',
      dni: json['dni'] as int?,
      creadoEn: DateTime.parse(json['creadoEn'] as String),
    );
  }

  /// Deserializa desde el formato JSON del Backend.
  factory Usuario.fromBackendJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final idStr = rawId is int ? rawId.toString() : (rawId?.toString() ?? '');

    return Usuario(
      id: idStr,
      nombre: json['name'] as String? ?? json['nombre'] as String? ?? '',
      email: json['email'] as String? ?? '',
      dni: json['dni'] as int?,
      creadoEn: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : (json['creadoEn'] != null
                ? DateTime.parse(json['creadoEn'] as String)
                : DateTime.now()),
    );
  }

  /// Serializa a Map JSON para persistencia.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      if (dni != null) 'dni': dni,
      'creadoEn': creadoEn.toIso8601String(),
    };
  }

  /// Convierte a formato JSON compatible con el Backend.
  Map<String, dynamic> toBackendJson() {
    return {'name': nombre, 'email': email, if (dni != null) 'dni': dni};
  }

  /// Obtiene las iniciales del nombre para mostrar en el avatar.
  String get iniciales {
    final trimNombre = nombre.trim();
    if (trimNombre.isEmpty) return '?';
    final partes = trimNombre.split(RegExp(r'\s+'));
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return trimNombre[0].toUpperCase();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Usuario && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
