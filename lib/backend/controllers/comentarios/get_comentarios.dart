import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sistema_acviis/models/comentarios.dart';

//get de comentario por id de contrato
Future<List<Comentario>> getComentariosPorContrato(String idContrato) async {
  final url = Uri.parse('http://localhost:3000/comentarios/contrato/$idContrato');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => Comentario.fromMap(e)).toList();
  } else {
    throw Exception('Error al obtener comentarios: ${response.body}');
  }
}

// get de comentario por id de trabajador
Future<List<Comentario>> getComentariosPorTrabajador(String idTrabajador) async {
  final url = Uri.parse('http://localhost:3000/comentarios/trabajador/$idTrabajador');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => Comentario.fromMap(e)).toList();
  } else {
    throw Exception('Error al obtener comentarios: ${response.body}');
  }
}

// get de comentario por id de anexo
Future<List<Comentario>> getComentariosPorAnexo(String idAnexo) async {
  final url = Uri.parse('http://localhost:3000/comentarios/anexo/$idAnexo');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => Comentario.fromMap(e)).toList();
  } else {
    throw Exception('Error al obtener comentarios: ${response.body}');
  }
}