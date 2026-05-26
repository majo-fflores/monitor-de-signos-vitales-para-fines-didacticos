import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/models/usuario.dart';
import '../utils/almacenamiento_local.dart';

part 'usuario_provider.g.dart';

/// Estado inmutable del sistema de usuarios.
@immutable
class EstadoUsuarios {
  final List<Usuario> usuarios;
  final Usuario? usuarioActivo;
  final bool cargando;

  const EstadoUsuarios({
    required this.usuarios,
    required this.cargando,
    this.usuarioActivo,
  });

  factory EstadoUsuarios.inicial() {
    return const EstadoUsuarios(
      usuarios: [],
      cargando: true,
    );
  }

  EstadoUsuarios copiarCon({
    List<Usuario>? usuarios,
    Usuario? usuarioActivo,
    bool? cargando,
    bool limpiarUsuarioActivo = false,
  }) {
    return EstadoUsuarios(
      usuarios: usuarios ?? this.usuarios,
      usuarioActivo:
          limpiarUsuarioActivo ? null : (usuarioActivo ?? this.usuarioActivo),
      cargando: cargando ?? this.cargando,
    );
  }
}

/// Notifier reactivo para la gestión de usuarios.
/// Persiste automáticamente cada cambio en SharedPreferences.
@Riverpod(keepAlive: true)
class NotificadorUsuarios extends _$NotificadorUsuarios {
  @override
  EstadoUsuarios build() {
    _cargarDesdeAlmacenamiento();
    return EstadoUsuarios.inicial();
  }

  Future<void> _cargarDesdeAlmacenamiento() async {
    final usuarios = await AlmacenamientoLocal.obtenerUsuarios();
    
    // Al iniciar la app, no auto-iniciamos sesión para forzar la selección previa a ver los gráficos
    await AlmacenamientoLocal.guardarUsuarioActivo(null);

    state = state.copiarCon(
      usuarios: usuarios,
      usuarioActivo: null,
      cargando: false,
    );
  }

  /// Crea un nuevo usuario y lo selecciona automáticamente como activo.
  Future<void> crearUsuario({
    required String nombre,
    required String email,
    required int edad,
  }) async {
    final nuevoUsuario = Usuario.crear(
      nombre: nombre,
      email: email,
      edad: edad,
    );

    final nuevaLista = [...state.usuarios, nuevoUsuario];
    state = state.copiarCon(
      usuarios: nuevaLista,
      usuarioActivo: nuevoUsuario,
    );

    await AlmacenamientoLocal.guardarUsuarios(nuevaLista);
    await AlmacenamientoLocal.guardarUsuarioActivo(nuevoUsuario.id);
  }

  /// Selecciona un usuario existente como activo.
  void seleccionarUsuario(Usuario usuario) {
    state = state.copiarCon(usuarioActivo: usuario);
    AlmacenamientoLocal.guardarUsuarioActivo(usuario.id);
  }

  /// Deselecciona el usuario activo (vuelve a la pantalla de selección).
  void cambiarUsuario() {
    state = state.copiarCon(limpiarUsuarioActivo: true);
    AlmacenamientoLocal.guardarUsuarioActivo(null);
  }

  /// Elimina un usuario y todos sus registros de medición asociados.
  Future<void> eliminarUsuario(String usuarioId) async {
    final nuevaLista =
        state.usuarios.where((u) => u.id != usuarioId).toList();

    final bool eraActivo = state.usuarioActivo?.id == usuarioId;

    state = state.copiarCon(
      usuarios: nuevaLista,
      limpiarUsuarioActivo: eraActivo,
    );

    await AlmacenamientoLocal.guardarUsuarios(nuevaLista);
    await AlmacenamientoLocal.eliminarRegistrosDeUsuario(usuarioId);
    if (eraActivo) {
      await AlmacenamientoLocal.guardarUsuarioActivo(null);
    }
  }
}
