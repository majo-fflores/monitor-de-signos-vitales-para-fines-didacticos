import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Estructura de datos para pasar al generador de PDF.
class ReporteDatos {
  final String nombrePaciente;
  final String edadPaciente;
  final String notasClinicas;
  final int frecuenciaCardiaca;
  final int nivelSpo2;
  final int nivelCo2;
  final int amplitudAcustica;
  final DateTime fechaReporte;

  ReporteDatos({
    required this.nombrePaciente,
    required this.edadPaciente,
    required this.notasClinicas,
    required this.frecuenciaCardiaca,
    required this.nivelSpo2,
    required this.nivelCo2,
    required this.amplitudAcustica,
    required this.fechaReporte,
  });
}

/// Helper encargado de maquetar el reporte PDF.
class ReportPdfHelper {
  /// Genera los bytes del PDF a partir de los datos provistos.
  static Future<Uint8List> generarPdf(ReporteDatos datos) async {
    final pdf = pw.Document();
    
    // Cargamos la fuente Inter desde Google Fonts para dar soporte nativo a Unicode (tildes, eñes, etc.)
    final fontBase = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interBold();
    final fontItalic = await PdfGoogleFonts.interItalic();
    
    final tfgTheme = pw.ThemeData.withFont(
      base: fontBase,
      bold: fontBold,
      italic: fontItalic,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        theme: tfgTheme,
        build: (pw.Context context) {
          final primaryColor = PdfColor.fromHex('#030213');
          final secondaryColor = PdfColor.fromHex('#717182');
          final borderGrey = PdfColor.fromHex('#ECECF0');
          final successGreen = PdfColor.fromHex('#10B981');
          final alertRed = PdfColor.fromHex('#D4183D');
          
          final isSpo2Critico = datos.nivelSpo2 < 95;
          final isFcCritica = datos.frecuenciaCardiaca < 50 || datos.frecuenciaCardiaca > 120;
          final isCo2Critico = datos.nivelCo2 > 800;

          final formatoFecha = '${datos.fechaReporte.day.toString().padLeft(2, '0')}/${datos.fechaReporte.month.toString().padLeft(2, '0')}/${datos.fechaReporte.year} ${datos.fechaReporte.hour.toString().padLeft(2, '0')}:${datos.fechaReporte.minute.toString().padLeft(2, '0')}';

          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // CABECERA DEL INFORME
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'DATAVITAL',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        pw.Text(
                          'Sistema de Monitoreo de Biosignales en Tiempo Real',
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: secondaryColor,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'INFORME CLÍNICO',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        pw.Text(
                          formatoFecha,
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),
                pw.Divider(thickness: 1, color: borderGrey),
                pw.SizedBox(height: 16),

                // DATOS DEL PACIENTE
                pw.Text(
                  'DATOS DEL PACIENTE',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Table(
                  border: pw.TableBorder.all(color: borderGrey, width: 1),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Nombre del Paciente', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(datos.nombrePaciente.isNotEmpty ? datos.nombrePaciente : 'No especificado', style: const pw.TextStyle(fontSize: 10)),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Edad / Fecha de Nacimiento', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(datos.edadPaciente.isNotEmpty ? '${datos.edadPaciente} años' : 'No especificado', style: const pw.TextStyle(fontSize: 10)),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 24),

                // SIGNOS VITALES REGISTRADOS
                pw.Text(
                  'SIGNOS VITALES REGISTRADOS',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Table(
                  border: pw.TableBorder.all(color: borderGrey, width: 1),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(2),
                    2: const pw.FlexColumnWidth(2),
                    3: const pw.FlexColumnWidth(3),
                  },
                  children: [
                    // Header de la Tabla
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: primaryColor),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Biosensor / Parámetro', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Valor', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Unidad', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Estado', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        ),
                      ],
                    ),
                    // Fila ECG
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('AD8232 (Frecuencia Cardíaca)', style: const pw.TextStyle(fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('${datos.frecuenciaCardiaca}', style: const pw.TextStyle(fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('LPM', style: const pw.TextStyle(fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            isFcCritica ? 'CRÍTICO / ALTA PRIORIDAD' : 'NORMAL',
                            style: pw.TextStyle(
                              color: isFcCritica ? alertRed : successGreen,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Fila SpO2
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey50),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('MAX30100 (Saturación SpO2)', style: const pw.TextStyle(fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('${datos.nivelSpo2}', style: const pw.TextStyle(fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('%', style: const pw.TextStyle(fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            isSpo2Critico ? 'HIPOXIA / CRÍTICO' : 'NORMAL',
                            style: pw.TextStyle(
                              color: isSpo2Critico ? alertRed : successGreen,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Fila CO2
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('MQ-135 (Dióxido de Carbono)', style: const pw.TextStyle(fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('${datos.nivelCo2}', style: const pw.TextStyle(fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('ppm', style: const pw.TextStyle(fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            isCo2Critico ? 'MALA VENTILACIÓN' : 'NORMAL',
                            style: pw.TextStyle(
                              color: isCo2Critico ? alertRed : successGreen,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Fila LM386 PCG
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey50),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('LM386 (Amplitud Acústica PCG)', style: const pw.TextStyle(fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('${datos.amplitudAcustica}', style: const pw.TextStyle(fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('%', style: const pw.TextStyle(fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('ESTABLE', style: pw.TextStyle(color: successGreen, fontWeight: pw.FontWeight.bold, fontSize: 9)),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 24),

                // NOTAS CLÍNICAS
                pw.Text(
                  'OBSERVACIONES Y NOTAS CLÍNICAS',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: borderGrey, width: 1),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Text(
                    datos.notasClinicas.isNotEmpty ? datos.notasClinicas : 'Sin observaciones adicionales registradas por el personal de enfermería/médico.',
                    style: pw.TextStyle(fontSize: 10, fontStyle: datos.notasClinicas.isEmpty ? pw.FontStyle.italic : pw.FontStyle.normal),
                  ),
                ),

                pw.Spacer(),

                // FIRMAS Y AVISO LEGAL
                pw.Divider(thickness: 1, color: borderGrey),
                pw.SizedBox(height: 16),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'DataVital Biosensing Systems',
                          style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          'Este es un documento didáctico autogenerado y no sustituye un diagnóstico clínico formal.',
                          style: pw.TextStyle(fontSize: 7, color: secondaryColor),
                        ),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Container(
                          width: 120,
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(top: pw.BorderSide(color: PdfColors.black, width: 1)),
                          ),
                          padding: const pw.EdgeInsets.only(top: 4),
                          child: pw.Center(
                            child: pw.Text(
                              'Firma del Profesional',
                              style: const pw.TextStyle(fontSize: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }
}
