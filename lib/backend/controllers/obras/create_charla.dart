import 'dart:convert';
import 'package:http/http.dart' as http;

Future<bool> createCharla({
  required String obraId,
  required DateTime fechaProgramada,
  String? tipoProgramacion,
  int? intervaloDias,
}) async {
  const String apiBaseUrl = 'http://localhost:3000';
  final url = Uri.parse('$apiBaseUrl/obras/$obraId/charlas');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'fecha_programada': fechaProgramada.toIso8601String(),
        'tipo_programacion': tipoProgramacion,
        'intervalo_dias': intervaloDias,
      }),
    );

    if (response.statusCode == 201) {
      return true; // Éxito
    } else {
      throw Exception('Error al crear la charla: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    throw Exception('Error de conexión al crear charla: $e');
  }
}
