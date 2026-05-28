import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/breakpoints.dart';
import '../../../core/models/registro_medicion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/historial_provider.dart';
import '../../../shared/providers/usuario_provider.dart';
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
  final _nombreController = TextEditingController();
  final _edadController = TextEditingController();
  final _notasController = TextEditingController();
  RegistroMedicion? _sesionSeleccionada;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final usuario = ref.read(notificadorUsuariosProvider).usuarioActivo;
      if (usuario != null) {
        _nombreController.text = usuario.nombre;
        _edadController.text = usuario.edad.toString();
        ref.read(notificadorHistorialProvider.notifier).cargarHistorial(usuario.id);
      }
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _edadController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  void _generarReporte() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_sesionSeleccionada == null) return;

      final datosReporte = ReporteDatos(
        nombrePaciente: _nombreController.text.trim(),
        edadPaciente: _edadController.text.trim(),
        notasClinicas: _notasController.text.trim(),
        frecuenciaCardiaca: _sesionSeleccionada!.frecuenciaCardiaca,
        ppgFrecuenciaCardiaca: _sesionSeleccionada!.ppgFrecuenciaCardiaca,
        nivelSpo2: _sesionSeleccionada!.nivelSpo2,
        nivelCo2: _sesionSeleccionada!.nivelCo2,
        fechaReporte: _sesionSeleccionada!.fechaRegistro,
      );

      // Navegamos a la previsualización del PDF pasando los datos por el parámetro extra
      context.push('/historial/preview-pdf', extra: datosReporte);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Escuchar el historial del usuario activo
    final estadoHistorial = ref.watch(notificadorHistorialProvider);
    final sesiones = estadoHistorial.registros;

    // Inicializar o ajustar la selección de sesión en cada reconstrucción de la lista
    if (sesiones.isNotEmpty) {
      if (_sesionSeleccionada == null || !sesiones.any((s) => s.id == _sesionSeleccionada!.id)) {
        _sesionSeleccionada = sesiones.first;
        _notasController.text = _sesionSeleccionada!.notasClinicas;
      }
    } else {
      _sesionSeleccionada = null;
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
                color: isDark ? ColoresOscuros.foreground : ColoresClaros.foreground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Genera, previsualiza y descarga informes biométricos basados en las sesiones del paciente.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? ColoresOscuros.mutedForeground : ColoresClaros.mutedForeground,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: esMobile
                    ? Column(
                        children: [
                          PatientReportForm(
                            formKey: _formKey,
                            nombreController: _nombreController,
                            edadController: _edadController,
                            notasController: _notasController,
                            sesiones: sesiones,
                            sesionSeleccionada: _sesionSeleccionada,
                            onSesionChanged: (nuevaSesion) {
                              setState(() {
                                _sesionSeleccionada = nuevaSesion;
                                if (nuevaSesion != null) {
                                  _notasController.text = nuevaSesion.notasClinicas;
                                }
                              });
                            },
                            onGenerarReporte: _generarReporte,
                          ),
                          const Gap(24),
                          const ReportExportDetails(),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: PatientReportForm(
                              formKey: _formKey,
                              nombreController: _nombreController,
                              edadController: _edadController,
                              notasController: _notasController,
                              sesiones: sesiones,
                              sesionSeleccionada: _sesionSeleccionada,
                              onSesionChanged: (nuevaSesion) {
                                setState(() {
                                  _sesionSeleccionada = nuevaSesion;
                                  if (nuevaSesion != null) {
                                    _notasController.text = nuevaSesion.notasClinicas;
                                  }
                                });
                              },
                              onGenerarReporte: _generarReporte,
                            ),
                          ),
                          const Gap(24),
                          const Expanded(
                            flex: 2,
                            child: ReportExportDetails(),
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
