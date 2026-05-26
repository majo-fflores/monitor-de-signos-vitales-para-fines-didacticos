// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuario_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificadorUsuariosHash() =>
    r'2f14dbe937cc7d8ea95f8984807d87639b6732d5';

/// Notifier reactivo para la gestión de usuarios.
/// Persiste automáticamente cada cambio en SharedPreferences.
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
