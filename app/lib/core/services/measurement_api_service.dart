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

  /// Guarda mediciones de un tipo específico para una sesión (POST /{type}).
  /// [type] debe ser uno de: 'ecg', 'bpm', 'spo2', 'air'.
  Future<Measurement> saveMeasurement(
    String type,
    int sessionId,
    List<Sample> samples,
  ) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/$type'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'session_id': sessionId,
          'datos': samples.map((d) => d.toJson()).toList(),
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Measurement.fromJson(data);
      } else {
        throw Exception(
          'Error al guardar medición de $type: Código ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Fallo al guardar medición de $type: $e');
    }
  }

  /// Obtiene las mediciones de un tipo específico para una sesión (GET /sessions/:sessionId/{type}).
  Future<List<Measurement>> getMeasurementsBySession(
    String type,
    int sessionId,
  ) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/sessions/$sessionId/$type'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => Measurement.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Error al obtener mediciones de $type para sesión $sessionId: Código ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception(
        'Fallo al obtener mediciones de $type para sesión desde el backend: $e',
      );
    }
  }

  /// Obtiene todas las mediciones de un tipo específico de un usuario (GET /users/:userId/{type}).
  Future<List<Measurement>> getMeasurementsByUser(
    String type,
    int userId,
  ) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/users/$userId/$type'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => Measurement.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Error al obtener mediciones de $type para usuario $userId: Código ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception(
        'Fallo al obtener mediciones de $type para usuario desde el backend: $e',
      );
    }
  }

  /// Elimina una medición específica por ID (DELETE /{type}/:id).
  Future<void> deleteMeasurement(String type, int id) async {
    try {
      final response = await client.delete(Uri.parse('$baseUrl/$type/$id'));

      if (response.statusCode != 200) {
        throw Exception(
          'Error al eliminar medición de $type con ID $id: Código ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Fallo al eliminar medición de $type en el backend: $e');
    }
  }
}
