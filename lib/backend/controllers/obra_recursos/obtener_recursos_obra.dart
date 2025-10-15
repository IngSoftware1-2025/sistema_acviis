import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sistema_acviis/models/obra_recurso.dart';
import 'constants.dart';

// Obtiene todos los recursos asignados a una obra específica
Future<List<ObraRecurso>> obtenerRecursosObra({
  required String obraId,
  String? tipo,
}) async {
  // Añadir un timestamp para evitar caché
  String url = '$baseUrl/obra/$obraId';
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  
  if (tipo != null) {
    url += '?tipo=$tipo&_=$timestamp';
  } else {
    url += '?_=$timestamp';
  }
  
  print('[SOLUCIÓN] Solicitando recursos de obra con timestamp: $url');

  try {
    final response = await http.get(Uri.parse(url));
    print('[obtenerRecursosObra] Código de respuesta: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List recursos = data['recursos'];
      print('[obtenerRecursosObra] Recursos obtenidos: ${recursos.length}');
      
      final listaRecursos = recursos.map((json) => ObraRecurso.fromJson(json)).toList();
      
      // Verificar los recursos obtenidos
      print('[obtenerRecursosObra] Recursos convertidos: ${listaRecursos.length}');
      if (listaRecursos.isNotEmpty) {
        listaRecursos.take(3).forEach((r) => 
          print('- ID: ${r.id}, Tipo: ${r.tipo}, Estado: ${r.estado}')
        );
      }
      
      return listaRecursos;
    } else {
      final error = jsonDecode(response.body);
      final errorMsg = error['error'] ?? 'Error al obtener recursos de la obra';
      print('[obtenerRecursosObra] Error: $errorMsg');
      throw Exception(errorMsg);
    }
  } catch (e) {
    print('[obtenerRecursosObra] Excepción: $e');
    rethrow;
  }
}