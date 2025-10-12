import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sistema_acviis/models/obra_recurso.dart';
import 'constants.dart';

// Retira un recurso de una obra
Future<ObraRecurso> retirarRecurso({
  required String id,
  String? observaciones,
}) async {
  final response = await http.put(
    Uri.parse('$baseUrl/$id/retirar'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'observaciones': observaciones,
    }),
  );

  if (response.statusCode == 200) {
    // Éxito - recurso retirado
    final data = jsonDecode(response.body);
    return ObraRecurso.fromJson(data['data']);
  } else {
    // Error
    final error = jsonDecode(response.body);
    throw Exception(error['error'] ?? 'Error al retirar recurso');
  }
}