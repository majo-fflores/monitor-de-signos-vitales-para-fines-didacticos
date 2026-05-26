import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/models/registro_medicion.dart';
import '../utils/almacenamiento_local.dart';

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
/// Los registros se guardan y cargan de forma separada por cada usuario.
@Riverpod(keepAlive: true)
class NotificadorHistorial extends _$NotificadorHistorial {
  @override
  EstadoHistorial build() {
    return EstadoHistorial.inicial();
  }

  /// Carga los registros de medición de un usuario específico.
  Future<void> cargarHistorial(String usuarioId) async {
    state = state.copiarCon(cargando: true);
    final registros = await AlmacenamientoLocal.obtenerRegistros(usuarioId);
    // Ordenamos por fecha descendente (más reciente primero)
    registros.sort((a, b) => b.fechaRegistro.compareTo(a.fechaRegistro));
    state = state.copiarCon(
      registros: registros,
      cargando: false,
      usuarioIdCargado: usuarioId,
    );
  }

  /// Guarda un nuevo registro de medición para el usuario indicado.
  Future<void> guardarRegistro(RegistroMedicion registro) async {
    final nuevaLista = [registro, ...state.registros];
    state = state.copiarCon(registros: nuevaLista);
    await AlmacenamientoLocal.guardarRegistros(
      registro.usuarioId,
      nuevaLista,
    );
  }

  /// Elimina un registro de medición específico.
  Future<void> eliminarRegistro(String registroId, String usuarioId) async {
    final nuevaLista =
        state.registros.where((r) => r.id != registroId).toList();
    state = state.copiarCon(registros: nuevaLista);
    await AlmacenamientoLocal.guardarRegistros(usuarioId, nuevaLista);
  }

  /// Limpia el historial cargado (al cambiar de usuario).
  void limpiar() {
    state = EstadoHistorial.inicial();
  }
}
