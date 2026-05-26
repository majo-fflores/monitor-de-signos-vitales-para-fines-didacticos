import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/breakpoints.dart';
import '../../../core/models/registro_medicion.dart';
import '../../../shared/providers/vital_signs_provider.dart';
import '../../../shared/providers/usuario_provider.dart';
import '../../../shared/providers/historial_provider.dart';
import '../widgets/kpi_panels.dart';
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
  int _segundosGrabacion = 0;
  Timer? _timerGrabacion;
  final List<int> _frecuenciasGrabadas = [];
  final List<int> _spo2Grabados = [];
  final List<int> _co2Grabados = [];
  final List<int> _amplitudesGrabadas = [];
  int _alertasDisparadas = 0;

  @override
  void initState() {
    super.initState();
    // Ejecutamos la simulación al montar el componente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificadorSignosVitalesProvider.notifier).iniciarSimulacion();
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
      _spo2Grabados.clear();
      _co2Grabados.clear();
      _amplitudesGrabadas.clear();
      _alertasDisparadas = 0;
    });

    _timerGrabacion = Timer.periodic(const Duration(seconds: 1), (timer) {
      final signos = ref.read(notificadorSignosVitalesProvider);
      
      _frecuenciasGrabadas.add(signos.frecuenciaCardiaca);
      _spo2Grabados.add(signos.nivelSpo2);
      _co2Grabados.add(signos.nivelCo2);
      _amplitudesGrabadas.add(signos.amplitudAcustica);

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
    final spo2Prom = _spo2Grabados.isEmpty
        ? 98
        : (_spo2Grabados.reduce((a, b) => a + b) ~/ _spo2Grabados.length);
    final co2Prom = _co2Grabados.isEmpty
        ? 400
        : (_co2Grabados.reduce((a, b) => a + b) ~/ _co2Grabados.length);
    final ampProm = _amplitudesGrabadas.isEmpty
        ? 15
        : (_amplitudesGrabadas.reduce((a, b) => a + b) ~/ _amplitudesGrabadas.length);

    final notasController = TextEditingController();

    // Mostrar diálogo premium para agregar notas clínicas antes de guardar
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(LucideIcons.save, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              const Text('Guardar Medición'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resumen de la sesión:',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Gap(8),
              Text('• Duración: $_segundosGrabacion segundos'),
              Text('• Prom. Cardíaco: $fcProm LPM'),
              Text('• Prom. SpO2: $spo2Prom%'),
              Text('• Prom. CO2: $co2Prom ppm'),
              const Gap(16),
              TextField(
                controller: notasController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Notas y Observaciones Clínicas',
                  hintText: 'Ej. Paciente estable durante la prueba...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => _grabando = false);
              },
              child: const Text('Descartar'),
            ),
            FilledButton(
              onPressed: () async {
                final registro = RegistroMedicion.crear(
                  usuarioId: usuarioActivo.id,
                  duracionSegundos: _segundosGrabacion,
                  frecuenciaCardiaca: fcProm,
                  nivelSpo2: spo2Prom,
                  nivelCo2: co2Prom,
                  amplitudAcustica: ampProm,
                  alertasDisparadas: _alertasDisparadas,
                  notasClinicas: notasController.text.trim(),
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
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: const Text('Guardar'),
            ),
          ],
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final esMobile = constraints.maxWidth < Breakpoints.tablet;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header de la sección
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dashboard de Bioseñales',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: esOscuro ? ColoresOscuros.foreground : ColoresClaros.foreground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Visualización en tiempo real de sensores.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: esOscuro ? ColoresOscuros.mutedForeground : ColoresClaros.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Botón de control de grabación
                if (usuarioActivo != null) ...[
                  _grabando
                      ? OutlinedButton.icon(
                          onPressed: _detenerYGuardar,
                          icon: const Icon(LucideIcons.square, size: 16, color: Colors.red),
                          label: Text(
                            'DETENER (${_formatearTiempo(_segundosGrabacion)})',
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                          ),
                        )
                      : FilledButton.icon(
                          onPressed: _iniciarGrabacion,
                          icon: const Icon(LucideIcons.play, size: 16),
                          label: const Text('GRABAR SESIÓN'),
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                          ),
                        ),
                ],
              ],
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
                    : const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: WaveCharts(),
                          ),
                          SizedBox(width: 24),
                          Expanded(
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
