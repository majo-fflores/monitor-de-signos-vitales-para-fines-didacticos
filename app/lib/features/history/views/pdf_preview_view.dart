import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/utils/export_path_helper.dart';
import '../../../shared/utils/report_pdf_helper.dart';

/// Vista para previsualizar, imprimir y guardar el reporte en PDF.
/// Utiliza el widget `PdfPreview` de la librería `printing`.
class PdfPreviewView extends StatelessWidget {
  final ReportData data;

  const PdfPreviewView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Previsualizar Reporte',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? DarkColors.foreground : LightColors.foreground,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: IconThemeData(
          color: isDark ? DarkColors.foreground : LightColors.foreground,
        ),
      ),
      body: PdfPreview(
        build: (format) => ReportPdfHelper.generatePdf(data),
        allowPrinting: true,
        allowSharing: true,
        canChangePageFormat: false,
        canChangeOrientation: false,
        pdfFileName:
            'reporte_datavital_${data.patientName.replaceAll(' ', '_')}.pdf',
        actions: [
          PdfPreviewAction(
            icon: const Icon(Icons.download),
            onPressed: (context, build, pageFormat) async {
              try {
                final bytes = await build(pageFormat);
                final exportDir = ExportPathHelper.getExportDir('pdf');
                final fileName =
                    'reporte_datavital_${data.patientName.replaceAll(' ', '_')}.pdf';
                final file = File(
                  '${exportDir.path}${Platform.pathSeparator}$fileName',
                );
                await file.writeAsBytes(bytes);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('PDF guardado en: ${file.path}'),
                      backgroundColor: SensorColors.excellentLight,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al guardar PDF: $e'),
                      backgroundColor: SensorColors.criticalLight,
                    ),
                  );
                }
              }
            },
          ),
        ],
        // Estilización de PdfPreview para acoplarse al Dark/Light Mode
        loadingWidget: const Center(child: CircularProgressIndicator()),
        previewPageMargin: const EdgeInsets.all(16),
      ),
    );
  }
}
