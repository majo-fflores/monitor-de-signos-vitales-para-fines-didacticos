import 'package:flutter/foundation.dart';

/// Modelo inmutable de usuario del sistema.
/// Se persiste localmente vía SharedPreferences como JSON serializado.
@immutable
class User {
  final String id;
  final String name;
  final String email;
  final int? dni;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.dni,
    required this.createdAt,
  });

  /// Genera un ID único basado en timestamp + hash del nombre.
  factory User.crear({required String name, required String email, int? dni}) {
    final ahora = DateTime.now();
    final id = '${ahora.millisecondsSinceEpoch}_${name.hashCode.abs()}';
    return User(id: id, name: name, email: email, dni: dni, createdAt: ahora);
  }

  /// Deserializa desde un Map JSON.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String? ?? json['nombre'] as String? ?? '',
      email: json['email'] as String? ?? '',
      dni: json['dni'] as int?,
      createdAt: DateTime.parse(
        json['createdAt'] as String? ??
            json['creadoEn'] as String? ??
            DateTime.now().toIso8601String(),
      ),
    );
  }

  /// Deserializa desde el formato JSON del Backend.
  factory User.fromBackendJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final idStr = rawId is int ? rawId.toString() : (rawId?.toString() ?? '');

    return User(
      id: idStr,
      name: json['name'] as String? ?? json['nombre'] as String? ?? '',
      email: json['email'] as String? ?? '',
      dni: json['dni'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : (json['creadoEn'] != null
                ? DateTime.parse(json['creadoEn'] as String)
                : (json['createdAt'] != null
                      ? DateTime.parse(json['createdAt'] as String)
                      : DateTime.now())),
    );
  }

  /// Serializa a Map JSON para persistencia.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (dni != null) 'dni': dni,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Convierte a formato JSON compatible con el Backend.
  Map<String, dynamic> toBackendJson() {
    return {'name': name, 'email': email, if (dni != null) 'dni': dni};
  }

  /// Obtiene las iniciales del nombre para mostrar en el avatar.
  String get initials {
    final trimNombre = name.trim();
    if (trimNombre.isEmpty) return '?';
    final partes = trimNombre.split(RegExp(r'\s+'));
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return trimNombre[0].toUpperCase();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is User && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
