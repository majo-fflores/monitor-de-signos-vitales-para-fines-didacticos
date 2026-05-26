// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'historial_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificadorHistorialHash() =>
    r'74ba4d68b36ed25f06b7fbcca5ce333f0c8cdb3a';

/// Notifier reactivo para el historial de mediciones.
/// Los registros se guardan y cargan de forma separada por cada usuario.
///
/// Copied from [NotificadorHistorial].
@ProviderFor(NotificadorHistorial)
final notificadorHistorialProvider =
    NotifierProvider<NotificadorHistorial, EstadoHistorial>.internal(
      NotificadorHistorial.new,
      name: r'notificadorHistorialProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificadorHistorialHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NotificadorHistorial = Notifier<EstadoHistorial>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
