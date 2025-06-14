import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';

Future<void> descargarAnexoPDF(BuildContext context, String idAnexo) async {
  print('[DEBUG] Iniciando descarga de PDF para idAnexo: $idAnexo');
  try {
    final url = Uri.parse('http://localhost:3000/anexos/mongo/descargar-pdf/$idAnexo');
    print('[DEBUG] URL de descarga: ' + url.toString());
    final response = await http.get(url);
    print('[DEBUG] Código de respuesta: ${response.statusCode}');
    if (response.statusCode == 200) {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/anexo_$idAnexo.pdf');
      await file.writeAsBytes(response.bodyBytes);
      print('[DEBUG] PDF guardado en: ${file.path}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF descargado. Abriendo...')),
      );
      final result = await OpenFile.open(file.path);
      print('[DEBUG] Resultado de OpenFile.open: ${result.message}');
    } else {
      print('[DEBUG] No se pudo descargar el PDF. Status: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo descargar el PDF del anexo.')),
      );
    }
  } catch (e) {
    print('[DEBUG] Error al descargar o abrir PDF: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al descargar PDF: $e')),
    );
  }
}
