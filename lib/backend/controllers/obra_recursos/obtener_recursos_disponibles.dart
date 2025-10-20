import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';

// Obtiene recursos disponibles para asignar
Future<List<dynamic>> obtenerRecursosDisponibles({
  required String tipo,
}) async {
  final url = '$baseUrl/disponibles/$tipo';
  print('[obtenerRecursosDisponibles] Solicitando recursos disponibles a: $url');
  
  // Añadir timestamp para evitar caché del navegador
  final timestampedUrl = '$url?_=${DateTime.now().millisecondsSinceEpoch}';
  
  try {
    // Usar una cabecera personalizada para evitar caché
    final headers = {
      'Cache-Control': 'no-cache',
      'Pragma': 'no-cache',
      'X-Requested-With': 'XMLHttpRequest',
    };
    
    final response = await http.get(
      Uri.parse(timestampedUrl),
      headers: headers
    );
    
    print('[obtenerRecursosDisponibles] Código de estado: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final recursos = data['recursos'] ?? [];
      print('[obtenerRecursosDisponibles] Recursos obtenidos: ${recursos.length}');
      
      // Mostrar los primeros recursos para depuración
      if (recursos.isNotEmpty) {
        final muestra = recursos.take(3).toList();
        print('[obtenerRecursosDisponibles] Muestra de recursos:');
        muestra.forEach((r) => print('- ID: ${r['id']}, Tipo: ${r['tipo'] ?? ''}, Estado: ${r['estado'] ?? 'N/A'}'));
      }
      
      return recursos;
    } else {
      try {
        final error = jsonDecode(response.body);
        final errorMsg = error['error'] ?? 'Error al obtener recursos disponibles';
        print('[obtenerRecursosDisponibles] Error: $errorMsg');
        throw Exception(errorMsg);
      } catch (e) {
        final errorMsg = 'Error en la respuesta del servidor: ${response.body}';
        print('[obtenerRecursosDisponibles] Error: $errorMsg');
        throw Exception(errorMsg);
      }
    }
  } catch (e) {
    print('[obtenerRecursosDisponibles] Excepción: $e');
    rethrow;
  }
}