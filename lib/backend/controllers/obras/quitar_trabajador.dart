import 'dart:convert';
import 'package:http/http.dart' as http;

/// Quita un trabajador de una obra específica
/// 
/// Retorna true si se quitó correctamente, false en caso contrario.
/// En caso de error, lanza una Exception con el mensaje de error.
Future<bool> quitarTrabajador({
  required String obraId,
  required String trabajadorId,
}) async {
  const String apiBaseUrl = 'http://localhost:3000';
  final url = Uri.parse('$apiBaseUrl/obras/quitar-trabajador');

  try {
    // Se usa PUT en lugar de POST porque estamos actualizando un recurso existente
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'obraId': obraId,
        'trabajadorId': trabajadorId,
      }),
    );

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      // Intentar obtener la respuesta
      try {
        final responseData = json.decode(response.body);
        print("Desasignación exitosa: ${responseData['message']}");
      } catch (_) {
        print("Desasignación exitosa");
      }
      return true; // Operación exitosa
    } else {
      // Intentar extraer el mensaje de error
      Map<String, dynamic> errorData = {};
      try {
        errorData = json.decode(response.body);
      } catch (_) {}
      
      final errorMessage = errorData['error'] ?? 'Error al quitar trabajador de la obra';
      print("Error en quitarTrabajador: $errorMessage");
      throw Exception(errorMessage);
    }
  } catch (e) {
    print("Excepción en quitarTrabajador: $e");
    throw Exception('Error al quitar trabajador de la obra: $e');
  }
}