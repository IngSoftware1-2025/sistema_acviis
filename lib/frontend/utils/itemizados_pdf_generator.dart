import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class ItemizadosPdfGenerator {
  static Future<void> generarYMostrar(
    BuildContext context, {
    required String obraId,
    required String obraNombre,
  }) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generando PDF del itemizado...')),
    );

    try {
      final url = Uri.parse('http://localhost:3000/itemizados/$obraId/pdf');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final directory = await getDownloadsDirectory();
        if (directory == null) {
          throw Exception('No se pudo acceder a la carpeta de Descargas.');
        }

        final safeName = obraNombre.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
        final filePath = '${directory.path}/itemizado_$safeName.pdf';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF guardado en: $filePath')),
        );

        await OpenFile.open(filePath);
      } else {
        throw Exception('Error del servidor (${response.statusCode})');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al generar PDF: $e')),
      );
    }
  }
}
