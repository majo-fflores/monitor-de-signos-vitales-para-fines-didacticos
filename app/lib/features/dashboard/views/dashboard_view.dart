import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/breakpoints.dart';
import '../../../core/models/registro_medicion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/connection_provider.dart';
import '../../../shared/providers/historial_provider.dart';
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
  // Estado para la grabación de sesiones
  bool _grabando = false;
  bool _vistaCompacta = true;
  int _segundosGrabacion = 0;
  Timer? _timerGrabacion;
  final List<int> _frecuenciasGrabadas = [];
  final List<int> _ppgFrecuenciasGrabadas = [];
  final List<int> _spo2Grabados = [];
  final List<int> _co2Grabados = [];
  int _alertasDisparadas = 0;

  @override
  void initState() {
    super.initState();
    // Si la configuración ya terminó de cargar al entrar (ej: navegación posterior), inicializamos de inmediato.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final configConexion = ref.read(notificadorConexionProvider);
      if (!configConexion.cargando) {
        final notifier = ref.read(notificadorSignosVitalesProvider.notifier);
        if (configConexion.modo == ModoFuente.websocket) {
          final ws = ref.read(notificadorConexionProvider.notifier).wsService;
          notifier.iniciarConWebSocket(ws.packetStream);
        } else {
          notifier.iniciarSimulacion();
        }
      }
    });
  }

  @override
  void dispose() {
    _timerGrabacion?.cancel();
    super.dispose();
  }

  void _iniciarGrabacion() {
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
      if (signos.frecuenciaCardiaca < 60 || signos.frecuenciaCardiaca > 100 ||
          signos.nivelSpo2 < 95 ||
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
        : (_frecuenciasGrabadas.reduce((a, b) => a + b) ~/ _frecuenciasGrabadas.length);
    final ppgProm = _ppgFrecuenciasGrabadas.isEmpty
        ? 72
        : (_ppgFrecuenciasGrabadas.reduce((a, b) => a + b) ~/ _ppgFrecuenciasGrabadas.length);
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
            final registro = RegistroMedicion.crear(
              usuarioId: usuarioActivo.id,
              duracionSegundos: _segundosGrabacion,
              frecuenciaCardiaca: fcProm,
              ppgFrecuenciaCardiaca: ppgProm,
              nivelSpo2: spo2Prom,
              nivelCo2: co2Prom,
              alertasDisparadas: _alertasDisparadas,
              notasClinicas: notas,
            );

            await ref.read(notificadorHistorialProvider.notifier).guardarRegistro(registro);
            
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
    ref.listen<EstadoConexionBackend>(notificadorConexionProvider, (prev, next) {
      if ((prev == null || prev.cargando) && !next.cargando) {
        // Al terminar de cargar la configuración inicial de persistencia
        final notifier = ref.read(notificadorSignosVitalesProvider.notifier);
        if (next.modo == ModoFuente.websocket) {
          final ws = ref.read(notificadorConexionProvider.notifier).wsService;
          notifier.iniciarConWebSocket(ws.packetStream);
        } else {
          notifier.iniciarSimulacion();
        }
      } else if (prev != null && prev.modo != next.modo) {
        // Al cambiar de modo manualmente
        final notifier = ref.read(notificadorSignosVitalesProvider.notifier);
        if (next.modo == ModoFuente.websocket) {
          final ws = ref.read(notificadorConexionProvider.notifier).wsService;
          notifier.iniciarConWebSocket(ws.packetStream);
        } else {
          notifier.iniciarSimulacion();
        }
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
              vistaCompacta: _vistaCompacta,
              tiempoFormateado: _formatearTiempo(_segundosGrabacion),
              estadoConexion: estadoConexion,
              onToggleVista: () {
                setState(() {
                  _vistaCompacta = !_vistaCompacta;
                });
              },
              onStartRecording: _iniciarGrabacion,
              onStopRecording: _detenerYGuardar,
            ),
            const SizedBox(height: 24),

            // Grid adaptativo
            Expanded(
              child: SingleChildScrollView(
                child: esMobile
                    ? Column(
                        children: [
                          const KpiPanels(esMobile: true),
                          const SizedBox(height: 24),
                          WaveCharts(esCompacto: _vistaCompacta),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: WaveCharts(esCompacto: _vistaCompacta),
                          ),
                          const SizedBox(width: 24),
                          const Expanded(
                            flex: 1,
                            child: KpiPanels(esMobile: false),
                          ),
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
