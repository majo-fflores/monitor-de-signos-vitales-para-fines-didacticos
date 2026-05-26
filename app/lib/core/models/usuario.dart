import 'package:flutter/foundation.dart';

/// Modelo inmutable de usuario del sistema.
/// Se persiste localmente vía SharedPreferences como JSON serializado.
@immutable
class Usuario {
  final String id;
  final String nombre;
  final String email;
  final int edad;
  final DateTime creadoEn;

  const Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.edad,
    required this.creadoEn,
  });

  /// Genera un ID único basado en timestamp + hash del nombre.
  factory Usuario.crear({
    required String nombre,
    required String email,
    required int edad,
  }) {
    final ahora = DateTime.now();
    final id = '${ahora.millisecondsSinceEpoch}_${nombre.hashCode.abs()}';
    return Usuario(
      id: id,
      nombre: nombre,
      email: email,
      edad: edad,
      creadoEn: ahora,
    );
  }

  /// Deserializa desde un Map JSON.
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      email: json['email'] as String? ?? '',
      edad: json['edad'] as int,
      creadoEn: DateTime.parse(json['creadoEn'] as String),
    );
  }

  /// Serializa a Map JSON para persistencia.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'edad': edad,
      'creadoEn': creadoEn.toIso8601String(),
    };
  }

  /// Obtiene las iniciales del nombre para mostrar en el avatar.
  String get iniciales {
    final partes = nombre.trim().split(RegExp(r'\s+'));
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Usuario && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
