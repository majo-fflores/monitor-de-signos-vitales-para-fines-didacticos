import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/breakpoints.dart';
import '../../../core/models/registro_medicion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/connection_provider.dart';
import '../../../shared/providers/historial_provider.dart';
import '../../../shared/providers/session_provider.dart';
import '../../../shared/providers/usuario_provider.dart';
import '../../../shared/providers/vital_signs_provider.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/kpi_panels.dart';
import '../widgets/save_session_dialog.dart';
import '../widgets/wave_charts.dart';

/// Vista principal de monitoreo en tiempo real.
/// Se suscribe de manera selectiva a los flujos del NotificadorSignosVitales.
class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  bool _grabando = false;
  int _segundosGrabacion = 0;
  Timer? _timerGrabacion;
  final List<int> _frecuenciasGrabadas = [];
  final List<int> _ppgFrecuenciasGrabadas = [];
  final List<int> _spo2Grabados = [];
  final List<int> _co2Grabados = [];
  int _alertasDisparadas = 0;
  int? _sessionId;

  @override
  void initState() {
    super.initState();
    // Si la configuración ya terminó de cargar al entrar (ej: navegación posterior), inicializamos de inmediato.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final configConexion = ref.read(notificadorConexionProvider);
      if (!configConexion.cargando) {
        final notifier = ref.read(notificadorSignosVitalesProvider.notifier);
        final ws = ref.read(notificadorConexionProvider.notifier).wsService;
        notifier.iniciarConWebSocket(ws.packetStream);
      }
    });
  }

  @override
  void dispose() {
    _timerGrabacion?.cancel();
    super.dispose();
  }

  Future<void> _iniciarGrabacion() async {
    final usuarioActivo = ref.read(notificadorUsuariosProvider).usuarioActivo;
    if (usuarioActivo == null) return;

    try {
      final session = await ref.read(sessionApiServiceProvider).crearSesion(int.parse(usuarioActivo.id));
      _sessionId = session.id;
    } catch (e) {
      debugPrint('Error al crear sesión en backend: $e');
      _sessionId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    }

    ref.read(notificadorSignosVitalesProvider.notifier).startBuffering();

    setState(() {
      _grabando = true;
      _segundosGrabacion = 0;
      _frecuenciasGrabadas.clear();
      _ppgFrecuenciasGrabadas.clear();
      _spo2Grabados.clear();
      _co2Grabados.clear();
      _alertasDisparadas = 0;
    });

    _timerGrabacion = Timer.periodic(const Duration(seconds: 1), (timer) {
      final signos = ref.read(notificadorSignosVitalesProvider);

      _frecuenciasGrabadas.add(signos.frecuenciaCardiaca);
      _ppgFrecuenciasGrabadas.add(signos.ppgFrecuenciaCardiaca);
      _spo2Grabados.add(signos.nivelSpo2);
      _co2Grabados.add(signos.nivelCo2);

      // Verificación simple de alertas/anomalías
      if (signos.frecuenciaCardiaca < 60 ||
          signos.frecuenciaCardiaca > 100 ||
          // signos.nivelSpo2 < 95 ||
          signos.nivelCo2 > 1000) {
        _alertasDisparadas++;
      }

      setState(() {
        _segundosGrabacion++;
      });
    });
  }

  void _detenerYGuardar() {
    _timerGrabacion?.cancel();
    _timerGrabacion = null;

    final usuarioActivo = ref.read(notificadorUsuariosProvider).usuarioActivo;
    if (usuarioActivo == null) return;

    // Calcular promedios
    final fcProm = _frecuenciasGrabadas.isEmpty
        ? 70
        : (_frecuenciasGrabadas.reduce((a, b) => a + b) ~/
              _frecuenciasGrabadas.length);
    final ppgProm = _ppgFrecuenciasGrabadas.isEmpty
        ? 72
        : (_ppgFrecuenciasGrabadas.reduce((a, b) => a + b) ~/
              _ppgFrecuenciasGrabadas.length);
    final spo2Prom = _spo2Grabados.isEmpty
        ? 98
        : (_spo2Grabados.reduce((a, b) => a + b) ~/ _spo2Grabados.length);
    final co2Prom = _co2Grabados.isEmpty
        ? 400
        : (_co2Grabados.reduce((a, b) => a + b) ~/ _co2Grabados.length);

    // Mostrar diálogo premium componentizado
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return SaveSessionDialog(
          segundosGrabacion: _segundosGrabacion,
          fcProm: fcProm,
          ppgProm: ppgProm,
          spo2Prom: spo2Prom,
          co2Prom: co2Prom,
          onCancel: () {
            Navigator.pop(context);
            setState(() => _grabando = false);
          },
          onSave: (notas) async {
            final activeSessionId = _sessionId;
            final buffers = ref.read(notificadorSignosVitalesProvider.notifier).stopBuffering();

            if (activeSessionId != null) {
              try {
                final measApi = ref.read(measurementApiServiceProvider);
                final sessionApi = ref.read(sessionApiServiceProvider);

                if (buffers['ecg'] != null && buffers['ecg']!.isNotEmpty) {
                  await measApi.guardarMedicion('ecg', activeSessionId, buffers['ecg']!);
                }
                if (buffers['bpm'] != null && buffers['bpm']!.isNotEmpty) {
                  await measApi.guardarMedicion('bpm', activeSessionId, buffers['bpm']!);
                }
                // if (buffers['spo2'] != null && buffers['spo2']!.isNotEmpty) {
                //   await measApi.guardarMedicion('spo2', activeSessionId, buffers['spo2']!);
                // }
                if (buffers['air'] != null && buffers['air']!.isNotEmpty) {
                  await measApi.guardarMedicion('air', activeSessionId, buffers['air']!);
                }

                await sessionApi.finalizarSesion(activeSessionId, notes: notas);
              } catch (e) {
                debugPrint('Error al guardar datos en el backend: $e');
              }
            }

            final registro = RegistroMedicion(
              id: activeSessionId?.toString() ?? '${DateTime.now().millisecondsSinceEpoch}',
              usuarioId: usuarioActivo.id,
              fechaRegistro: DateTime.now(),
              duracionSegundos: _segundosGrabacion,
              frecuenciaCardiaca: fcProm,
              ppgFrecuenciaCardiaca: ppgProm,
              nivelSpo2: 0, // spo2Prom comentado
              nivelCo2: co2Prom,
              alertasDisparadas: _alertasDisparadas,
              notasClinicas: notas,
            );

            await ref
                .read(notificadorHistorialProvider.notifier)
                .guardarRegistro(registro);

            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sesión de medición guardada con éxito'),
                  backgroundColor: ColoresSensores.statusConectado,
                ),
              );
            }
            setState(() => _grabando = false);
          },
        );
      },
    );
  }

  String _formatearTiempo(int segs) {
    final minutos = segs ~/ 60;
    final segundos = segs % 60;
    return '${minutos.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final esOscuro = theme.brightness == Brightness.dark;
    final usuarioActivo = ref.watch(notificadorUsuariosProvider).usuarioActivo;
    final estadoConexion = ref.watch(notificadorConexionProvider);

    // Escuchamos reactivamente los cambios de conexión para inicializar el origen de datos adecuado
    ref.listen<EstadoConexionBackend>(notificadorConexionProvider, (
      prev,
      next,
    ) {
      if ((prev == null || prev.cargando) && !next.cargando) {
        final notifier = ref.read(notificadorSignosVitalesProvider.notifier);
        final ws = ref.read(notificadorConexionProvider.notifier).wsService;
        notifier.iniciarConWebSocket(ws.packetStream);
      }
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final esMobile = constraints.maxWidth < Breakpoints.tablet;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header componentizado
            DashboardHeader(
              esOscuro: esOscuro,
              tieneUsuarioActivo: usuarioActivo != null,
              grabando: _grabando,
              tiempoFormateado: _formatearTiempo(_segundosGrabacion),
              estadoConexion: estadoConexion,
              onStartRecording: _iniciarGrabacion,
              onStopRecording: _detenerYGuardar,
            ),
            const SizedBox(height: 24),

            // Grid adaptativo
            Expanded(
              child: SingleChildScrollView(
                child: esMobile
                    ? const Column(
                        children: [
                          KpiPanels(esMobile: true),
                          SizedBox(height: 24),
                          WaveCharts(),
                        ],
                      )
                    : const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          KpiPanels(esMobile: false),
                          SizedBox(height: 24),
                          WaveCharts(),
                        ],
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
