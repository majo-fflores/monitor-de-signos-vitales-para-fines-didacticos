// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userApiServiceHash() => r'292928c55e62c7501fe9ba9d63c5266533753f1b';

/// Provider para la instancia del servicio de API de usuarios.
/// Deduce la URL base HTTP a partir de la URL de WebSockets.
///
/// Copied from [userApiService].
@ProviderFor(userApiService)
final userApiServiceProvider = AutoDisposeProvider<UserApiService>.internal(
  userApiService,
  name: r'userApiServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userApiServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserApiServiceRef = AutoDisposeProviderRef<UserApiService>;
String _$usersNotifierHash() => r'f5cc9e4dbfd42c529863fa88d0d443b1a583c37d';

/// Notifier reactivo para la gestión de usuarios.
/// Persiste en el backend si el modo simulación está desactivado, o localmente como fallback.
///
/// Copied from [UsersNotifier].
@ProviderFor(UsersNotifier)
final usersNotifierProvider =
    NotifierProvider<UsersNotifier, UsersState>.internal(
      UsersNotifier.new,
      name: r'usersNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$usersNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$UsersNotifier = Notifier<UsersState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
