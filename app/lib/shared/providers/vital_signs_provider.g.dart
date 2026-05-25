// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vital_signs_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificadorSignosVitalesHash() =>
    r'491d20064dc4a2ee35ab5d6df8d3e4074353b5da';

/// Notifier reactivo que simula los sensores en tiempo real de forma matemática.
/// Reemplazo directo con Riverpod del store de Zustand (useVitalSignsStore).
///
/// Copied from [NotificadorSignosVitales].
@ProviderFor(NotificadorSignosVitales)
final notificadorSignosVitalesProvider =
    NotifierProvider<NotificadorSignosVitales, EstadoSignosVitales>.internal(
      NotificadorSignosVitales.new,
      name: r'notificadorSignosVitalesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificadorSignosVitalesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NotificadorSignosVitales = Notifier<EstadoSignosVitales>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
