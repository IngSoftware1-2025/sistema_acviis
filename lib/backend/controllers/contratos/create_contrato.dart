import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> createContrato(Map<String, String> data, String id) async {
  final url = Uri.parse('http://localhost:3000/contratos/mongo');
  final response = await http.post(
    url,
    headers: {'Content-type': 'application/json'},
    body: jsonEncode({...data, 'id': id}),
  );

  if (response.statusCode == 200){
    debugPrint('Contrato cargado en la base de datos correctamente: ${response.body}');
  } else {
    debugPrint('Error al crear contrato: ${response.statusCode}');
    debugPrint('Respuesta del backend: ${response.body}');
    throw Exception('Error al crear contrato');
  }
}
