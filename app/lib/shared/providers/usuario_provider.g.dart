// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuario_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$usuarioApiServiceHash() => r'657f510cdf99af4a2a6a79b044d560f52964f044';

/// Provider para la instancia del servicio de API de usuarios.
/// Deduce la URL base HTTP a partir de la URL de WebSockets.
///
/// Copied from [usuarioApiService].
@ProviderFor(usuarioApiService)
final usuarioApiServiceProvider =
    AutoDisposeProvider<UsuarioApiService>.internal(
      usuarioApiService,
      name: r'usuarioApiServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$usuarioApiServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UsuarioApiServiceRef = AutoDisposeProviderRef<UsuarioApiService>;
String _$notificadorUsuariosHash() =>
    r'cbaaa8e0cbef59ffd4a9a98c4a232bd8e40f7b94';

/// Notifier reactivo para la gestión de usuarios.
/// Persiste en el backend si el modo simulación está desactivado, o localmente como fallback.
///
/// Copied from [NotificadorUsuarios].
@ProviderFor(NotificadorUsuarios)
final notificadorUsuariosProvider =
    NotifierProvider<NotificadorUsuarios, EstadoUsuarios>.internal(
      NotificadorUsuarios.new,
      name: r'notificadorUsuariosProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificadorUsuariosHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NotificadorUsuarios = Notifier<EstadoUsuarios>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
