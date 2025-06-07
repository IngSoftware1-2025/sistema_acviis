import 'package:http/http.dart' as http;

Future<void> mongoConnection() async {
  final url = Uri.parse('http://localhost:3000/contratos/mongo');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: '{}', // Replace with actual JSON if needed
  );

  if (response.statusCode == 200) {
    //print('Conexión a MongoDB exitosa: ${response.body}');
    print('Documento cargado exitosiamente: ${response.body}');
  } else {
    print('Error al subir documento: ${response.body}');
  }
}