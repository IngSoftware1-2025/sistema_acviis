import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sistema_acviis/models/pagos.dart';

// crea un pago en el servidor usando el modelo Pago
Future<void> crearPago(Pago pago) async {
  final url = Uri.parse('http://localhost:3000/pagos');
  final body = pago.toMap();
  body.remove('id');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(body),
  );
  if (response.statusCode != 201 && response.statusCode != 200) {
    throw Exception('Error al crear pago: ${response.body}');
  }
}