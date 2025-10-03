import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

Future<void> descargarCertificadoEpp(BuildContext context, String certificadoId) async {
  final url = 'http://localhost:3000/api/epp/download-certificado/$certificadoId';
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final downloadsDir = Directory('${Platform.environment['USERPROFILE']}\\Downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${downloadsDir.path}/certificado_epp_${certificadoId}_$timestamp.pdf';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Certificado guardado en Descargas. Abriendo...')),
        );
      }
      await OpenFile.open(filePath);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo descargar el certificado')),
        );
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al descargar el certificado: $e')),
      );
    }
  }
}