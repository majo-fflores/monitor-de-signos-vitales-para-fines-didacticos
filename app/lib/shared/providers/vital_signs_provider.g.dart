// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vital_signs_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$vitalSignsNotifierHash() =>
    r'5534e23fb961b79d723c9d59b80134a2d8932a30';

/// Notifier reactivo para signos vitales de alto rendimiento.
///
/// Características STR avanzadas:
/// - Throttling adaptativo a nivel de frame sincronizado con SchedulerBinding.
/// - Reducción de jank y micro-allocations de memoria.
///
/// Copied from [VitalSignsNotifier].
@ProviderFor(VitalSignsNotifier)
final vitalSignsNotifierProvider =
    NotifierProvider<VitalSignsNotifier, VitalSignsState>.internal(
      VitalSignsNotifier.new,
      name: r'vitalSignsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$vitalSignsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$VitalSignsNotifier = Notifier<VitalSignsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
