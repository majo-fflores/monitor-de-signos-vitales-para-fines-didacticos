import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';

/// Servicio para comunicarse con los endpoints HTTP de usuarios en el backend Go.
class UsuarioApiService {
  final String baseUrl;
  final http.Client client;

  UsuarioApiService({
    this.baseUrl = 'http://localhost:8080',
    http.Client? client,
  }) : client = client ?? http.Client();

  /// Obtiene todos los usuarios desde el backend (GET /users).
  Future<List<Usuario>> obtenerUsuarios() async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/users'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Usuario.fromBackendJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Error al obtener usuarios del backend: Código ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Fallo de conexión al backend de usuarios: $e');
    }
  }

  /// Crea un nuevo usuario en el backend (POST /users).
  Future<Usuario> crearUsuario({
    required String nombre,
    required String email,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': nombre,
          'email': email,
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Usuario.fromBackendJson(data);
      } else {
        final errorMsg = _obtenerMensajeError(response.body);
        throw Exception(errorMsg ?? 'Error al crear usuario en el backend: Código ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Fallo al registrar usuario en el backend: $e');
    }
  }

  /// Obtiene un usuario específico por su ID desde el backend (GET /users/:id).
  Future<Usuario> obtenerUsuarioPorId(String id) async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/users/$id'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Usuario.fromBackendJson(data);
      } else {
        throw Exception('Usuario no encontrado o error en el backend: Código ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Fallo al obtener usuario por ID desde el backend: $e');
    }
  }

  /// Elimina un usuario por su ID en el backend (DELETE /users/:id).
  Future<void> eliminarUsuario(String id) async {
    try {
      final response = await client.delete(Uri.parse('$baseUrl/users/$id'));

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Error al eliminar usuario en el backend: Código ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Fallo al eliminar usuario en el backend: $e');
    }
  }

  String? _obtenerMensajeError(String responseBody) {
    try {
      final map = jsonDecode(responseBody) as Map<String, dynamic>;
      return map['error'] as String?;
    } catch (_) {
      return null;
    }
  }
}
