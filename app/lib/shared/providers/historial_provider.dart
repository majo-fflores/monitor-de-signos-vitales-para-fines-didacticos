import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/models/measurement.dart';
import '../../core/models/registro_medicion.dart';
import 'session_provider.dart';

part 'historial_provider.g.dart';

/// Estado inmutable del historial de mediciones del usuario activo.
@immutable
class EstadoHistorial {
  final List<RegistroMedicion> registros;
  final bool cargando;
  final String? usuarioIdCargado;

  const EstadoHistorial({
    required this.registros,
    required this.cargando,
    this.usuarioIdCargado,
  });

  factory EstadoHistorial.inicial() {
    return const EstadoHistorial(
      registros: [],
      cargando: false,
    );
  }

  EstadoHistorial copiarCon({
    List<RegistroMedicion>? registros,
    bool? cargando,
    String? usuarioIdCargado,
  }) {
    return EstadoHistorial(
      registros: registros ?? this.registros,
      cargando: cargando ?? this.cargando,
      usuarioIdCargado: usuarioIdCargado ?? this.usuarioIdCargado,
    );
  }
}

/// Notifier reactivo para el historial de mediciones.
/// Los registros se guardan y cargan desde el backend.
@Riverpod(keepAlive: true)
class NotificadorHistorial extends _$NotificadorHistorial {
  @override
  EstadoHistorial build() {
    return EstadoHistorial.inicial();
  }

  /// Carga los registros de medición de un usuario específico desde el backend.
  Future<void> cargarHistorial(String usuarioId) async {
    state = state.copiarCon(cargando: true);
    List<RegistroMedicion> registros = [];
    final uId = int.tryParse(usuarioId);

    if (uId != null) {
      try {
        final sessionApi = ref.read(sessionApiServiceProvider);
        final measApi = ref.read(measurementApiServiceProvider);

        final sessions = await sessionApi.obtenerSesionesDeUsuario(uId);

        final allBpm = await measApi.obtenerMedicionesPorUsuario('bpm', uId);
        final allSpo2 = await measApi.obtenerMedicionesPorUsuario('spo2', uId);
        final allAir = await measApi.obtenerMedicionesPorUsuario('air', uId);

        final bpmBySession = <int, List<Measurement>>{};
        for (var m in allBpm) {
          bpmBySession.putIfAbsent(m.sessionId, () => []).add(m);
        }
        final spo2BySession = <int, List<Measurement>>{};
        for (var m in allSpo2) {
          spo2BySession.putIfAbsent(m.sessionId, () => []).add(m);
        }
        final airBySession = <int, List<Measurement>>{};
        for (var m in allAir) {
          airBySession.putIfAbsent(m.sessionId, () => []).add(m);
        }

        for (var session in sessions) {
          registros.add(
            RegistroMedicion.fromBackendSession(
              session,
              bpm: bpmBySession[session.id],
              spo2: spo2BySession[session.id],
              air: airBySession[session.id],
              notasClinicas: session.notes,
            ),
          );
        }

        // Ordenamos por fecha descendente (más reciente primero)
        registros.sort((a, b) => b.fechaRegistro.compareTo(a.fechaRegistro));
      } catch (e) {
        debugPrint('[NotificadorHistorial] Error al cargar historial desde el backend: $e');
        registros = [];
      }
    }

    state = state.copiarCon(
      registros: registros,
      cargando: false,
      usuarioIdCargado: usuarioId,
    );
  }

  /// Guarda un nuevo registro en memoria para visualización inmediata.
  Future<void> guardarRegistro(RegistroMedicion registro) async {
    final nuevaLista = [registro, ...state.registros];
    state = state.copiarCon(registros: nuevaLista);
  }

  /// Elimina un registro de medición específico (elimina la sesión del backend).
  Future<void> eliminarRegistro(String registroId, String usuarioId) async {
    final nuevaLista =
        state.registros.where((r) => r.id != registroId).toList();
    state = state.copiarCon(registros: nuevaLista);

    final sessionId = int.tryParse(registroId);
    if (sessionId != null) {
      try {
        await ref.read(sessionApiServiceProvider).eliminarSesion(sessionId);
      } catch (e) {
        debugPrint('[NotificadorHistorial] Error al eliminar sesión $sessionId del backend: $e');
      }
    }
  }

  /// Limpia el historial cargado (al cambiar de usuario).
  void limpiar() {
    state = EstadoHistorial.inicial();
  }
}
