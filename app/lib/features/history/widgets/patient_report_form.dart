import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/models/measurement_record.dart';
import '../../../../core/theme/app_colors.dart';

class PatientReportForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController notesController;
  final List<MeasurementRecord> sessions;
  final MeasurementRecord? selectedSession;
  final ValueChanged<MeasurementRecord?> onSessionChanged;
  final VoidCallback onGenerateReport;
  final VoidCallback onExportCsv;

  const PatientReportForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.notesController,
    required this.sessions,
    required this.selectedSession,
    required this.onSessionChanged,
    required this.onGenerateReport,
    required this.onExportCsv,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (sessions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? DarkColors.border : LightColors.border,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.fileWarning,
              size: 48,
              color: theme.colorScheme.error.withValues(alpha: 0.8),
            ),
            const Gap(16),
            Text(
              'No hay sesiones registradas',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            Text(
              'Para generar un reporte clínico, primero debe registrar una sesión de monitoreo para el paciente actual desde el Dashboard.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? DarkColors.mutedForeground
                    : LightColors.mutedForeground,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.onSurface.withValues(
                          alpha: 0.05,
                        ),
                        foregroundColor: theme.colorScheme.onSurface.withValues(
                          alpha: 0.3,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: null,
                      icon: const Icon(Icons.picture_as_pdf, size: 20),
                      label: const Text(
                        'REPORTE PDF',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.onSurface.withValues(
                          alpha: 0.3,
                        ),
                        side: BorderSide(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.1,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: null,
                      icon: const Icon(LucideIcons.download, size: 20),
                      label: const Text(
                        'EXPORTAR CSV',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? DarkColors.border : LightColors.border,
        ),
      ),
      child: Form(
        key: formKey,
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
            // Dropdown de Sesiones
            DropdownButtonFormField<MeasurementRecord>(
              initialValue: selectedSession,
              decoration: InputDecoration(
                labelText: 'Seleccionar Sesión Médica',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: sessions.map((s) {
                return DropdownMenuItem<MeasurementRecord>(
                  value: s,
                  child: Text(
                    '${s.formattedDate} (${s.formattedDuration})',
                    style: theme.textTheme.bodyMedium,
                  ),
                );
              }).toList(),
              onChanged: onSessionChanged,
              validator: (val) {
                if (val == null) {
                  return 'Por favor seleccione una sesión';
                }
                return null;
              },
            ),
            const Gap(16),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nombre Completo del Paciente',
                hintText: 'Ej. Juan Pérez',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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
              controller: notesController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Notas y Observaciones Clínicas',
                hintText:
                    'Describa cualquier síntoma, anomalía o indicación del monitoreo...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const Gap(24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: onGenerateReport,
                      icon: const Icon(Icons.picture_as_pdf, size: 20),
                      label: const Text(
                        'REPORTE PDF',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        side: BorderSide(color: theme.colorScheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: onExportCsv,
                      icon: const Icon(LucideIcons.download, size: 20),
                      label: const Text(
                        'EXPORTAR CSV',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
