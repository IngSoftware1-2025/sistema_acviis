import 'package:http/http.dart' as http;
import 'dart:convert';

Future<bool> createProveedor(Map<String, dynamic> proveedor) async {
  final response = await http.post(
    Uri.parse('http://localhost:3000/proveedores'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(proveedor),
  );
  if (response.statusCode != 201) {
    print(response.body); // Esto te mostrará el error exacto
  }
  return response.statusCode == 201;
}