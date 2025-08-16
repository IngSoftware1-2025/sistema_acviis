import 'package:http/http.dart' as http;

Future<bool> deleteProveedor(String id) async {
  final url = Uri.parse('http://localhost:3000/proveedores/$id');
  final response = await http.delete(url);
  return response.statusCode == 200;
}