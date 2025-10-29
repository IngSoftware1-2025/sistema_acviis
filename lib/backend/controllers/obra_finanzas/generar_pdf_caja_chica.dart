import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:sistema_acviis/models/obra_finanza.dart';

/// Genera y descarga un PDF con la información de la caja chica
Future<void> generarPDFCajaChica({
  required ObraFinanza cajaChica,
  required String obraNombre,
  required String obraDireccion,
  String? responsableEmail,
}) async {
  final pdf = pw.Document();

  // Formatos
  final formatoMoneda = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
  final formatoFecha = DateFormat('dd/MM/yyyy');

  // Calcular valores
  final montoAsignado = cajaChica.montoTotalAsignado;
  final montoUtilizado = cajaChica.montoTotalUtilizado;
  final montoImpago = cajaChica.montoUtilizadoImpago;
  final montoResuelto = cajaChica.montoUtilizadoResuelto;
  final montoDisponible = cajaChica.montoDisponible;
  final porcentaje = cajaChica.porcentajeUtilizado;

  // Calcular problemas
  final utilizadoExcedeAsignado = montoUtilizado > montoAsignado;
  final excedenteUtilizado = utilizadoExcedeAsignado ? montoUtilizado - montoAsignado : 0;

  final pagadoExcedeUtilizado = montoResuelto > montoUtilizado;
  final pagadoExcedeAsignado = montoResuelto > montoAsignado;
  final excedentePagadoVsUtilizado = pagadoExcedeUtilizado ? montoResuelto - montoUtilizado : 0;
  final excedentePagadoVsAsignado = pagadoExcedeAsignado ? montoResuelto - montoAsignado : 0;

  final hayProblemaExcesoPago = pagadoExcedeUtilizado && pagadoExcedeAsignado;
  final hayProblemas = utilizadoExcedeAsignado || hayProblemaExcesoPago;

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) => [
        // Encabezado
        pw.Header(
          level: 0,
          child: pw.Text(
            'REPORTE DE CAJA CHICA',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
        ),
        pw.SizedBox(height: 20),

        // Información de la Obra
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Información de la Obra',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('Nombre: $obraNombre', style: const pw.TextStyle(fontSize: 10)),
              pw.Text('Dirección: $obraDireccion', style: const pw.TextStyle(fontSize: 10)),
              if (responsableEmail != null)
                pw.Text('Responsable: $responsableEmail',
                    style: const pw.TextStyle(fontSize: 10)),
            ],
          ),
        ),
        pw.SizedBox(height: 15),

        // Detalles de Caja Chica
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Detalles de Caja Chica',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('Propósito: ${cajaChica.proposito}', style: const pw.TextStyle(fontSize: 10)),
              pw.Text('Estado: ${cajaChica.estado.toUpperCase()}',
                  style: const pw.TextStyle(fontSize: 10)),
              pw.Text(
                  'Fecha de Asignación: ${formatoFecha.format(cajaChica.fechaAsignacion)}',
                  style: const pw.TextStyle(fontSize: 10)),
            ],
          ),
        ),
        pw.SizedBox(height: 15),

        // Advertencias
        if (hayProblemas)
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              color: PdfColors.red50,
              border: pw.Border.all(color: PdfColors.red300, width: 2),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Text('⚠ ',
                        style: pw.TextStyle(fontSize: 16, color: PdfColors.red700)),
                    pw.Text('PROBLEMAS DETECTADOS',
                        style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.red900)),
                  ],
                ),
                pw.SizedBox(height: 10),

                if (utilizadoExcedeAsignado) ...[
                  pw.Text('• Monto utilizado excede el monto asignado',
                      style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.orange900)),
                  pw.Text(
                      '  Excedente: ${formatoMoneda.format(excedenteUtilizado)}',
                      style: pw.TextStyle(fontSize: 9, color: PdfColors.orange800)),
                ],

                if (hayProblemaExcesoPago) ...[
                  pw.SizedBox(height: 10),
                  pw.Text('• Monto pagado excede el monto total utilizado',
                      style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.red900)),
                  pw.Text(
                      '  - Por monto asignado: ${formatoMoneda.format(excedentePagadoVsAsignado)}',
                      style: pw.TextStyle(fontSize: 9, color: PdfColors.red800)),
                  pw.Text(
                      '  - Por monto utilizado: ${formatoMoneda.format(excedentePagadoVsUtilizado)}',
                      style: pw.TextStyle(fontSize: 9, color: PdfColors.red800)),
                ],
              ],
            ),
          ),

        pw.SizedBox(height: 15),

        // Resumen Financiero
        pw.Text('Resumen Financiero',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),

        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400),
          children: [
            _buildTableRow('Monto Total Asignado', formatoMoneda.format(montoAsignado), bold: true),
            _buildTableRow('Monto Total Utilizado', formatoMoneda.format(montoUtilizado)),
            _buildTableRow('  • Sin Pagar', formatoMoneda.format(montoImpago), indent: true),
            _buildTableRow('  • Pagado/Resuelto', formatoMoneda.format(montoResuelto), indent: true),
            _buildTableRow(
              'Monto Disponible',
              formatoMoneda.format(montoDisponible),
              bold: true,
              color: montoDisponible >= 0 ? PdfColors.green : PdfColors.red,
            ),
          ],
        ),
        pw.SizedBox(height: 15),

        pw.Text(
          'Porcentaje de Utilización: ${porcentaje.toStringAsFixed(1)}%',
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
        ),

        pw.SizedBox(height: 8),
      ],
      footer: (context) => pw.Container(
        alignment: pw.Alignment.center,
        margin: const pw.EdgeInsets.only(top: 20),
        child: pw.Text(
          'Generado el ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
          style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
        ),
      ),
    ),
  );

  // Guardar y abrir el PDF
    final Uint8List pdfBytes = await pdf.save();

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename =
        'caja_chica_${cajaChica.proposito.replaceAll(' ', '_')}_$timestamp.pdf';

    // Carpeta temporal (no se pide confirmación al usuario)
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/$filename';

    // Guardar el PDF
    final file = File(filePath);
    await file.writeAsBytes(pdfBytes);

    // Abrir automáticamente el PDF con el visor predeterminado del sistema
    await OpenFile.open(filePath);
}

// Helpers
pw.TableRow _buildTableRow(String label, String value,
    {bool bold = false, bool indent = false, PdfColor? color}) {
  return pw.TableRow(
    children: [
      pw.Padding(
        padding: pw.EdgeInsets.all(indent ? 8.0 : 10.0),
        child: pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: indent ? 9 : 10,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: color,
          ),
        ),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.all(10.0),
        child: pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: color,
          ),
          textAlign: pw.TextAlign.right,
        ),
      ),
    ],
  );
}

PdfColor _getColorPorcentaje(double porcentaje) {
  if (porcentaje < 50) return PdfColors.green;
  if (porcentaje < 80) return PdfColors.orange;
  return PdfColors.red;
}
