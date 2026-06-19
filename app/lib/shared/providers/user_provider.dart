import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/models/user.dart';
import '../../core/services/user_api_service.dart';
import '../utils/local_storage.dart';
import 'connection_provider.dart';
import 'session_provider.dart';

part 'user_provider.g.dart';

/// Provider para la instancia del servicio de API de usuarios.
/// Deduce la URL base HTTP a partir de la URL de WebSockets.
@riverpod
UserApiService userApiService(UserApiServiceRef ref) {
  final connectionState = ref.watch(connectionNotifierProvider);
  String httpUrl = 'http://localhost:8080';
  final wsUrl = connectionState.wsUrl;

  if (wsUrl.startsWith('ws://')) {
    httpUrl = wsUrl
        .replaceFirst('ws://', 'http://')
        .replaceAll('/ws/sensors', '');
  } else if (wsUrl.startsWith('wss://')) {
    httpUrl = wsUrl
        .replaceFirst('wss://', 'https://')
        .replaceAll('/ws/sensors', '');
  }

  return UserApiService(baseUrl: httpUrl);
}

/// Estado inmutable del sistema de usuarios.
@immutable
class UsersState {
  final List<User> users;
  final User? activeUser;
  final bool isLoading;

  const UsersState({
    required this.users,
    required this.isLoading,
    this.activeUser,
  });

  factory UsersState.inicial() {
    return const UsersState(users: [], isLoading: true);
  }

  UsersState copiarCon({
    List<User>? users,
    User? activeUser,
    bool? isLoading,
    bool clearActiveUser = false,
  }) {
    return UsersState(
      users: users ?? this.users,
      activeUser: clearActiveUser ? null : (activeUser ?? this.activeUser),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Notifier reactivo para la gestión de usuarios.
/// Persiste en el backend si el modo simulación está desactivado, o localmente como fallback.
@Riverpod(keepAlive: true)
class UsersNotifier extends _$UsersNotifier {
  @override
  UsersState build() {
    final isLoading = ref.watch(
      connectionNotifierProvider.select((s) => s.isLoading),
    );

    if (isLoading) {
      return UsersState.inicial();
    }

    Future.microtask(() => _loadUsers());

    return const UsersState(users: [], isLoading: true);
  }

  Future<void> _loadUsers() async {
    final apiService = ref.read(userApiServiceProvider);
    state = state.copiarCon(isLoading: true);

    // Al iniciar la app o cambiar de modo, forzamos deseleccionar usuario para obligar a elegir perfil
    await LocalStorage.saveActiveUser(null);

    List<User> users = [];

    try {
      users = await apiService.getUsers();
    } catch (e) {
      debugPrint('[UsersNotifier] Error al cargar desde backend: $e');
      users = [];
    }

    state = state.copiarCon(users: users, activeUser: null, isLoading: false);
  }

  /// Crea un nuevo usuario y lo selecciona automáticamente como activo.
  Future<void> createUser({
    required String name,
    required String email,
    required int dni,
  }) async {
    final apiService = ref.read(userApiServiceProvider);

    try {
      final newUser = await apiService.createUser(
        name: name,
        email: email,
        dni: dni,
      );

      final newList = [...state.users, newUser];
      state = state.copiarCon(users: newList, activeUser: newUser);
    } catch (e) {
      debugPrint('[UsersNotifier] Error al crear en el backend: $e');
      rethrow;
    }

    await LocalStorage.saveActiveUser(state.activeUser!.id);
  }

  /// Selecciona un usuario existente como activo.
  void selectUser(User user) {
    state = state.copiarCon(activeUser: user);
    LocalStorage.saveActiveUser(user.id);
  }

  /// Deselecciona el usuario activo (vuelve a la pantalla de selección).
  void changeUser() {
    state = state.copiarCon(clearActiveUser: true);
    LocalStorage.saveActiveUser(null);
  }

  /// Elimina un usuario y todos sus registros de medición asociados.
  Future<void> deleteUser(String userId) async {
    final apiService = ref.read(userApiServiceProvider);

    // Eliminación en cascada manual de sesiones en el backend
    final uId = int.tryParse(userId);
    if (uId != null) {
      try {
        final sessionApi = ref.read(sessionApiServiceProvider);
        final sessions = await sessionApi.getSessionsByUser(uId);
        for (var session in sessions) {
          await sessionApi.deleteSession(session.id);
        }
      } catch (e) {
        debugPrint(
          '[UsersNotifier] Error al eliminar sesiones en cascada en backend: $e',
        );
      }
    }

    try {
      await apiService.deleteUser(userId);
    } catch (e) {
      debugPrint(
        '[UsersNotifier] Error al eliminar en el backend (tal vez no está implementado aún): $e',
      );
    }

    final newList = state.users.where((u) => u.id != userId).toList();

    final bool wasActive = state.activeUser?.id == userId;

    state = state.copiarCon(users: newList, clearActiveUser: wasActive);

    if (wasActive) {
      await LocalStorage.saveActiveUser(null);
    }
  }
}
