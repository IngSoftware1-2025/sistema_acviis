import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> createEpp({
  required String numeroIdentificador,
  required String tipoEquipamiento,
  required String obraAsignada,
  required String cantidadDisponible,

}) async {
  final url = Uri.parse('http://localhost:3000/logistica');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'numero_identificador': numeroIdentificador,
      'tipo_equipamiento': tipoEquipamiento,
      'obra_asignada': obraAsignada,
      'cantidad_disponible': cantidadDisponible,
    }),
  );

  if (response.statusCode == 201) {
    final data = jsonDecode(response.body);
    return data['id']; 
  } else {
    throw Exception('Error al crear EPP: ${response.body}');
  }
}
