import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

/// Servicio para comunicarse con los endpoints HTTP de usuarios en el backend Go.
class UserApiService {
  final String baseUrl;
  final http.Client client;

  UserApiService({this.baseUrl = 'http://localhost:8080', http.Client? client})
    : client = client ?? http.Client();

  /// Obtiene todos los usuarios desde el backend (GET /users).
  Future<List<User>> getUsers() async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/users'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => User.fromBackendJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Error al obtener usuarios del backend: Código ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Fallo de conexión al backend de usuarios: $e');
    }
  }

  /// Crea un nuevo usuario en el backend (POST /users).
  Future<User> createUser({
    required String name,
    required String email,
    required int dni,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'dni': dni}),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return User.fromBackendJson(data);
      } else {
        final errorMsg = _getErrorMessage(response.body);
        throw Exception(
          errorMsg ??
              'Error al crear usuario en el backend: Código ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Fallo al registrar usuario en el backend: $e');
    }
  }

  /// Obtiene un usuario específico por su ID desde el backend (GET /users/:id).
  Future<User> getUserById(String id) async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/users/$id'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return User.fromBackendJson(data);
      } else {
        throw Exception(
          'Usuario no encontrado o error en el backend: Código ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Fallo al obtener usuario por ID desde el backend: $e');
    }
  }

  /// Elimina un usuario por su ID en el backend (DELETE /users/:id).
  Future<void> deleteUser(String id) async {
    try {
      final response = await client.delete(Uri.parse('$baseUrl/users/$id'));

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception(
          'Error al eliminar usuario en el backend: Código ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Fallo al eliminar usuario en el backend: $e');
    }
  }

  String? _getErrorMessage(String responseBody) {
    try {
      final map = jsonDecode(responseBody) as Map<String, dynamic>;
      return map['error'] as String?;
    } catch (_) {
      return null;
    }
  }
}
