import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:sistema_acviis/models/epp.dart';
import 'package:printing/printing.dart';

class EppPdfGenerator {
  static Future<void> generarReporteEpp(EPP epp) async {
    try {
      // Crear el documento PDF
      final pdf = pw.Document();
      
      // Agregar página con el contenido
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                pw.SizedBox(height: 20),
                
                // Título del reporte
                _buildTitle(epp),
                pw.SizedBox(height: 30),
                
                // Información general
                _buildInfoGeneral(epp),
                pw.SizedBox(height: 20),
                
                // Obras asignadas
                _buildObrasAsignadas(epp),
                pw.SizedBox(height: 20),
                
                // Certificación
                _buildCertificacion(epp),
                pw.SizedBox(height: 30),
                
                // Footer
                _buildFooter(),
              ],
            );
          },
        ),
      );
      
      // Guardar y descargar el PDF
      await _guardarYDescargarPdf(pdf, epp);
      
    } catch (e) {
      throw Exception('Error al generar PDF: $e');
    }
  }
  
  static pw.Widget _buildHeader() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'SISTEMA ACVIIS',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Gestión de Equipos de Protección Personal',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              'EPP',
              style: pw.TextStyle(
                color: PdfColors.blue,
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  static pw.Widget _buildTitle(EPP epp) {
    return pw.Container(
      width: double.infinity,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'REPORTE DE EQUIPO DE PROTECCIÓN PERSONAL',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            epp.tipo.toUpperCase(),
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'ID: ${epp.id} | Generado: ${DateTime.now().toLocal().toString().split(' ')[0]}',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }
  
  static pw.Widget _buildInfoGeneral(EPP epp) {
    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header de sección
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(8),
                topRight: pw.Radius.circular(8),
              ),
            ),
            child: pw.Text(
              'INFORMACIÓN GENERAL',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
          ),
          // Contenido
          pw.Padding(
            padding: const pw.EdgeInsets.all(16),
            child: pw.Column(
              children: [
                _buildInfoRow('ID:', epp.id?.toString() ?? 'Sin ID'),
                _buildInfoRow('Tipo:', epp.tipo),
                _buildInfoRow('Cantidad:', '${epp.cantidad} unidades'),
                _buildInfoRow(
                  'Fecha de Registro:', 
                  epp.fechaRegistro?.toLocal().toString().split(' ')[0] ?? 'No especificada'
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  static pw.Widget _buildObrasAsignadas(EPP epp) {
    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header de sección
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.orange50,
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(8),
                topRight: pw.Radius.circular(8),
              ),
            ),
            child: pw.Text(
              'ASIGNACIÓN DE OBRAS',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.orange800,
              ),
            ),
          ),
          // Contenido
          pw.Padding(
            padding: const pw.EdgeInsets.all(16),
            child: epp.obrasAsignadas.isNotEmpty
                ? pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Obras donde se utiliza este EPP:',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      ...epp.obrasAsignadas.map((obra) => pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 2),
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('• ', style: pw.TextStyle(fontSize: 12)),
                            pw.Expanded(
                              child: pw.Text(
                                obra,
                                style: pw.TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    ],
                  )
                : pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.orange100,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Row(
                      children: [
                        pw.Text('⚠️ ', style: pw.TextStyle(fontSize: 14)),
                        pw.Text(
                          'Sin obras asignadas - EPP disponible para cualquier obra',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.orange800,
                            fontStyle: pw.FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
  
  static pw.Widget _buildCertificacion(EPP epp) {
    final tieneCertificado = epp.certificadoId != null && epp.certificadoId!.isNotEmpty;
    
    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header de sección
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: tieneCertificado ? PdfColors.green50 : PdfColors.red50,
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(8),
                topRight: pw.Radius.circular(8),
              ),
            ),
            child: pw.Text(
              'CERTIFICACIÓN',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: tieneCertificado ? PdfColors.green800 : PdfColors.red800,
              ),
            ),
          ),
          // Contenido
          pw.Padding(
            padding: const pw.EdgeInsets.all(16),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Text(
                      tieneCertificado ? '✅ ' : '❌ ',
                      style: pw.TextStyle(fontSize: 16),
                    ),
                    pw.Text(
                      'Estado de Certificado: ',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      tieneCertificado ? 'Certificado disponible' : 'Sin certificado',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: tieneCertificado ? PdfColors.green700 : PdfColors.red700,
                      ),
                    ),
                  ],
                ),
                if (tieneCertificado) ...[
                  pw.SizedBox(height: 8),
                  _buildInfoRow('ID de Certificado:', epp.certificadoId!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 12,
                color: PdfColors.grey800,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  static pw.Widget _buildFooter() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'Este reporte fue generado automáticamente por el Sistema ACVIIS',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Fecha y hora de generación: ${DateTime.now().toString()}',
            style: pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey500,
            ),
          ),
        ],
      ),
    );
  }
  
  static Future<void> _guardarYDescargarPdf(pw.Document pdf, EPP epp) async {
    try {
      // Generar bytes del PDF
      final Uint8List pdfBytes = await pdf.save();
      
      // Obtener directorio de descargas
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'EPP_${epp.tipo.replaceAll(' ', '_')}_${epp.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');
      
      // Escribir archivo
      await file.writeAsBytes(pdfBytes);
      
      // Usar printing para abrir/compartir el PDF
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: fileName,
      );
      
    } catch (e) {
      throw Exception('Error al guardar PDF: $e');
    }
  }
}
