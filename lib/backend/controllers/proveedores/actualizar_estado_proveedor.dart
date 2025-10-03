import 'package:http/http.dart' as http;
import 'dart:convert';

Future<bool> actualizarEstadoProveedor(String id, String nuevoEstado) async {
  final url = Uri.parse('http://localhost:3000/proveedores/$id/estado');
  final response = await http.put(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'estado': nuevoEstado}),
  );
  return response.statusCode == 200;
}