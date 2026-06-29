import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/breakpoints.dart';
import '../../../core/models/measurement_record.dart';
import '../../../core/models/session_summary.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/connection_provider.dart';
import '../../../shared/providers/history_provider.dart';
import '../../../shared/providers/session_provider.dart';
import '../../../shared/providers/user_provider.dart';
import '../../../shared/providers/vital_signs_provider.dart';
import '../widgets/co2_chart.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/ecg_chart.dart';
import '../widgets/save_session_dialog.dart';
import '../widgets/vital_kpi_card.dart';

/// Vista principal de monitoreo en tiempo real.
/// Se suscribe de manera selectiva a los flujos del NotificadorSignosVitales.
class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  bool _isRecording = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  int? _sessionId;

  @override
  void initState() {
    super.initState();
    // Si la configuración ya terminó de cargar al entrar (ej: navegación posterior), inicializamos de inmediato.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final connectionConfig = ref.read(connectionNotifierProvider);
      if (!connectionConfig.isLoading) {
        final notifier = ref.read(vitalSignsNotifierProvider.notifier);
        final ws = ref.read(connectionNotifierProvider.notifier).wsService;
        notifier.startWithWebSocket(ws.packetStream);
      }
    });
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final activeUser = ref.read(usersNotifierProvider).activeUser;
    if (activeUser == null) return;

    try {
      final session = await ref
          .read(sessionApiServiceProvider)
          .createSession(int.parse(activeUser.id));
      _sessionId = session.id;
    } catch (e) {
      debugPrint('Error al crear sesión en backend: $e');
      _sessionId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    }

    ref.read(vitalSignsNotifierProvider.notifier).startBuffering();

    setState(() {
      _isRecording = true;
      _recordingSeconds = 0;
    });

    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingSeconds++;
      });
    });
  }

  Future<void> _stopAndSave() async {
    _recordingTimer?.cancel();
    _recordingTimer = null;

    setState(() => _isRecording = false);

    final activeUser = ref.read(usersNotifierProvider).activeUser;
    if (activeUser == null) return;

    // Mostrar un indicador de carga mientras se guardan los datos y se obtiene el resumen
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final activeSessionId = _sessionId;
    final buffers = ref
        .read(vitalSignsNotifierProvider.notifier)
        .stopBuffering();

    try {
      if (activeSessionId != null) {
        final sessionApi = ref.read(sessionApiServiceProvider);

        // Congelar el EndTime en el backend inmediatamente
        try {
          await sessionApi.endSession(activeSessionId);
        } catch (e) {
          debugPrint('Error al pre-finalizar sesión: $e');
        }

        final measApi = ref.read(measurementApiServiceProvider);

        // Guardar buffers en paralelo
        try {
          await Future.wait([
            if (buffers['ecg']?.isNotEmpty ?? false)
              measApi.saveMeasurement('ecg', activeSessionId, buffers['ecg']!),
            if (buffers['bpm']?.isNotEmpty ?? false)
              measApi.saveMeasurement('bpm', activeSessionId, buffers['bpm']!),
            if (buffers['air']?.isNotEmpty ?? false)
              measApi.saveMeasurement('air', activeSessionId, buffers['air']!),
          ]);
        } catch (e) {
          debugPrint('Error al guardar mediciones en backend: $e');
        }

        // Obtener el summary real del backend
        SessionSummary summary;
        try {
          summary = await sessionApi.getSessionSummary(activeSessionId);
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
              durationSeconds: _recordingSeconds,
              avgBpm: summary.avgBpm.round(),
              minBpm: summary.minBpm.round(),
              maxBpm: summary.maxBpm.round(),
              avgCo2: summary.avgAir.round(),
              minCo2: summary.minAir.round(),
              maxCo2: summary.maxAir.round(),
              alertCount: summary.alertCount,
              onCancel: () async {
                try {
                  await sessionApi.deleteSession(activeSessionId);
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

                  await sessionApi.endSession(activeSessionId, notes: notas);

                  // Construir el MeasurementRecord con datos reales
                  final record = MeasurementRecord(
                    id: activeSessionId.toString(),
                    userId: activeUser.id,
                    registeredAt: DateTime.now(),
                    durationSeconds: _recordingSeconds,
                    heartRate: summary.avgBpm.round(),
                    minHeartRate: summary.minBpm.round(),
                    maxHeartRate: summary.maxBpm.round(),
                    co2Level: summary.avgAir.round(),
                    minCo2: summary.minAir.round(),
                    maxCo2: summary.maxAir.round(),
                    alertsTriggered: summary.alertCount,
                    clinicalNotes: notas,
                  );
                  await ref
                      .read(historyNotifierProvider.notifier)
                      .saveRecord(record);

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
                        backgroundColor: SensorColors.statusConnected,
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
                  // _isRecording = false is handled at start
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

  String _formatTime(int segs) {
    final minutos = segs ~/ 60;
    final segundos = segs % 60;
    return '${minutos.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeUser = ref.watch(usersNotifierProvider).activeUser;
    final connectionState = ref.watch(connectionNotifierProvider);

    // Escuchamos reactivamente los cambios de conexión para inicializar el origen de datos adecuado
    ref.listen<BackendConnectionState>(connectionNotifierProvider, (
      prev,
      next,
    ) {
      if ((prev == null || prev.isLoading) && !next.isLoading) {
        final notifier = ref.read(vitalSignsNotifierProvider.notifier);
        final ws = ref.read(connectionNotifierProvider.notifier).wsService;
        notifier.startWithWebSocket(ws.packetStream);
      }
    });

    final frecuenciaCardiaca = ref.watch(
      vitalSignsNotifierProvider.select((s) => s.heartRate),
    );
    final nivelCo2 = ref.watch(
      vitalSignsNotifierProvider.select((s) => s.co2Level),
    );
    final isEcgActive = ref.watch(
      vitalSignsNotifierProvider.select((s) => s.isEcgActive),
    );
    final isCo2Active = ref.watch(
      vitalSignsNotifierProvider.select((s) => s.isCo2Active),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final esMobile = constraints.maxWidth < Breakpoints.tablet;

        final fcCard = VitalKpiCard(
          title: 'Frecuencia Cardíaca',
          value: !isEcgActive || frecuenciaCardiaca == 0
              ? '-'
              : '$frecuenciaCardiaca',
          unit: 'LPM',
          accentColor: SensorColors.ecgGreen,
        );

        final co2Card = VitalKpiCard(
          title: 'Dióxido de Carbono',
          value: !isCo2Active || nivelCo2 == 0 ? '-' : '$nivelCo2',
          unit: 'ppm',
          accentColor: SensorColors.co2Yellow,
        );

        Widget gridContent;

        if (esMobile) {
          // Móvil: apilado (stacked) y bien grande
          gridContent = Column(
            children: [
              SizedBox(height: 110, child: fcCard),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: const EcgChart(expand: true),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(height: 110, child: co2Card),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: const Co2Chart(expand: true),
                ),
              ),
            ],
          );
        } else {
          // Desktop/Tablet: 70% Gráfico, 30% KPI
          gridContent = Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 7,
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: const EcgChart(expand: true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(flex: 3, child: fcCard),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 7,
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: const Co2Chart(expand: true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(flex: 3, child: co2Card),
                  ],
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header componentizado
            DashboardHeader(
              isDark: isDark,
              hasActiveUser: activeUser != null,
              isRecording: _isRecording,
              formattedTime: _formatTime(_recordingSeconds),
              connectionState: connectionState,
              onStartRecording: _startRecording,
              onStopRecording: _stopAndSave,
            ),
            const SizedBox(height: 24),

            // Banner de Sensores Desconectados si ambos están inactivos
            if (!isEcgActive && !isCo2Active) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.redAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.redAccent,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dispositivo Desconectado',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Por favor, conecte el dispositivo por USB para iniciar la lectura de los sensores.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? DarkColors.mutedForeground
                                  : LightColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Grid adaptativo
            Expanded(
              child: SingleChildScrollView(
                child: SizedBox(
                  // Forzamos altura fija en desktop para que CrossAxisAlignment.stretch funcione en Row
                  height: esMobile ? null : 600,
                  child: gridContent,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
