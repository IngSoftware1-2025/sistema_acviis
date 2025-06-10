import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> actualizarEstadoTrabajador(String id, String nuevoEstado) async {
  final url = Uri.parse('http://localhost:3000/trabajadores/$id/estado');
  final response = await http.put(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'estado_trabajador': nuevoEstado}),
  );
  if (response.statusCode != 200) {
    throw Exception('Error al actualizar estado: ${response.body}');
  }
}