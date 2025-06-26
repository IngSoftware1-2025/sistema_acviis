import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> actualizarEstadoTrabajador(String id, String nuevoEstado) async {
  final url = Uri.parse('http://localhost:3000/trabajadores/$id/estado');
  final response = await http.put(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'estado': nuevoEstado}),
  );
  if (response.statusCode != 200) {
    throw Exception('Error al actualizar estado: ${response.body}');
  }
}