import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> actualizarTrabajador(String id, Map<String, dynamic> data) async {
  final url = Uri.parse('http://localhost:3000/trabajadores/$id/datos');
  final response = await http.put(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(data),
  );
  if (response.statusCode != 200) {
    throw Exception('Error al actualizar trabajador: ${response.body}');
  }
}