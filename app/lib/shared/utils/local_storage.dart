import 'package:shared_preferences/shared_preferences.dart';

/// Utilidad de persistencia local para usuarios y registros de medición.
/// Abstrae las operaciones de lectura/escritura sobre SharedPreferences
/// siguiendo el patrón ya establecido en el proyecto.
class LocalStorage {
  static const _keyActiveUserId = 'datavital_usuario_activo_id';

  // ─── Usuario Activo ────────────────────────────────────────────────

  /// Guarda el ID del usuario actualmente seleccionado.
  static Future<void> saveActiveUser(String? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null) {
      await prefs.remove(_keyActiveUserId);
    } else {
      await prefs.setString(_keyActiveUserId, id);
    }
  }

  /// Obtiene el ID del último usuario seleccionado.
  static Future<String?> getActiveUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyActiveUserId);
  }
}
