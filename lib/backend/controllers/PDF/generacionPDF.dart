import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

Future<void> descargarFichaPDFGenerico(
  BuildContext context,
  String recurso, // "trabajadores", "herramientas", "vehiculos"
  String id,
  String nombreArchivo,
) async {
  try {
    final url = Uri.parse('http://localhost:3000/$recurso/$id/ficha-pdf');
    final response = await http.get(url);

    print('URL: $url');
    print('StatusCode: ${response.statusCode}');
    print('Body: ${response.body}'); // puede ser texto de error del backend

    if (response.statusCode == 200) {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/ficha_${recurso}_${nombreArchivo}.pdf');
      await file.writeAsBytes(response.bodyBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF descargado. Abriendo...')),
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