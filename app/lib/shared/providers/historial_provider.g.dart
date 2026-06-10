// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'historial_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificadorHistorialHash() =>
    r'e3e8adb5bea6b9a0dabc44c4fb7a0e6092cc41f7';

/// Notifier reactivo para el historial de mediciones.
/// Los registros se guardan y cargan desde el backend.
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
