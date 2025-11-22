import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sistema_acviis/models/obra_finanza.dart';
import 'constants.dart';

Future<ObraFinanza> modificarCajaChica(
  String id, {
  required double montoTotalAsignado,
  required double montoTotalUtilizado,
  required double montoUtilizadoImpago,
  required double montoUtilizadoResuelto,
}) async {
  final response = await http.put(
    Uri.parse('$baseUrl/$id'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'detalles': {
        'montoTotalAsignado': montoTotalAsignado,
        'montoTotalUtilizado': montoTotalUtilizado,
        'montoUtilizadoImpago': montoUtilizadoImpago,
        'montoUtilizadoResuelto': montoUtilizadoResuelto,
      },
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print('[modificarCajaChica] Respuesta exitosa: ${response.body}');
    return ObraFinanza.fromJson(data['data'] ?? data);
  } else {
    final error = jsonDecode(response.body);
    print('[modificarCajaChica] Error: ${response.body}');
    throw Exception(error['error'] ?? 'Error al modificar caja chica');
  }
}