import 'package:http/http.dart' as http;
import 'dart:convert';


// Función para crear un trabajador nuevo en el backend
Future<void> createTrabajador({
  required String nombre,
  required apellido,
  required String email,
  required edad,
}) async {
  final url = Uri.parse('http://localhost:3000/trabajadores'); // Ajusta según backend

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'edad': edad,
    }),
  );

  if (response.statusCode != 201) {
    throw Exception('Error al crear trabajador: ${response.body}');
  }
}