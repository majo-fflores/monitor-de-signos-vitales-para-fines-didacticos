import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/utils/report_pdf_helper.dart';

/// Vista para previsualizar, imprimir y guardar el reporte en PDF.
/// Utiliza el widget `PdfPreview` de la librería `printing`.
class PdfPreviewView extends StatelessWidget {
  final ReporteDatos datos;

  const PdfPreviewView({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final esOscuro = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Previsualizar Reporte',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: esOscuro
                ? ColoresOscuros.foreground
                : ColoresClaros.foreground,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: IconThemeData(
          color: esOscuro
              ? ColoresOscuros.foreground
              : ColoresClaros.foreground,
        ),
      ),
      body: PdfPreview(
        build: (format) => ReportPdfHelper.generarPdf(datos),
        allowPrinting: true,
        allowSharing: true,
        canChangePageFormat: false,
        canChangeOrientation: false,
        pdfFileName:
            'reporte_datavital_${datos.nombrePaciente.replaceAll(' ', '_')}.pdf',
        // Estilización de PdfPreview para acoplarse al Dark/Light Mode
        loadingWidget: const Center(child: CircularProgressIndicator()),
        previewPageMargin: const EdgeInsets.all(16),
      ),
    );
  }
}
