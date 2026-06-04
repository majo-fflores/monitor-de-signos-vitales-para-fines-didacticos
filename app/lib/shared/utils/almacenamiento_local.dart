import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/models/registro_medicion.dart';

/// Utilidad de persistencia local para usuarios y registros de medición.
/// Abstrae las operaciones de lectura/escritura sobre SharedPreferences
/// siguiendo el patrón ya establecido en el proyecto (alarma_state, theme_provider).
class AlmacenamientoLocal {
  static const _keyUsuarioActivo = 'datavital_usuario_activo_id';
  static const _keyRegistrosPrefix = 'datavital_registros_';

  // ─── Usuario Activo ────────────────────────────────────────────────

  /// Guarda el ID del usuario actualmente seleccionado.
  static Future<void> guardarUsuarioActivo(String? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null) {
      await prefs.remove(_keyUsuarioActivo);
    } else {
      await prefs.setString(_keyUsuarioActivo, id);
    }
  }

  /// Obtiene el ID del último usuario seleccionado.
  static Future<String?> obtenerUsuarioActivoId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsuarioActivo);
  }

  // ─── Registros de Medición ─────────────────────────────────────────

  /// Guarda los registros de medición para un usuario específico.
  static Future<void> guardarRegistros(
    String usuarioId,
    List<RegistroMedicion> registros,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyRegistrosPrefix$usuarioId';
    final jsonList = registros.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(key, jsonList);
  }

  /// Obtiene los registros de medición de un usuario específico.
  static Future<List<RegistroMedicion>> obtenerRegistros(
    String usuarioId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_keyRegistrosPrefix$usuarioId';
      final jsonList = prefs.getStringList(key);
      if (jsonList == null) return [];
      return jsonList
          .map((s) =>
              RegistroMedicion.fromJson(jsonDecode(s) as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error obteniendo registros para $usuarioId: $e');
      return [];
    }
  }

  /// Elimina todos los registros de medición de un usuario específico.
  static Future<void> eliminarRegistrosDeUsuario(String usuarioId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyRegistrosPrefix$usuarioId';
    await prefs.remove(key);
  }
}
