import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sistema_acviis/models/obra_finanza.dart';
import 'constants.dart';

Future<ObraFinanza> cerrarCajaChica(
  String id, {
  String? observaciones,
}) async {
  final response = await http.put(
    Uri.parse('$baseUrl/$id/cerrar'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'estado': 'cerrada',
      'observaciones': observaciones,
      'fechaCierre': DateTime.now().toIso8601String(),
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print('[cerrarCajaChica] Respuesta exitosa: ${response.body}');
    return ObraFinanza.fromJson(data['data'] ?? data);
  } else {
    final error = jsonDecode(response.body);
    print('[cerrarCajaChica] Error: ${response.body}');
    throw Exception(error['error'] ?? 'Error al cerrar caja chica');
  }
}