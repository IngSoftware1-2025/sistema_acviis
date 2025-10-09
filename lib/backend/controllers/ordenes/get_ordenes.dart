import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/ordenes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


// Función para obtener todas las órdenes de compra
Future<List<OrdenCompra>> fetchOrdenesFromApi() async {
  final response = await http.get(Uri.parse('http://localhost:3000/ordenes_de_compra'));
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => OrdenCompra.fromJson(e)).toList();
  } else {
    throw Exception('Error al obtener órdenes de compra');
  }
}

// Función para obtener una orden de compra por id
Future<OrdenCompra> fetchOrdenFromApi(String id) async {
  final response = await http.get(Uri.parse('http://localhost:3000/ordenes_de_compra/$id'));
  if (response.statusCode == 200) {
    final Map<String, dynamic> orden = jsonDecode(response.body);
    return OrdenCompra.fromJson(orden);
  } else {
    debugPrint('Error al obtener orden de compra de id: $id: ${response.statusCode} - ${response.reasonPhrase}');
    throw Exception('Error al obtener orden de compra');
  }
}