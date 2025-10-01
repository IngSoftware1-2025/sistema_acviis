import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/trabajador.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


// Funcion que crea la peticion al servidor para conseguir todos los trabajadores
Future<List<Trabajador>> fetchTrabajadoresFiltrados(Map<dynamic, dynamic>? filtrosTrabajadores) async {
  // Construir los parámetros de consulta a partir de los filtros
  final Map<String, dynamic> queryParameters = filtrosTrabajadores != null
      ? filtrosTrabajadores.map((key, value) => MapEntry(key.toString(), value.toString()))
      : <String, dynamic>{};

  final uri = Uri.http('localhost:3000/trabajadores/$queryParameters'); // Funciona como si fuera por ID
  final response = await http.get(uri);
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((e) => Trabajador.fromJson(e))
        .where((trabajador) => trabajador.estado != 'Eliminado')
        .toList();
  } else {
    throw Exception('Error al obtener trabajadores');
  }
}
