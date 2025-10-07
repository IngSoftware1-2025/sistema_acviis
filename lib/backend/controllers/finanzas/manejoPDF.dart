import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';



Future<void> descargarYAbrirPdf(BuildContext context, String fotografiaId) async {
  final url = 'http://localhost:3000/finanzas/download-pdf/$fotografiaId';
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final downloadsDir = Directory('${Platform.environment['USERPROFILE']}\\Downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${downloadsDir.path}/factura_${fotografiaId}_$timestamp.pdf';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF guardado en Descargas. Abriendo...')),
      );
      await OpenFile.open(filePath);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo descargar el PDF')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al descargar el PDF: $e')),
    );
  }
}
  
Future<void> descargarFichaPDF(BuildContext context, String facturaId, String codigo) async {
  try {
    final url = Uri.parse('http://localhost:3000/pagos/$facturaId/pdf');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final downloadsDir = Directory('${Platform.environment['USERPROFILE']}\\Downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
      final file = File('${downloadsDir.path}/factura_$codigo.pdf');
      await file.writeAsBytes(response.bodyBytes);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ficha PDF guardado en Descargas. Abriendo...')),
      );
      await OpenFile.open(file.path);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo generar la ficha PDF')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}