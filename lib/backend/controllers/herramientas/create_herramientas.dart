import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> createHerramienta({
  required String tipo,
  DateTime? garantia,
  required int cantidadTotal,
}) async {
  final url = Uri.parse('http://localhost:3000/herramientas');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'tipo': tipo,
      'garantia': garantia?.toIso8601String(),
      'cantidad_total': cantidadTotal,
    }),
  );

  if (response.statusCode == 201) {
    final data = jsonDecode(response.body);
    return data['id'];
  } else {
    throw Exception('Error al crear herramienta: ${response.body}');
  }
}