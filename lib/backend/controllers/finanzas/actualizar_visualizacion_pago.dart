import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> actualizarVisualizacionFromAPI(String id, String visualizacion) async {
  final url = Uri.parse('http://localhost:3000/pagos/$id/visualizacion');
  final response = await http.put(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'visualizacion': visualizacion}),
  );
  if (response.statusCode != 200) {
throw Exception('Error al actualizar visualizacion: ${response.body}');
  }
}