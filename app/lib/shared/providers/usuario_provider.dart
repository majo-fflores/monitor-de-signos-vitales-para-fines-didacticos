import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/models/usuario.dart';
import '../../core/services/usuario_api_service.dart';
import '../utils/almacenamiento_local.dart';
import 'connection_provider.dart';

part 'usuario_provider.g.dart';

/// Provider para la instancia del servicio de API de usuarios.
/// Deduce la URL base HTTP a partir de la URL de WebSockets.
@riverpod
UsuarioApiService usuarioApiService(UsuarioApiServiceRef ref) {
  final conexionState = ref.watch(notificadorConexionProvider);
  String httpUrl = 'http://localhost:8080';
  final wsUrl = conexionState.wsUrl;
  
  if (wsUrl.startsWith('ws://')) {
    httpUrl = wsUrl.replaceFirst('ws://', 'http://').replaceAll('/ws/sensors', '');
  } else if (wsUrl.startsWith('wss://')) {
    httpUrl = wsUrl.replaceFirst('wss://', 'https://').replaceAll('/ws/sensors', '');
  }
  
  return UsuarioApiService(baseUrl: httpUrl);
}

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
/// Persiste en el backend si el modo simulación está desactivado, o localmente como fallback.
@Riverpod(keepAlive: true)
class NotificadorUsuarios extends _$NotificadorUsuarios {
  @override
  EstadoUsuarios build() {
    final cargando = ref.watch(
      notificadorConexionProvider.select((s) => s.cargando),
    );
    
    if (cargando) {
      return EstadoUsuarios.inicial();
    }

    Future.microtask(() => _cargarUsuarios());
    
    return const EstadoUsuarios(
      usuarios: [],
      cargando: true,
    );
  }

  Future<void> _cargarUsuarios() async {
    final apiService = ref.read(usuarioApiServiceProvider);
    state = state.copiarCon(cargando: true);

    // Al iniciar la app or cambiar de modo, forzamos deseleccionar usuario para obligar a elegir perfil
    await AlmacenamientoLocal.guardarUsuarioActivo(null);

    List<Usuario> usuarios = [];

    try {
      usuarios = await apiService.obtenerUsuarios();
    } catch (e) {
      debugPrint('[NotificadorUsuarios] Error al cargar desde backend: $e');
      usuarios = [];
    }

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
  }) async {
    final apiService = ref.read(usuarioApiServiceProvider);

    try {
      final nuevoUsuario = await apiService.crearUsuario(
        nombre: nombre,
        email: email,
      );
      
      final nuevaLista = [...state.usuarios, nuevoUsuario];
      state = state.copiarCon(
        usuarios: nuevaLista,
        usuarioActivo: nuevoUsuario,
      );
    } catch (e) {
      debugPrint('[NotificadorUsuarios] Error al crear en el backend: $e');
      rethrow;
    }

    await AlmacenamientoLocal.guardarUsuarioActivo(state.usuarioActivo!.id);
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
    final apiService = ref.read(usuarioApiServiceProvider);
    
    try {
      await apiService.eliminarUsuario(usuarioId);
    } catch (e) {
      debugPrint('[NotificadorUsuarios] Error al eliminar en el backend (tal vez no está implementado aún): $e');
    }

    final nuevaLista =
        state.usuarios.where((u) => u.id != usuarioId).toList();

    final bool eraActivo = state.usuarioActivo?.id == usuarioId;

    state = state.copiarCon(
      usuarios: nuevaLista,
      limpiarUsuarioActivo: eraActivo,
    );

    await AlmacenamientoLocal.eliminarRegistrosDeUsuario(usuarioId);
    
    if (eraActivo) {
      await AlmacenamientoLocal.guardarUsuarioActivo(null);
    }
  }
}
