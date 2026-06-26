import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/breakpoints.dart';
import '../../../core/models/measurement_record.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/history_provider.dart';
import '../../../shared/providers/session_provider.dart';
import '../../../shared/providers/user_provider.dart';
import '../../../shared/utils/report_pdf_helper.dart';
import '../widgets/patient_report_form.dart';
import '../widgets/report_export_details.dart';

/// Vista de Historial Biométrico con formulario de paciente y generador de reporte.
class HistoryView extends ConsumerStatefulWidget {
  const HistoryView({super.key});

  @override
  ConsumerState<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends ConsumerState<HistoryView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  MeasurementRecord? _selectedSession;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final user = ref.read(usersNotifierProvider).activeUser;
      if (user != null) {
        _nameController.text = user.name;
        ref.read(historyNotifierProvider.notifier).loadHistory(user.id);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _generateReport() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedSession == null) return;

      final user = ref.read(usersNotifierProvider).activeUser;
      final dniStr = user?.dni?.toString() ?? 'No especificado';

      final reportData = ReportData(
        patientName: _nameController.text.trim(),
        patientDni: dniStr,
        formattedDuration: _selectedSession!.formattedDuration,
        clinicalNotes: _notesController.text.trim(),
        heartRate: _selectedSession!.heartRate,
        minHeartRate: _selectedSession!.minHeartRate,
        maxHeartRate: _selectedSession!.maxHeartRate,
        co2Level: _selectedSession!.co2Level,
        minCo2: _selectedSession!.minCo2,
        maxCo2: _selectedSession!.maxCo2,
        reportDate: _selectedSession!.registeredAt,
      );

      // Navegamos a la previsualización del PDF pasando los datos por el parámetro extra
      context.push('/history/preview-pdf', extra: reportData);
    }
  }

  Future<void> _exportCsv() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedSession == null) return;

      final sessionId = int.tryParse(_selectedSession!.id);
      if (sessionId == null) return;

      try {
        final path = await ref
            .read(sessionApiServiceProvider)
            .exportSessionCsv(sessionId);
        if (path == null) return; // Se canceló la selección de archivo
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'CSV exportado: $path',
              style: const TextStyle(color: Colors.white),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al exportar CSV: $e',
              style: const TextStyle(color: Colors.white),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Escuchar el historial del usuario activo
    final historyState = ref.watch(historyNotifierProvider);
    final sessions = historyState.records;

    // Inicializar o ajustar la selección de sesión en cada reconstrucción de la lista
    if (sessions.isNotEmpty) {
      if (_selectedSession == null ||
          !sessions.any((s) => s.id == _selectedSession!.id)) {
        _selectedSession = sessions.first;
        _notesController.text = _selectedSession!.clinicalNotes;
      }
    } else {
      _selectedSession = null;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final esMobile = constraints.maxWidth < Breakpoints.tablet;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reportes Clínicos',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: isDark ? DarkColors.foreground : LightColors.foreground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Genera, previsualiza y descarga informes biométricos basados en las sesiones del paciente.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? DarkColors.mutedForeground
                    : LightColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: esMobile
                    ? Column(
                        children: [
                          // En mobile, detalles primero como contexto
                          const ReportExportDetails(esMobile: true),
                          const Gap(16),
                          PatientReportForm(
                            formKey: _formKey,
                            nameController: _nameController,
                            notesController: _notesController,
                            sessions: sessions,
                            selectedSession: _selectedSession,
                            onSessionChanged: (newSession) {
                              setState(() {
                                _selectedSession = newSession;
                                if (newSession != null) {
                                  _notesController.text =
                                      newSession.clinicalNotes;
                                }
                              });
                            },
                            onGenerateReport: _generateReport,
                            onExportCsv: _exportCsv,
                          ),
                        ],
                      )
                    : IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 3,
                              child: PatientReportForm(
                                formKey: _formKey,
                                nameController: _nameController,
                                notesController: _notesController,
                                sessions: sessions,
                                selectedSession: _selectedSession,
                                onSessionChanged: (newSession) {
                                  setState(() {
                                    _selectedSession = newSession;
                                    if (newSession != null) {
                                      _notesController.text =
                                          newSession.clinicalNotes;
                                    }
                                  });
                                },
                                onGenerateReport: _generateReport,
                                onExportCsv: _exportCsv,
                              ),
                            ),
                            const Gap(24),
                            const Expanded(
                              flex: 2,
                              child: ReportExportDetails(esMobile: false),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
