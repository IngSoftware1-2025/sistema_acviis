import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> createContratoMongo(Map<String, String> data, String id) async {
  final url = Uri.parse('http://localhost:3000/contratos/mongo');
  final response = await http.post(
    url,
    headers: {'Content-type': 'application/json'},
    body: jsonEncode({...data, 'id': id}),
  );

  if (response.statusCode == 200){
    debugPrint('Contrato cargado en mongoDB correctamente: ${response.body}');
  } else {
    debugPrint('Error al crear contrato en mongo: ${response.statusCode}');
    debugPrint('Respuesta del backend: ${response.body}');
    throw Exception('Error al crear contrato mongo');
  }
}

Future<void> createContratoSupabase(Map<String, String> data, String id) async {
  final url = Uri.parse('http://localhost:3000/contratos/supabase');
  final response  = await http.post(
    url,
    headers: {'Content-type': 'application/json'},
    body: jsonEncode({'id_trabajador': id, ...data}),
  );
  

  if (response.statusCode == 200){
    //debugPrint('Contrato cargado supabase correctamente: ${response.body}');
  } else {
    debugPrint('Error al crear contrato en supabase: ${response.statusCode}');
    debugPrint('Respuesta del backend: ${response.body}');
    throw Exception('Error al crear contrato supabase');
  }
}