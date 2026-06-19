// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$historyNotifierHash() => r'5e98ac61d07150c10d98896510407e2756c9ac7a';

/// Notifier reactivo para el historial de mediciones.
/// Los registros se guardan y cargan desde el backend.
///
/// Copied from [HistoryNotifier].
@ProviderFor(HistoryNotifier)
final historyNotifierProvider =
    NotifierProvider<HistoryNotifier, HistoryState>.internal(
      HistoryNotifier.new,
      name: r'historyNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$historyNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HistoryNotifier = Notifier<HistoryState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
