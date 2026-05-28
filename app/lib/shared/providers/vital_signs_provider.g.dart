// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vital_signs_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificadorSignosVitalesHash() =>
    r'31e7e4a6d636d928eacf409ae1fd6ab4b4c2496b';

/// Notifier reactivo para signos vitales de alto rendimiento.
///
/// Características STR avanzadas:
/// - Throttling adaptativo a nivel de frame sincronizado con SchedulerBinding.
/// - Reducción de jank y micro-allocations de memoria.
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
