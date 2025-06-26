import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> createContratoMongo(Map<String, String> data, String id, String contratoId) async {
  final url = Uri.parse('http://localhost:3000/contratos/mongo');
  final response = await http.post(
    url,
    headers: {'Content-type': 'application/json'},
    body: jsonEncode({...data, 'id': id, 'id_contrato': contratoId}),
  );

  if (response.statusCode == 200){
    //debugPrint('Contrato cargado en mongoDB correctamente: ${response.body}');
  } else {
    debugPrint('Error al crear contrato en mongo: ${response.statusCode}');
    debugPrint('Respuesta del backend: ${response.body}');
    throw Exception('Error al crear contrato mongo');
  }
}

Future<String> createContratoSupabase(Map<String, String> data, String id) async {
  final url = Uri.parse('http://localhost:3000/contratos/supabase');
    final body = jsonEncode({
    'id_trabajadores': id,
    'plazo_de_contrato': data['plazo_de_contrato'] ?? '',
    'estado': data['estado'] ?? '',
    'fecha_de_contratacion': data['fecha_de_contratacion'] ?? '',
  });
  final response  = await http.post(
    url,
    headers: {'Content-type': 'application/json'},
    body: jsonEncode({'id_trabajadores': id, ...data}),
  );
  

  if (response.statusCode == 200){
    final responseData = jsonDecode(response.body);
    final contratoId = responseData['contrato']?['id']?.toString();
    return contratoId ?? '';
  } else {
    debugPrint('Error al crear contrato en supabase: ${response.statusCode}');
    debugPrint('Respuesta del backend: ${response.body}');
    throw Exception('Error al crear contrato supabase');
  }
}