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

Future<void> createContratoDescartada() async {
  Map<String, String> data = {
    'nombre': 'Test1',
    'fechaInicio': 'Test1',
    'cargo': 'Test1',
    'salario': 'Test1',
  };
  final response = await http.post(
    Uri.parse('http://localhost:3000/contratos/mongo'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(data),
  );
  if (response.statusCode == 201 || response.statusCode == 200) {
    print('Contrato creado correctamente');
  } else {
    print('Error al crear contrato: ${response.statusCode}');
    print('Respuesta del backend: ${response.body}');
    throw Exception('Error al crear contrato');
  }
}

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
