import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> actualizarContrato(
  String id, {
  required String plazo,
  required String comentario,
  required String documento,
  required String estado,
}) async {
  final url = Uri.parse('http://localhost:3000/contratos/supabase/$id/datos');
  final response = await http.put(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'plazo_de_contrato': plazo,
      'documento_de_vacaciones_del_trabajador': documento,
      'estado': estado,
    }),
  );
  if (response.statusCode != 200) {
    throw Exception('Error al actualizar contrato: ${response.body}');
  }
}