import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sistema_acviis/models/trabajador.dart';
import 'package:sistema_acviis/models/trabajador_obra.dart';

/// Obtiene la lista de trabajadores asignados a una obra específica
/// 
/// Retorna una lista de objetos [Trabajador] asignados a la obra.
/// En caso de error, lanza una Exception con el mensaje de error.
Future<List<Trabajador>> obtenerTrabajadoresDeObra(String obraId) async {
  const String apiBaseUrl = 'http://localhost:3000';
  final url = Uri.parse('$apiBaseUrl/obras/$obraId/trabajadores');

  try {
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Decodificar la respuesta
      final data = json.decode(response.body);
      
      // Convertir los datos en una lista de objetos Trabajador
      final List<dynamic> trabajadoresData = data['trabajadores'];
      List<Trabajador> trabajadores = [];
      
      // Iterar sobre cada trabajador y crear objetos Trabajador
      for (var trabajadorJson in trabajadoresData) {
        // Crear un mapa para construir un objeto Trabajador completo
        final Map<String, dynamic> trabajadorCompleto = {
          'id': trabajadorJson['id'],
          'nombre_completo': trabajadorJson['nombreCompleto'],
          'rut': trabajadorJson['rut'],
          'estado': trabajadorJson['estado'],
          // Campos requeridos pero que podrían no venir en la respuesta
          'estado_civil': '',
          'fecha_de_nacimiento': DateTime.now().toIso8601String(),
          'direccion': '',
          'correo_electronico': '',
          'sistema_de_salud': '',
          'prevision_afp': '',
          'contratos': []
        };
        
        trabajadores.add(Trabajador.fromJson(trabajadorCompleto));
      }
      
      return trabajadores;
    } else {
      // Intentar extraer el mensaje de error
      Map<String, dynamic> errorData = {};
      try {
        errorData = json.decode(response.body);
      } catch (_) {}
      
      throw Exception(errorData['error'] ?? 'Error al obtener trabajadores de la obra');
    }
  } catch (e) {
    throw Exception('Error al obtener trabajadores de la obra: $e');
  }
}