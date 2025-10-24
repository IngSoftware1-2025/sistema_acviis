import 'dart:convert';
import 'package:http/http.dart' as http;

/// Envía un Map con los campos del itemizado al endpoint POST /itemizados
Future<void> crearItemizadoMap(Map<String, dynamic> data) async {
  final url = Uri.parse('http://localhost:3000/itemizados');
  final body = Map<String, dynamic>.from(data);
  body.remove('id'); // eliminar id si viene
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(body),
  );
  if (response.statusCode != 201 && response.statusCode != 200) {
    throw Exception('Error al crear itemizado: ${response.body}');
  }
}