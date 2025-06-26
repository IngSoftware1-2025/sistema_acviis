import 'dart:convert';
import 'package:http/http.dart' as http;

// crea un comentario en el servidor
Future<void> crearComentario({
  required String idTrabajador,
  required String comentario,
  required DateTime fecha,
  String? idContrato, // <-- opcional
}) async {
  final url = Uri.parse('http://localhost:3000/comentarios');
  final body = {
    'id_trabajadores': idTrabajador,
    'comentario': comentario,
    'fecha': fecha.toIso8601String(),
    if (idContrato != null) 'id_contrato': idContrato, // solo si no es null
  };
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(body),
  );
  if (response.statusCode != 201) {
    throw Exception('Error al crear comentario: ${response.body}');
  }
}