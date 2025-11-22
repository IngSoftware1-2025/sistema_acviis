import 'dart:convert';
import 'package:http/http.dart' as http;

// Actualizamos los argumentos para coincidir con lo que necesita el sistema
Future<String> createEpp({
  required String tipo,            // Tipo de EPP
  required int cantidadTotal,      // Cantidad total
  int? cantidadDisponible,         // Cantidad disponible (opcional, por defecto igual a cantidadTotal)
  String? certificadoId,           // ID del certificado
}) async {
  final url = Uri.parse('http://localhost:3000/logistica');

  // Convertimos el body a JSON
  final bodyMap = {
    'tipo': tipo,
    'cantidadTotal': cantidadTotal,
    'cantidad_total': cantidadTotal,
    'cantidadDisponible': cantidadDisponible ?? cantidadTotal,
    'cantidad_disponible': cantidadDisponible ?? cantidadTotal,
    'fechaRegistro': DateTime.now().toIso8601String(),
    'fecha_registro': DateTime.now().toIso8601String(),
  };

  // Solo agregamos el certificado si existe
  if (certificadoId != null) {
    bodyMap['certificadoId'] = certificadoId;
    bodyMap['certificado_id'] = certificadoId;
  }

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(bodyMap),
  );

  if (response.statusCode == 201) {
    final data = jsonDecode(response.body);
    return data['id'].toString(); 
  } else {
    throw Exception('Error al crear EPP: ${response.body}');
  }
}
