import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> darDeBajaOrdenes(List<String> ids) async {
  final baseUrl = 'http://localhost:3000/ordenes_de_compra';

  for (final id in ids) {
    final url = Uri.parse('$baseUrl/$id/dar-de-baja');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Órden de compra ${id} dada de baja correctamente: ${data['mensaje']}");
    } else {
      print("Error al dar de baja la órden de compra ${id}: ${response.body}");
      throw Exception('Error al dar de baja la órden de compra ${id}');
    }
  }
}