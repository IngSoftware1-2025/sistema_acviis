import 'package:sistema_acviis/models/proveedor.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<Proveedor>> fetchProveedoresFromApi() async {
  final response = await http.get(Uri.parse('http://localhost:3000/proveedores'));
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => Proveedor.fromMap(e)).toList();
  } else {
    throw Exception('Error al obtener proveedores');
  }
}