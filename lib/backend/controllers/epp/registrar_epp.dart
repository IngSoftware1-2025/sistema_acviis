import 'dart:convert';
import 'package:http/http.dart' as http;

// Actualizamos los argumentos para coincidir con lo que necesita el sistema
Future<String> createEpp({
  required String tipo,            // Cambiado de tipoEquipamiento a tipo
  required List<String> obrasAsignadas, // Cambiado de String a List<String>
  required int cantidad,           // Cambiado a int
  String? certificadoId,           // [NUEVO] Agregamos el ID del certificado
}) async {
  final url = Uri.parse('http://localhost:3000/logistica');

  // Convertimos el body a JSON usando las mismas llaves que el modelo EPP.fromJson espera
  final bodyMap = {
    'tipo': tipo,
    'obrasAsignadas': obrasAsignadas, // Enviamos la lista ["Oficina Central"]
    'cantidad': cantidad,
    'fechaRegistro': DateTime.now().toIso8601String(),
  };

  // Solo agregamos el certificado si existe
  if (certificadoId != null) {
    bodyMap['certificadoId'] = certificadoId;
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
