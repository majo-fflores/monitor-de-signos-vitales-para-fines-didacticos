// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificadorConexionHash() =>
    r'981fe5220e4b6b8eb7fa3828fe16c570af1adb54';

/// Notifier que administra la conexión WebSocket con el backend.
/// Persiste únicamente la preferencia del Toggle (modo fuente) en SharedPreferences.
///
/// Copied from [NotificadorConexion].
@ProviderFor(NotificadorConexion)
final notificadorConexionProvider =
    NotifierProvider<NotificadorConexion, EstadoConexionBackend>.internal(
      NotificadorConexion.new,
      name: r'notificadorConexionProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificadorConexionHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NotificadorConexion = Notifier<EstadoConexionBackend>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
