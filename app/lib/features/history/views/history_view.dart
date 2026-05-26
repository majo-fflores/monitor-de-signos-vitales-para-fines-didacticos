import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/breakpoints.dart';
import '../../../shared/utils/report_pdf_helper.dart';
import '../../../shared/providers/vital_signs_provider.dart';
import '../../../shared/providers/usuario_provider.dart';

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

  @override
  void initState() {
    super.initState();
    final usuario = ref.read(notificadorUsuariosProvider).usuarioActivo;
    if (usuario != null) {
      _nombreController.text = usuario.nombre;
      _edadController.text = usuario.edad.toString();
    }
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
      // Obtenemos los últimos valores en tiempo real del NotificadorSignosVitales
      final signos = ref.read(notificadorSignosVitalesProvider);

      final datosReporte = ReporteDatos(
        nombrePaciente: _nombreController.text.trim(),
        edadPaciente: _edadController.text.trim(),
        notasClinicas: _notasController.text.trim(),
        frecuenciaCardiaca: signos.frecuenciaCardiaca,
        nivelSpo2: signos.nivelSpo2,
        nivelCo2: signos.nivelCo2,
        amplitudAcustica: signos.amplitudAcustica,
        fechaReporte: DateTime.now(),
      );

      // Navegamos a la previsualización del PDF pasando los datos por el parámetro extra
      context.push('/historial/preview-pdf', extra: datosReporte);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget buildForm() {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? ColoresOscuros.border : ColoresClaros.border,
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Información de la Sesión',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(16),
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre Completo del Paciente',
                  hintText: 'Ej. Juan Pérez',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Por favor ingrese el nombre del paciente';
                  }
                  return null;
                },
              ),
              const Gap(16),
              TextFormField(
                controller: _edadController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Edad (Años)',
                  hintText: 'Ej. 45',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Por favor ingrese la edad';
                  }
                  if (int.tryParse(val.trim()) == null) {
                    return 'Por favor ingrese un número válido';
                  }
                  return null;
                },
              ),
              const Gap(16),
              TextFormField(
                controller: _notasController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Notas y Observaciones Clínicas',
                  hintText: 'Describa cualquier síntoma, anomalía o indicación del monitoreo...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const Gap(24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _generarReporte,
                  icon: const Icon(Icons.picture_as_pdf, size: 20),
                  label: const Text(
                    'GENERAR REPORTE EN PDF',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget buildInfo() {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.02) 
              : Colors.black.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? ColoresOscuros.border : ColoresClaros.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalles de Exportación',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(12),
            Text(
              'Al hacer clic en generar, el sistema recopilará automáticamente las lecturas instantáneas de los biosensores activos (ECG, SpO2 y CO2) y creará un archivo PDF formalizado.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? ColoresOscuros.mutedForeground : ColoresClaros.mutedForeground,
                height: 1.5,
              ),
            ),
            const Gap(16),
            const Divider(),
            const Gap(16),
            _buildInfoRow(Icons.check_circle_outline, 'Formato Médico A4/Letter'),
            const Gap(12),
            _buildInfoRow(Icons.print_outlined, 'Listo para Impresión Física'),
            const Gap(12),
            _buildInfoRow(Icons.lock_outline, 'Datos locales privados'),
          ],
        ),
      );
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
              'Genera, previsualiza y descarga informes biométricos del paciente en tiempo real.',
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
                          buildForm(),
                          const Gap(24),
                          buildInfo(),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: buildForm()),
                          const Gap(24),
                          Expanded(flex: 2, child: buildInfo()),
                        ],
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    final theme = Theme.of(context);
    final esOscuro = theme.brightness == Brightness.dark;
    return Row(
      children: [
        Icon(
          icon, 
          size: 16, 
          color: esOscuro ? ColoresOscuros.mutedForeground : ColoresClaros.mutedForeground,
        ),
        const Gap(8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
