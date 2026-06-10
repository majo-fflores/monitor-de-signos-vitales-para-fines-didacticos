import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/session.dart';

/// Servicio para comunicarse con los endpoints HTTP de sesiones en el backend Go.
class SessionApiService {
  final String baseUrl;
  final http.Client client;

  SessionApiService({
    this.baseUrl = 'http://localhost:8080',
    http.Client? client,
  }) : client = client ?? http.Client();

  /// Crea una nueva sesión para un usuario (POST /sessions).
  Future<Session> crearSesion(int userId) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/sessions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Session.fromBackendJson(data);
      } else {
        throw Exception('Error al crear sesión en el backend: Código ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Fallo al crear sesión en el backend: $e');
    }
  }

  /// Obtiene una sesión específica por ID (GET /sessions/:id).
  Future<Session> obtenerSesion(int id) async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/sessions/$id'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Session.fromBackendJson(data);
      } else {
        throw Exception('Sesión no encontrada o error en el backend: Código ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Fallo al obtener sesión por ID desde el backend: $e');
    }
  }

  /// Obtiene todas las sesiones de un usuario específico (GET /users/:userId/sessions).
  Future<List<Session>> obtenerSesionesDeUsuario(int userId) async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/users/$userId/sessions'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Session.fromBackendJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Error al obtener sesiones del usuario: Código ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Fallo al obtener sesiones de usuario desde el backend: $e');
    }
  }

  /// Finaliza una sesión (PUT /sessions/:id/end).
  Future<void> finalizarSesion(int id, {String notes = ''}) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl/sessions/$id/end'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'notes': notes}),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al finalizar la sesión: Código ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Fallo al finalizar sesión en el backend: $e');
    }
  }

  /// Elimina una sesión por su ID (DELETE /sessions/:id).
  Future<void> eliminarSesion(int id) async {
    try {
      final response = await client.delete(Uri.parse('$baseUrl/sessions/$id'));

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar sesión en el backend: Código ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Fallo al eliminar sesión en el backend: $e');
    }
  }
}
