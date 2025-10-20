import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class PdfUtils {
  static Future<void> generarYMostrarFichaProveedor(BuildContext context, String proveedorId, String proveedorRut) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generando ficha PDF...')),
    );

    try {
      // 1. Llamar al endpoint del backend que genera el PDF
      final url = Uri.parse('http://localhost:3000/proveedores/$proveedorId/pdf');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // 1. Obtener el directorio de descargas del dispositivo.
        // getDownloadsDirectory() es más robusto para esto.
        final directory = await getDownloadsDirectory();
        if (directory == null) {
          throw Exception('No se pudo encontrar el directorio de descargas.');
        }

        // 2. Crear la ruta completa del archivo.
        final filePath = '${directory.path}/ficha_proveedor_$proveedorRut.pdf';
        final file = File(filePath);

        // 3. Escribir los bytes del PDF en el archivo.
        await file.writeAsBytes(response.bodyBytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF guardado en Descargas: $filePath')),
        );

        // 4. Abrir el archivo con la aplicación predeterminada.
        await OpenFile.open(filePath);

      } else {
        throw Exception('Error del servidor al generar el PDF: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al generar PDF: $e')),
      );
    }
  }
}
