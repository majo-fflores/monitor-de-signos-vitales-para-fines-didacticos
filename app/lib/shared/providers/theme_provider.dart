import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  static const _themeKey = 'tema_oscuro';
  SharedPreferences? _prefs;

  @override
  ThemeMode build() {
    _initPrefs();
    return ThemeMode.system; // Por defecto usa el del sistema hasta que se carguen los guardados
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    final esOscuro = _prefs?.getBool(_themeKey);
    if (esOscuro != null) {
      state = esOscuro ? ThemeMode.dark : ThemeMode.light;
    }
  }

  Future<void> alternarTema() async {
    final nuevoModo = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    
    state = nuevoModo;
    
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setBool(_themeKey, nuevoModo == ThemeMode.dark);
  }
}
