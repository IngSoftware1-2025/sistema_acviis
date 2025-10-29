import 'package:sistema_acviis/models/itemizado.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Obtiene TODOS los itemizados 
Future<List<Itemizado>> getItemizados() async {
  final url = Uri.parse('http://localhost:3000/itemizados');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Itemizado.fromJson(json)).toList();
  } else {
    throw Exception('Error al obtener itemizados');
  }
}

/// Obtiene los itemizados asociados a una obra específica
Future<List<Itemizado>> getItemizadosPorObra(String obraId) async {
  final url = Uri.parse('http://localhost:3000/itemizados/obra/$obraId');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Itemizado.fromJson(json)).toList();
  } else {
    throw Exception('Error al obtener itemizados de la obra');
  }
}
