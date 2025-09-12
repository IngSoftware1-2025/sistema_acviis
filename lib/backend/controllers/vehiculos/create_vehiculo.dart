import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> createVehiculo({
  required String patente,
  required String permisoCirculacion, 
  DateTime? fechaRevisionTecnica,
  DateTime? fechaRevisionGases,
  DateTime? fechaUltimaMantencion,
  DateTime? fechaProximaMantencion,
  String? desc_mantencion,
  required int capacidadKg,
  required String tipoNeumaticos,
  String? observaciones,
  required bool tieneRuedaRepuesto,
}) async {
  final url = Uri.parse('http://localhost:3000/vehiculos');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'patente': patente,
      'permiso_circ': permisoCirculacion,
      'revision_tecnica': fechaRevisionTecnica?.toIso8601String(),
      'revision_gases': fechaRevisionGases?.toIso8601String(),
      'ultima_mantencion': fechaUltimaMantencion?.toIso8601String(),
      'proxima_mantencion': fechaProximaMantencion?.toIso8601String(),
      'descripcion_mant': desc_mantencion,
      'capacidad_kg': capacidadKg,
      'neumaticos': tipoNeumaticos,
      'observaciones': observaciones,
      'rueda_repuesto': tieneRuedaRepuesto,
    }),
  );

  if (response.statusCode == 201) {
    final data = jsonDecode(response.body);
    return data['id']; 
  } else {
    throw Exception('Error al crear vehículo: ${response.body}');
  }
}
