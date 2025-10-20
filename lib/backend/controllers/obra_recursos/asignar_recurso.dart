import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sistema_acviis/models/obra_recurso.dart';
import 'constants.dart';

// Asigna un recurso a una obra
Future<ObraRecurso> asignarRecurso({
  required String obraId,
  required String recursoTipo,
  String? vehiculoId,
  String? herramientaId,
  int? eppId,
  int cantidad = 1,
  String? observaciones,
}) async {
  // Validación de datos
  if (!['vehiculo', 'herramienta', 'epp'].contains(recursoTipo)) {
    throw Exception('Tipo de recurso inválido');
  }

  // Validar que se proporcione el ID correcto según el tipo
  if (recursoTipo == 'vehiculo' && vehiculoId == null) {
    throw Exception('Para tipo vehículo, se requiere vehiculoId');
  } else if (recursoTipo == 'herramienta' && herramientaId == null) {
    throw Exception('Para tipo herramienta, se requiere herramientaId');
  } else if (recursoTipo == 'epp' && eppId == null) {
    throw Exception('Para tipo EPP, se requiere eppId');
  }

  final response = await http.post(
    Uri.parse(baseUrl),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'obraId': obraId,
      'recursoTipo': recursoTipo,
      'vehiculoId': vehiculoId,
      'herramientaId': herramientaId,
      'eppId': eppId,
      'cantidad': cantidad,
      'observaciones': observaciones,
    }),
  );

  // SOLUCIÓN: Aceptar tanto 201 (creación) como 200 (actualización) como respuestas exitosas
  if (response.statusCode == 201 || response.statusCode == 200) {
    // Éxito - recurso asignado o reasignado
    final data = jsonDecode(response.body);
    print('[asignarRecurso] Respuesta del servidor exitosa (${response.statusCode}): ${response.body}');
    return ObraRecurso.fromJson(data['data']);
  } else {
    // Error
    final error = jsonDecode(response.body);
    print('[asignarRecurso] Error del servidor (${response.statusCode}): ${response.body}');
    throw Exception(error['error'] ?? 'Error al asignar recurso');
  }
}