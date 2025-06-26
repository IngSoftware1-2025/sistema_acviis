import 'package:sistema_acviis/models/trabajador.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


// Funcion que crea la peticion al servidor para conseguir todos los trabajadores
Future<List<Trabajador>> fetchTrabajadoresFromApi() async {
  final response = await http.get(Uri.parse('http://localhost:3000/trabajadores'));
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    /*
    ahora filtra los trabajadores que no estan eliminados
    y crea una lista de Trabajador a partir de los datos
    y devuelve esa lista
    filtramos los trabajadores que no estan eliminados
    asi los aliminamos del sistema pero no de la base de datos
    */
    return data
        .map((e) => Trabajador.fromJson(e))
        .where((trabajador) => trabajador.estado != 'Eliminado')
        .toList();
  } else {
    throw Exception('Error al obtener trabajadores');
  }
}