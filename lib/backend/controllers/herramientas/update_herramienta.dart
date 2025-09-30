import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> updateHerramienta(Map<String, dynamic> herramientaData) async {
  final id = herramientaData['id'];
  final url = Uri.parse('http://localhost:3000/herramientas/$id/datos');

  final response = await http.put(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'tipo': herramientaData['tipo'],
      'garantia': herramientaData['garantia'],
      'cantidad': herramientaData['cantidad'],
      'obra_asig': herramientaData['obra_asig'],
      'asig_inicio': herramientaData['asig_inicio'],
      'asig_fin': herramientaData['asig_fin'],
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Error al actualizar herramienta: ${response.body}');
  }
}