import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

import '../models/session.dart';
import '../models/session_summary.dart';

/// Servicio para comunicarse con los endpoints HTTP de sesiones en el backend Go.
class SessionApiService {
  final String baseUrl;
  final http.Client client;

  SessionApiService({
    this.baseUrl = 'http://localhost:8080',
    http.Client? client,
  }) : client = client ?? http.Client();

  /// Crea una nueva sesión para un usuario (POST /sessions).
  Future<Session> createSession(int userId) async {
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
        throw Exception(
          'Error al crear sesión en el backend: Código ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Fallo al crear sesión en el backend: $e');
    }
  }

  /// Obtiene una sesión específica por ID (GET /sessions/:id).
  Future<Session> getSession(int id) async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/sessions/$id'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Session.fromBackendJson(data);
      } else {
        throw Exception(
          'Sesión no encontrada o error en el backend: Código ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Fallo al obtener sesión por ID desde el backend: $e');
    }
  }

  /// Obtiene todas las sesiones de un usuario específico (GET /users/:userId/sessions).
  Future<List<Session>> getSessionsByUser(int userId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/users/$userId/sessions'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map(
              (json) => Session.fromBackendJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw Exception(
          'Error al obtener sesiones del usuario: Código ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception(
        'Fallo al obtener sesiones de usuario desde el backend: $e',
      );
    }
  }

  /// Finaliza una sesión (PUT /sessions/:id/end).
  Future<void> endSession(int id, {String notes = ''}) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl/sessions/$id/end'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'notes': notes}),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Error al finalizar la sesión: Código ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Fallo al finalizar sesión en el backend: $e');
    }
  }

  /// Elimina una sesión por su ID (DELETE /sessions/:id).
  Future<void> deleteSession(int id) async {
    try {
      final response = await client.delete(Uri.parse('$baseUrl/sessions/$id'));

      if (response.statusCode != 200) {
        throw Exception(
          'Error al eliminar sesión en el backend: Código ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Fallo al eliminar sesión en el backend: $e');
    }
  }

  /// Obtiene todos los resúmenes de sesiones de un usuario (GET /users/:userId/session-summaries).
  /// Endpoint batch optimizado: 1 sola llamada HTTP.
  Future<List<SessionWithSummary>> getSessionSummaries(int userId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/users/$userId/session-summaries'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map(
              (json) =>
                  SessionWithSummary.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw Exception(
          'Error al obtener resúmenes de sesiones del usuario: Código ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception(
        'Fallo al obtener resúmenes de sesiones de usuario desde el backend: $e',
      );
    }
  }

  /// Obtiene el resumen de una sesión individual (GET /sessions/:id/summary).
  /// Se usa solo para el diálogo de fin de sesión.
  Future<SessionSummary> getSessionSummary(int sessionId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/sessions/$sessionId/summary'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return SessionSummary.fromJson(data);
      } else {
        throw Exception(
          'Error al obtener resumen de la sesión: Código ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception(
        'Fallo al obtener resumen de sesión desde el backend: $e',
      );
    }
  }

  /// Exporta los datos de una sesión en CSV y devuelve la ruta del archivo guardado (o null si el usuario canceló).
  Future<String?> exportSessionCsv(int sessionId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/sessions/$sessionId/export.csv'),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Error al exportar sesión: Código ${response.statusCode}',
        );
      }

      String filename = 'session_$sessionId.csv';
      final contentDisposition = response.headers['content-disposition'];
      if (contentDisposition != null) {
        final match = RegExp(
          r'filename="?([^"]+)"?',
        ).firstMatch(contentDisposition);
        if (match != null) {
          filename = match.group(1)!;
        }
      }

      final selectedPath = await FilePicker.saveFile(
        dialogTitle: 'Seleccione dónde guardar el archivo CSV',
        fileName: filename,
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (selectedPath == null) {
        return null;
      }

      final file = File(selectedPath);
      await file.writeAsBytes(response.bodyBytes);
      return file.path;
    } catch (e) {
      throw Exception('Fallo al exportar sesión en CSV: $e');
    }
  }
}
