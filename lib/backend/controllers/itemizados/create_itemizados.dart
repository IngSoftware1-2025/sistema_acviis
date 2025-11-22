import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

Future<Map<String, dynamic>> createItemizado({
  required String nombre,
  String? descripcion,
  required int cantidad,
  required int montoTotal,
  required String obraId,
}) async {
  try {
    final url = Uri.parse('http://localhost:3000/itemizados');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nombre': nombre,
        'descripcion': descripcion,
        'cantidad': cantidad,
        'monto_total': montoTotal,
        'obraId': obraId,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);
      return {'success': true, 'data': decodedResponse};
    } else {
      if (kDebugMode) {
        print('Error al crear itemizado: ${response.body}');
      }
      return {'success': false, 'error': response.body};
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error en createItemizado: $e');
    }
    return {'success': false, 'error': e.toString()};
  }
}
