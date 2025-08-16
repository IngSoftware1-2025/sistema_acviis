import 'package:http/http.dart' as http;
import 'dart:convert';

Future<bool> createProveedor(Map<String, dynamic> data) async {
  final url = Uri.parse('http://localhost:3000/proveedores');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(data),
  );
  if (response.statusCode == 201) {
    return true;
  } else {
    print('Error al registrar proveedor: ${response.body}');
    return false;
  }
}