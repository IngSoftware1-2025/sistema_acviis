import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/herramienta.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Función para obtener todas las herramientas
Future<List<Herramienta>> fetchHerramientasFromApi() async {
  final response = await http.get(Uri.parse('http://localhost:3000/herramientas'));
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => Herramienta.fromJson(e)).toList();
  } else {
    throw Exception('Error al obtener herramientas');
  }
}

// Función para obtener una herramienta por id
Future<Herramienta> fetchHerramientaFromApi(String id) async {
  final response = await http.get(Uri.parse('http://localhost:3000/herramientas/$id'));
  if (response.statusCode == 200) {
    final Map<String, dynamic> herramienta = jsonDecode(response.body);
    return Herramienta.fromJson(herramienta);
  } else {
    debugPrint('Error al obtener herramienta de id: $id: ${response.statusCode} - ${response.reasonPhrase}');
    throw Exception('Error al obtener herramienta');
  }
}