import 'package:sistema_acviis/models/itemizado.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<Itemizado>> getItemizados() async {
  final url = Uri.parse('http://localhost:3000/itemizados');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => Itemizado.fromJson(e)).toList();
  } else {
    throw Exception('Error al obtener itemizados');
  }
}
