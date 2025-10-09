import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> createAnexoSupabase(tipoAnexo, id_trabajador, id_contrato, parametros, comentario) async{
  final url = Uri.parse('http://localhost:3000/anexos/supabase');
  final body = jsonEncode({
    'tipo_anexo': tipoAnexo,
    'id_trabajador': id_trabajador,
    'id_contrato': id_contrato,
    'parametros': parametros,
    'comentario': comentario,
  });
  final response = await http.post(
    url,
    headers: {'Content-type': 'application/json'},
    body: body,
  );

  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    final anexoId = responseData['anexo']?['id']?.toString();
    return anexoId ?? ''; 
  } else {
    debugPrint('Error al crear anexo en supabase: ${response.statusCode}');
    debugPrint('Respuesta del backend: ${response.body}');
    
    throw Exception('Error al crear anexo supabase');
  }
}

Future<void> createAnexoMongo(data) async { 
  final url = Uri.parse('http://localhost:3000/anexos/mongo');
  final body = jsonEncode({
    // Datos del anexo
    'id_anexo': data['id_anexo'],
    'id_contrato': data['id_contrato'],
    'parametros': data['parametros'],
  });
  final response = await http.post(
    url,
    headers: {'Content-type': 'application/json'},
    body: body,
  );

  if (response.statusCode == 200) {
    // debugPrint('Anexo cargado correctamente en mongo: ${response.body}');
  } else {
    debugPrint('Error al crear anexo en mongo: ${response.statusCode}');
    debugPrint('Respuesta del backend: ${response.body}');
    throw Exception('Error al crear anexo mongo');
  }
}


Future<String> createAnexoSupabaseTemporal(Map<String, String> data) async{ // Data incluye el id de contrato
  final url = Uri.parse('http://localhost:3000/anexos/supabase');
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
    final responseData = jsonDecode(response.body);
    final anexoId = responseData['anexo']?['id']?.toString();
    return anexoId ?? '';
  } else {
    debugPrint('Error al crear anexo en supabase: ${response.statusCode}');
    debugPrint('Respuesta del backend: ${response.body}');
    
    throw Exception('Error al crear anexo supabase');
  }
}

// Por cambiar lol (plop)
Future<void> createAnexoMongoTemporal(Map<String, String> data) async { 
  final url = Uri.parse('http://localhost:3000/anexos/mongo');
  final body = jsonEncode({
    // Datos del trabajador
    'id': data['id'],
    'nombre_completo': data['nombre_completo'],
    'estado_civil': data['estado_civil'],
    'rut': data['rut'],
    'fecha_de_nacimiento': data['fecha_de_nacimiento'],
    'direccion': data['direccion'],
    'correo_electronico': data['correo_electronico'],
    'sistema_de_salud': data['sistema_de_salud'],
    'prevision_afp': data['prevision_afp'],
    'obra_en_la_que_trabaja': data['obra_en_la_que_trabaja'],
    'rol_que_asume_en_la_obra': data['rol_que_asume_en_la_obra'],
    'estado': data['estado'],
    // Datos del anexo
    'id_anexo': data['id_anexo'],
    'id_contrato': data['id_contrato'],
    'tipo': data['tipo'],
    'duracion': data['duracion'],
    'parametros': data['parametros'],
    'comentario': data['comentario'],
  });
  final response = await http.post(
    url,
    headers: {'Content-type': 'application/json'},
    body: body,
  );

  if (response.statusCode == 200) {
    // debugPrint('Anexo cargado correctamente en mongo: ${response.body}');
  } else {
    debugPrint('Error al crear anexo en mongo: ${response.statusCode}');
    debugPrint('Respuesta del backend: ${response.body}');
    throw Exception('Error al crear anexo mongo');
  }
}
