import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> createAnexoSupabase(Map<String, String> data, String db) async{ // Data incluye el id de contrato
  final url = Uri.parse('http://localhost:3000/anexos/$db');
  final body = jsonEncode({
    'id_trabajador': data['id_trabajador'],
    'id_contrato': data['id_contrato'],
    'fecha_de_creacion': data['fecha_de_creacion'],
    'duracion': data['duracion'],
    'tipo': data['tipo'],
    'parametros': data['parametros'],
    'comentario': data['comentario']
  });
  final response = await http.post(
    url,
    headers: {'Content-type': 'application/json'},
    body: body,
  );

  if (response.statusCode == 200) {
    //debugPrint('Anexo cargado correctamente en $db: ${response.body}');
  } else {
    debugPrint('Error al crear anexo en $db: ${response.statusCode}');
    debugPrint('Respuesta del backend: ${response.body}');
    throw Exception('Error al crear anexo $db');
  }
}

// Por cambiar lol (plop)
Future<void> createAnexoMongo(Map<String, String> data, String db) async{ 
  final url = Uri.parse('http://localhost:3000/anexos/$db');
  final body = jsonEncode({
    'id_trabajador': data['id_trabajador'],
    'id_contrato': data['id_contrato'],
    'fecha_de_creacion': data['fecha_de_creacion'],
    'duracion': data['duracion'],
    'tipo': data['tipo'],
    'parametros': data['parametros'],
    'comentario': data['comentario']
  });
  final response = await http.post(
    url,
    headers: {'Content-type': 'application/json'},
    body: body,
  );

  if (response.statusCode == 200) {
    //debugPrint('Anexo cargado correctamente en $db: ${response.body}');
  } else {
    debugPrint('Error al crear anexo en $db: ${response.statusCode}');
    debugPrint('Respuesta del backend: ${response.body}');
    throw Exception('Error al crear anexo $db');
  }
}

