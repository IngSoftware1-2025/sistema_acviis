import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> updateVehiculo(Map<String, dynamic> vehiculoData) async {
  final id = vehiculoData['id'];
  final url = Uri.parse('http://localhost:3000/vehiculos/$id/datos');

  final response = await http.put(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'patente': vehiculoData['patente'],
      'permiso_circ': vehiculoData['permiso_circ'],
      'revision_tecnica': DateTime.parse(vehiculoData['revision_tecnica']).toUtc().toIso8601String(),
      'revision_gases': DateTime.parse(vehiculoData['revision_gases']).toUtc().toIso8601String(),
      'ultima_mantencion': DateTime.parse(vehiculoData['ultima_mantencion']).toUtc().toIso8601String(),
      'descripcion_mant': vehiculoData['descripcion_mant'],
      'capacidad_kg': vehiculoData['capacidad_kg'],
      'neumaticos': vehiculoData['neumaticos'],
      'rueda_repuesto': vehiculoData['rueda_repuesto'],
      'observaciones': vehiculoData['observaciones'],
      'proxima_mantencion': DateTime.parse(vehiculoData['proxima_mantencion']).toUtc().toIso8601String(),
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Error al actualizar vehículo: ${response.body}');
  }
}