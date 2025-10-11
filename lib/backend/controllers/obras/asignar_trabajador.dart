import 'dart:convert';
import 'package:http/http.dart' as http;

/// Asigna un trabajador a una obra específica
/// 
/// Retorna true si se asignó correctamente, false en caso contrario.
/// En caso de error, lanza una Exception con el mensaje de error.
Future<bool> asignarTrabajador({
  required String obraId,
  required String trabajadorId,
  String? rolEnObra,
}) async {
  const String apiBaseUrl = 'http://localhost:3000';
  final url = Uri.parse('$apiBaseUrl/obras/asignar-trabajador');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'obraId': obraId,
        'trabajadorId': trabajadorId,
        if (rolEnObra != null) 'rolEnObra': rolEnObra,
      }),
    );

    if (response.statusCode == 201) {
      // Intentar obtener la respuesta
      try {
        final responseData = json.decode(response.body);
        print("Asignación exitosa: ${responseData['message']}");
      } catch (_) {
        print("Asignación exitosa");
      }
      return true; // Asignación exitosa
    } else {
      // Intentar extraer el mensaje de error
      Map<String, dynamic> errorData = {};
      try {
        errorData = json.decode(response.body);
      } catch (_) {}
      
      final errorMessage = errorData['error'] ?? 'Error al asignar trabajador a la obra';
      print("Error en asignarTrabajador: $errorMessage");
      throw Exception(errorMessage);
    }
  } catch (e) {
    print("Excepción en asignarTrabajador: $e");
    throw Exception('Error al asignar trabajador a la obra: $e');
  }
}