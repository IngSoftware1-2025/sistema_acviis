import 'package:sistema_acviis/models/trabajador.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


// Funcion que crea la peticion al servidor para conseguir todos los trabajadores
Future<List<Trabajador>> fetchTrabajadoresFromApi() async {
  final response = await http.get(Uri.parse('http://localhost:3000/trabajadores'));

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => Trabajador.fromJson(e)).toList();
  } else {
    throw Exception('Error al obtener trabajadores');
  }
}