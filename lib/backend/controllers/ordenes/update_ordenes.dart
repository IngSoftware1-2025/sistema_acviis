import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<bool> updateOrden(String id, Map<String, dynamic> data) async {
  // final url = Uri.parse('http://localhost:3000/api/ordenes/$id');
  final url = Uri.parse('http://localhost:3000/ordenes_de_compra/$id');

  try {
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      debugPrint('Orden de compra actualizada con éxito: $id');
      return true;
    } else {
      debugPrint('Error al actualizar la orden de compra: ${response.statusCode}');
      debugPrint('Cuerpo de la respuesta: ${response.body}');
      return false;
    }
  } catch (e) {
    debugPrint('Excepción al intentar actualizar la orden de compra: $e');
    return false;
  }
}
