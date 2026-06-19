import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  static const _themeKey = 'tema_oscuro';
  static const _themeModeKey = 'tema_modo_str';
  SharedPreferences? _prefs;

  @override
  ThemeMode build() {
    _initPrefs();
    return ThemeMode
        .system; // Por defecto usa el del sistema hasta que se carguen los guardados
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    final modoStr = _prefs?.getString(_themeModeKey);
    if (modoStr != null) {
      if (modoStr == 'light') {
        state = ThemeMode.light;
      } else if (modoStr == 'dark') {
        state = ThemeMode.dark;
      } else {
        state = ThemeMode.system;
      }
    } else {
      // Compatibilidad con la clave booleana anterior
      final esOscuro = _prefs?.getBool(_themeKey);
      if (esOscuro != null) {
        state = esOscuro ? ThemeMode.dark : ThemeMode.light;
      }
    }
  }

  Future<void> changeTheme(ThemeMode modo) async {
    state = modo;
    _prefs ??= await SharedPreferences.getInstance();
    String modoStr;
    switch (modo) {
      case ThemeMode.light:
        modoStr = 'light';
        break;
      case ThemeMode.dark:
        modoStr = 'dark';
        break;
      case ThemeMode.system:
        modoStr = 'system';
        break;
    }
    await _prefs?.setString(_themeModeKey, modoStr);
  }

  Future<void> toggleTheme() async {
    final nuevoModo = state == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    await changeTheme(nuevoModo);
  }
}
