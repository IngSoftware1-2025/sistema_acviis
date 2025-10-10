import 'package:http/http.dart' as http;
import 'package:sistema_acviis/models/obra.dart';

Future<List<Obra>> fetchObrasFromApi() async {
  try {
    // La URL base de tu API, consistente con otros controllers.
    const String apiBaseUrl = 'http://localhost:3000';
    final response = await http.get(Uri.parse('$apiBaseUrl/obras'));

    if (response.statusCode == 200) {
      return Obra.fromJsonList(response.body);
    } else {
      print('Error al cargar las obras desde la API: ${response.statusCode}');
      throw Exception('Fallo al cargar las obras desde la API');
    }
  } catch (e) {
    print('Error de conexión al cargar obras: $e');
    throw Exception('Fallo al conectar con la API');
  }
}
