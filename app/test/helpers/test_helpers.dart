import 'package:datavital_flutter/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps the widget under test with a [ProviderScope] and a [MaterialApp]
/// with appropriate theme settings.
Widget createTestableWidget({
  required Widget child,
  List<Override> overrides = const [],
  ThemeMode themeMode = ThemeMode.dark,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: Scaffold(body: child),
    ),
  );
}

/// Helper to test Riverpod providers without UI, managing the container lifecycle.
ProviderContainer createContainer({
  ProviderContainer? parent,
  List<Override> overrides = const [],
  List<ProviderObserver>? observers,
}) {
  final container = ProviderContainer(
    parent: parent,
    overrides: overrides,
    observers: observers,
  );
  addTearDown(container.dispose);
  return container;
}
