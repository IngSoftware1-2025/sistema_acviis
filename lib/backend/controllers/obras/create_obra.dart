import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

Future<Map<String, dynamic>> createObra({
  required String nombre,
  String? descripcion,
  String? responsableEmail,
  required String direccion,
  DateTime? obraInicio,
  DateTime? obraFin,
  String? jornada,
}) async {
  try {
    final url = Uri.parse('http://localhost:3000/obras');
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nombre': nombre,
        'descripcion': descripcion,
        'responsable_email': responsableEmail,
        'direccion': direccion,
        'obraInicio': obraInicio?.toIso8601String(),
        'obraFin': obraFin?.toIso8601String(),
        'jornada': jornada,
      }),
    );
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);
      return {'success': true, 'data': decodedResponse};
    } else {
      if (kDebugMode) {
        print('Error al crear la obra: ${response.body}');
      }
      return {'success': false, 'error': response.body};
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error en createObra: $e');
    }
    return {'success': false, 'error': e.toString()};
  }
}