import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Servicio de Audio Singleton optimizado para alarmas STR.
/// Controla la reproducción en bucle y las pruebas de tonos de alerta.
class ServicioAudio {
  static final ServicioAudio instancia = ServicioAudio._internal();
  ServicioAudio._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _reproduciendo = false;
  String? _sonidoActual;

  /// Inicia la reproducción de un sonido de alarma en bucle continuo.
  Future<void> iniciarAlarma(String nombreSonido) async {
    if (_reproduciendo && _sonidoActual == nombreSonido) return;

    try {
      await detenerAlarma();
      _sonidoActual = nombreSonido;
      _reproduciendo = true;

      // Configurar modo bucle
      await _player.setReleaseMode(ReleaseMode.loop);
      // Reproducir sonido desde los assets
      await _player.play(AssetSource('audio/$nombreSonido.wav'));
    } catch (e) {
      debugPrint('[ServicioAudio] Error al iniciar alarma: $e');
      _reproduciendo = false;
      _sonidoActual = null;
    }
  }

  /// Detiene la reproducción de la alarma.
  Future<void> detenerAlarma() async {
    if (!_reproduciendo) return;
    try {
      await _player.stop();
      _reproduciendo = false;
      _sonidoActual = null;
    } catch (e) {
      debugPrint('[ServicioAudio] Error al detener alarma: $e');
    }
  }

  /// Reproduce una muestra de 1.5 segundos del tono seleccionado.
  Future<void> probarSonido(String nombreSonido) async {
    try {
      // Detener cualquier sonido corriendo en el reproductor principal
      await detenerAlarma();

      final playerPrueba = AudioPlayer();
      await playerPrueba.setReleaseMode(ReleaseMode.release);
      await playerPrueba.play(AssetSource('audio/$nombreSonido.wav'));

      Timer(const Duration(milliseconds: 1500), () async {
        try {
          await playerPrueba.stop();
          await playerPrueba.dispose();
        } catch (_) {}
      });
    } catch (e) {
      debugPrint('[ServicioAudio] Error al probar sonido: $e');
    }
  }
}
