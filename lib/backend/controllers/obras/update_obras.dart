import 'dart:convert';
import 'package:http/http.dart' as http;


Future<void> updateObras(Map<String, dynamic> obraData) async {
  final id = obraData['id'];
  final url = Uri.parse('http://localhost:3000/obras/$id');

  print('[updateObras] Enviando actualización para obra $id');
  print('[updateObras] Datos: $obraData');

  final response = await http.put(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'nombre': obraData['nombre'],
      'descripcion': obraData['descripcion'],
      'responsable_email': obraData['responsable_email'],
      'direccion': obraData['direccion'],
      'obraInicio': obraData['obraInicio'] != null
          ? DateTime.parse(obraData['obraInicio']).toUtc().toIso8601String()
          : null,
      'obraFin': obraData['obraFin'] != null
          ? DateTime.parse(obraData['obraFin']).toUtc().toIso8601String()
          : null,
      'jornada': obraData['jornada'],
    }),
  );

  print('[updateObras] Respuesta del servidor: ${response.statusCode}');
  print('[updateObras] Body de la respuesta: ${response.body}');

  if (response.statusCode != 200) {
    final errorData = jsonDecode(response.body);
    throw Exception('Error al actualizar obra: ${errorData['error'] ?? response.body}');
  }
}