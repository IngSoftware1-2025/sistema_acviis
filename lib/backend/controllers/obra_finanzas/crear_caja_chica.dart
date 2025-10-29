import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sistema_acviis/models/obra_finanza.dart';
import 'constants.dart';

Future<ObraFinanza> crearCajaChica({
  required String obraId,
  required String proposito,
  required double montoTotalAsignado,
}) async {
  final response = await http.post(
    Uri.parse(baseUrl),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'obraId': obraId,
      'tipo': 'caja chica',
      'proposito': proposito,
      'estado': 'activa',
      'detalles': {
        'montoTotalAsignado': montoTotalAsignado,
        'montoTotalUtilizado': 0,
        'montoUtilizadoImpago': 0,
        'montoUtilizadoResuelto': 0,
      },
    }),
  );

  if (response.statusCode == 201 || response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print('[crearCajaChica] Respuesta exitosa: ${response.body}');
    return ObraFinanza.fromJson(data['data'] ?? data);
  } else {
    final error = jsonDecode(response.body);
    print('[crearCajaChica] Error: ${response.body}');
    throw Exception(error['error'] ?? 'Error al crear caja chica');
  }
}