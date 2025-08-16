import 'package:http/http.dart' as http;
import 'dart:convert';

Future<bool> updateProveedor(String id, Map<String, dynamic> data) async {
  final url = Uri.parse('http://localhost:3000/proveedores/$id');
  final response = await http.put(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(data),
  );
  return response.statusCode == 200;
}