import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/breakpoints.dart';
import '../../../core/models/registro_medicion.dart';
import '../../../core/models/session_summary.dart';
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
      final session = await ref
          .read(sessionApiServiceProvider)
          .crearSesion(int.parse(usuarioActivo.id));
      _sessionId = session.id;
    } catch (e) {
      debugPrint('Error al crear sesión en backend: $e');
      _sessionId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    }

    ref.read(notificadorSignosVitalesProvider.notifier).startBuffering();

    setState(() {
      _grabando = true;
      _segundosGrabacion = 0;
    });

    _timerGrabacion = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _segundosGrabacion++;
      });
    });
  }

  Future<void> _detenerYGuardar() async {
    _timerGrabacion?.cancel();
    _timerGrabacion = null;

    setState(() => _grabando = false);

    final usuarioActivo = ref.read(notificadorUsuariosProvider).usuarioActivo;
    if (usuarioActivo == null) return;

    // Mostrar un indicador de carga mientras se guardan los datos y se obtiene el resumen
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final activeSessionId = _sessionId;
    final buffers = ref
        .read(notificadorSignosVitalesProvider.notifier)
        .stopBuffering();

    try {
      if (activeSessionId != null) {
        final sessionApi = ref.read(sessionApiServiceProvider);

        // Congelar el EndTime en el backend inmediatamente
        try {
          await sessionApi.finalizarSesion(activeSessionId);
        } catch (e) {
          debugPrint('Error al pre-finalizar sesión: $e');
        }

        final measApi = ref.read(measurementApiServiceProvider);

        // Guardar buffers en paralelo
        try {
          await Future.wait([
            if (buffers['ecg']?.isNotEmpty ?? false)
              measApi.guardarMedicion('ecg', activeSessionId, buffers['ecg']!),
            if (buffers['bpm']?.isNotEmpty ?? false)
              measApi.guardarMedicion('bpm', activeSessionId, buffers['bpm']!),
            if (buffers['air']?.isNotEmpty ?? false)
              measApi.guardarMedicion('air', activeSessionId, buffers['air']!),
          ]);
        } catch (e) {
          debugPrint('Error al guardar mediciones en backend: $e');
        }

        // Obtener el summary real del backend
        SessionSummary summary;
        try {
          summary = await sessionApi.obtenerResumenSesion(activeSessionId);
        } catch (e) {
          debugPrint(
            'Error al obtener resumen de sesión del backend: $e. Usando valores por defecto.',
          );
          summary = SessionSummary(
            sessionId: activeSessionId,
            notes: '',
            minBpm: 0.0,
            maxBpm: 0.0,
            avgBpm: 70.0,
            minEcg: 0.0,
            maxEcg: 0.0,
            avgEcg: 0.0,
            minSpo2: 0.0,
            maxSpo2: 0.0,
            avgSpo2: 0.0,
            minAir: 0.0,
            maxAir: 0.0,
            avgAir: 350.0,
            alertCount: 0,
          );
        }

        // Quitar el loading dialog
        if (mounted) Navigator.of(context, rootNavigator: true).pop();

        // Mostrar el SaveSessionDialog con los promedios reales del backend
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogCtx) {
            return SaveSessionDialog(
              segundosGrabacion: _segundosGrabacion,
              fcProm: summary.avgBpm.round(),
              fcMin: summary.minBpm.round(),
              fcMax: summary.maxBpm.round(),
              ppgProm: summary.avgBpm.round(),
              ppgMin: summary.minBpm.round(),
              ppgMax: summary.maxBpm.round(),
              co2Prom: summary.avgAir.round(),
              co2Min: summary.minAir.round(),
              co2Max: summary.maxAir.round(),
              alertCount: summary.alertCount,
              onCancel: () async {
                try {
                  await sessionApi.eliminarSesion(activeSessionId);
                } catch (e) {
                  debugPrint('Error al descartar sesión: $e');
                }
                if (dialogCtx.mounted) {
                  Navigator.of(dialogCtx, rootNavigator: true).pop();
                }
              },
              onSave: (notas) async {
                try {
                  // Mostrar loading breve al finalizar
                  showDialog(
                    context: dialogCtx,
                    barrierDismissible: false,
                    builder: (loadingCtx) =>
                        const Center(child: CircularProgressIndicator()),
                  );

                  await sessionApi.finalizarSesion(
                    activeSessionId,
                    notes: notas,
                  );

                  // Construir el RegistroMedicion con datos reales
                  final registro = RegistroMedicion(
                    id: activeSessionId.toString(),
                    usuarioId: usuarioActivo.id,
                    fechaRegistro: DateTime.now(),
                    duracionSegundos: _segundosGrabacion,
                    frecuenciaCardiaca: summary.avgBpm.round(),
                    minFrecuenciaCardiaca: summary.minBpm.round(),
                    maxFrecuenciaCardiaca: summary.maxBpm.round(),
                    ppgFrecuenciaCardiaca: summary.avgBpm.round(),
                    minPpgFrecuenciaCardiaca: summary.minBpm.round(),
                    maxPpgFrecuenciaCardiaca: summary.maxBpm.round(),
                    nivelSpo2: 0,
                    minSpo2: 0,
                    maxSpo2: 0,
                    nivelCo2: summary.avgAir.round(),
                    minCo2: summary.minAir.round(),
                    maxCo2: summary.maxAir.round(),
                    alertasDisparadas: summary.alertCount,
                    notasClinicas: notas,
                  );
                  await ref
                      .read(notificadorHistorialProvider.notifier)
                      .guardarRegistro(registro);

                  if (dialogCtx.mounted) {
                    Navigator.of(
                      dialogCtx,
                      rootNavigator: true,
                    ).pop(); // Quitar loading de finalizar
                    Navigator.of(
                      dialogCtx,
                      rootNavigator: true,
                    ).pop(); // Cerrar SaveSessionDialog
                  }
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Sesión de medición guardada con éxito',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: ColoresSensores.statusConectado,
                      ),
                    );
                  }
                } catch (e) {
                  debugPrint('Error al finalizar sesión: $e');
                  if (dialogCtx.mounted) {
                    Navigator.of(
                      dialogCtx,
                      rootNavigator: true,
                    ).pop(); // Quitar loading en error
                  }
                } finally {
                  // _grabando = false is handled at start
                }
              },
            );
          },
        );
      }
    } catch (e) {
      debugPrint('Error al guardar datos y obtener resumen: $e');
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Quitar loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al guardar datos de sesión: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
