import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';

Future<void> createContratoTest() async {
  final url = Uri.parse('http://localhost:3000/contratos/mongo');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: '''
      {
      "nombre": "Juan",
      "apellido": "Pérez",
      "rut": "12.345.678-9",
      "descripcion": "Contrato de prueba",
      "terminos": "Acepto los términos y condiciones"
      }
    ''',
  );

  if (response.statusCode == 200) {
    //print('Conexión a MongoDB exitosa: ${response.body}');
    print('Documento cargado exitosiamente: ${response.body}');
  } else {
    print('Error al subir documento: ${response.body}');
  }
}

Future<void> getContratoNombre() async {
  final String nombre = 'Juan_Pérez_contrato.pdf';
  final url = Uri.http('localhost:3000', '/contratos/mongo/por-nombre', {'filename': nombre});
  final response = await http.get(
    url,
    headers: {'Content-Type': 'application/json'},
  );
  if (response.statusCode == 200) {
    print('Contrato obtenido exitosamente: ${response.body}');
  } else {
    print('Error al obtener contrato: ${response.body}');
  }
}

Future<void> showContrato(BuildContext context, String nombreArchivo) async {
  final url = Uri.http('localhost:3000', '/contratos/mongo/por-nombre', {'filename': nombreArchivo});
  final response = await http.get(url);

  if (response.statusCode == 200) {
    // Guarda los bytes en un archivo temporal
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$nombreArchivo');
    await file.writeAsBytes(response.bodyBytes);

    await OpenFile.open(file.path); // Esto abre el PDF con el visor de Windows
  } else {
    debugPrint('Error al obtener contrato: ${response.body}');
  }
}