import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/vehiculo.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


// Función para obtener todas los vehículos
Future<List<Vehiculo>> fetchVehiculosFromApi() async {
  final response = await http.get(Uri.parse('http://localhost:3000/vehiculos'));
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => Vehiculo.fromJson(e)).toList();
  } else {
    throw Exception('Error al obtener vehiculos');
  }
}

// Función para obtener un vehpiculo por id
Future<Vehiculo> fetchVehiculoFromApi(String id) async {
  final response = await http.get(Uri.parse('http://localhost:3000/vehiculos/$id'));
  if (response.statusCode == 200) {
    final Map<String, dynamic> vehiculo = jsonDecode(response.body);
    return Vehiculo.fromJson(vehiculo);
  } else {
    debugPrint('Error al obtener vehículo de id: $id: ${response.statusCode} - ${response.reasonPhrase}');
    throw Exception('Error al obtener vehículo');
  }
}