import 'package:http/http.dart' as http;

Future<bool> deleteAsistenciaFromApi(String asistenciaId) async {
  const String apiBaseUrl = 'http://localhost:3000';
  final url = Uri.parse('$apiBaseUrl/obras/charlas/asistencia/$asistenciaId');

  try {
    final response = await http.delete(url);

    // Consideramos éxito si el status es 200 (OK) o 404 (No encontrado, ya fue borrado)
    return response.statusCode == 200 || response.statusCode == 404;
  } catch (e) {
    throw Exception('Error de conexión al eliminar asistencia: $e');
  }
}
