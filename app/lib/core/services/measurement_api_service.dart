import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/measurement.dart';

/// Servicio para comunicarse con los endpoints HTTP de mediciones en el backend Go.
/// Soporta ECG, BPM, SpO2 y calidad de aire (AIR).
class MeasurementApiService {
  final String baseUrl;
  final http.Client client;

  MeasurementApiService({
    this.baseUrl = 'http://localhost:8080',
    http.Client? client,
  }) : client = client ?? http.Client();

  /// Guarda mediciones de un tipo específico para una sesión (POST /{tipo}).
  /// [tipo] debe ser uno de: 'ecg', 'bpm', 'spo2', 'air'.
  Future<Measurement> guardarMedicion(String tipo, int sessionId, List<Sample> datos) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/$tipo'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'session_id': sessionId,
          'datos': datos.map((d) => d.toJson()).toList(),
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Measurement.fromJson(data);
      } else {
        throw Exception('Error al guardar medición de $tipo: Código ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Fallo al guardar medición de $tipo: $e');
    }
  }

  /// Obtiene las mediciones de un tipo específico para una sesión (GET /sessions/:sessionId/{tipo}).
  Future<List<Measurement>> obtenerMedicionesPorSesion(String tipo, int sessionId) async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/sessions/$sessionId/$tipo'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Measurement.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Error al obtener mediciones de $tipo para sesión $sessionId: Código ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Fallo al obtener mediciones de $tipo para sesión desde el backend: $e');
    }
  }

  /// Obtiene todas las mediciones de un tipo específico de un usuario (GET /users/:userId/{tipo}).
  Future<List<Measurement>> obtenerMedicionesPorUsuario(String tipo, int userId) async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/users/$userId/$tipo'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Measurement.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Error al obtener mediciones de $tipo para usuario $userId: Código ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Fallo al obtener mediciones de $tipo para usuario desde el backend: $e');
    }
  }

  /// Elimina una medición específica por ID (DELETE /{tipo}/:id).
  Future<void> eliminarMedicion(String tipo, int id) async {
    try {
      final response = await client.delete(Uri.parse('$baseUrl/$tipo/$id'));

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar medición de $tipo con ID $id: Código ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Fallo al eliminar medición de $tipo en el backend: $e');
    }
  }
}
