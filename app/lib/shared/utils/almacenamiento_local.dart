import 'package:shared_preferences/shared_preferences.dart';

/// Utilidad de persistencia local para usuarios y registros de medición.
/// Abstrae las operaciones de lectura/escritura sobre SharedPreferences
/// siguiendo el patrón ya establecido en el proyecto (alarma_state, theme_provider).
class AlmacenamientoLocal {
  static const _keyUsuarioActivo = 'datavital_usuario_activo_id';

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
}
