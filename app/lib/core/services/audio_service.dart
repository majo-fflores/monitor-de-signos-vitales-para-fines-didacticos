import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Servicio de Audio Singleton optimizado para alarmas STR.
/// Controla la reproducción en bucle y las pruebas de tonos de alerta.
class AudioService {
  static AudioService instance = AudioService._internal();
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  String? _currentSound;

  /// Inicia la reproducción de un sonido de alarma en bucle continuo.
  Future<void> startAlarm(String soundName) async {
    if (_isPlaying && _currentSound == soundName) return;

    try {
      await stopAlarm();
      _currentSound = soundName;
      _isPlaying = true;

      // Configurar modo bucle
      await _player.setReleaseMode(ReleaseMode.loop);
      // Reproducir sonido desde los assets
      await _player.play(AssetSource('audio/$soundName.wav'));
    } catch (e) {
      debugPrint('[AudioService] Error al iniciar alarma: $e');
      _isPlaying = false;
      _currentSound = null;
    }
  }

  /// Detiene la reproducción de la alarma.
  Future<void> stopAlarm() async {
    if (!_isPlaying) return;
    try {
      await _player.stop();
      _isPlaying = false;
      _currentSound = null;
    } catch (e) {
      debugPrint('[AudioService] Error al detener alarma: $e');
    }
  }

  /// Reproduce una muestra de 1.5 segundos del tono seleccionado.
  Future<void> testSound(String soundName) async {
    try {
      // Detener cualquier sonido corriendo en el reproductor principal
      await stopAlarm();

      final testPlayer = AudioPlayer();
      await testPlayer.setReleaseMode(ReleaseMode.release);
      await testPlayer.play(AssetSource('audio/$soundName.wav'));

      Timer(const Duration(milliseconds: 1500), () async {
        try {
          await testPlayer.stop();
          await testPlayer.dispose();
        } catch (_) {}
      });
    } catch (e) {
      debugPrint('[AudioService] Error al probar sonido: $e');
    }
  }
}
