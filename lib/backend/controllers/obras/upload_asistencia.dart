import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

Future<bool> uploadAsistencia({
  required String charlaId,
  required String fileName,
  required List<int> fileBytes,
}) async {
  const String apiBaseUrl = 'http://localhost:3000';
  final url = Uri.parse('$apiBaseUrl/obras/charlas/$charlaId/asistencia');

  try {
    var request = http.MultipartRequest('POST', url);
    request.files.add(http.MultipartFile.fromBytes(
      'asistencia', // Este es el nombre del campo que espera multer: upload.single('asistencia')
      fileBytes,
      filename: fileName,
      contentType: MediaType('application', 'octet-stream'),
    ));

    var response = await request.send();

    return response.statusCode == 201;
  } catch (e) {
    throw Exception('Error de conexión al subir asistencia: $e');
  }
}
