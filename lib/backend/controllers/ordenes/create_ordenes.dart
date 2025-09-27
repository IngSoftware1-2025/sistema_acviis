import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> createOrden({
  required String proveedorId,
  required String numeroOrden,
  required DateTime fechaEmision,
  required String centroCosto,
  String? seccionItemizado,
  required String numeroCotizacion,
  required String numeroContacto,
  required String nombreServicio,
  required int valor,
  required bool descuento,
  String? notasAdicionales,
  String? estado,
}) async {
  final url = Uri.parse('http://localhost:3000/ordenes_de_compra');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'proveedorId': proveedorId,
      'numero_orden': numeroOrden,
      'fecha_emision': fechaEmision.toIso8601String(),
      'centro_costo': centroCosto,
      'seccion_itemizado': seccionItemizado,
      'numero_cotizacion': numeroCotizacion,
      'numero_contacto': numeroContacto,
      'nombre_servicio': nombreServicio,
      'valor': valor,
      'descuento': descuento,
      'notas_adicionales': notasAdicionales,
      'estado': estado ?? 'Activo',
    }),
  );

  if (response.statusCode == 201) {
    final data = jsonDecode(response.body);
    return data['id']; 
  } else {
    throw Exception('Error al crear orden de compra: ${response.body}');
  }
}
