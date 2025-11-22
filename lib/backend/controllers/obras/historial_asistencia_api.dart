import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

const String _apiBase = 'http://localhost:3000';

Future<Map<String, dynamic>> uploadFileFromBytesApi(Uint8List bytes, String filename, {String? obraId}) async {
  final uri = Uri.parse('$_apiBase/historial-asistencia/upload-register');
  final request = http.MultipartRequest('POST', uri);
  request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));
  if (obraId != null) request.fields['obraId'] = obraId;
  request.fields['fecha_subida'] = DateTime.now().toIso8601String();

  final streamedResp = await request.send();
  final respStr = await streamedResp.stream.bytesToString();
  final status = streamedResp.statusCode;
  if (status >= 200 && status < 300) {
    try {
      final json = jsonDecode(respStr);
      return {'ok': true, 'body': json};
    } catch (_) {
      return {'ok': true, 'body': respStr};
    }
  } else {
    throw Exception('Upload failed (status $status): $respStr');
  }
}

Future<Uint8List> downloadLatestExcelBytesApi(String obraId) async {
  if (obraId.isEmpty) throw Exception('obraId vacío');
  final importUri = Uri.parse('$_apiBase/historial-asistencia/import/${Uri.encodeComponent(obraId)}');
  final importResp = await http.get(importUri);
  if (importResp.statusCode != 200) {
    throw Exception('No se encontró id del archivo (status ${importResp.statusCode})');
  }
  dynamic importJson;
  try {
    importJson = jsonDecode(importResp.body);
  } catch (_) {
    throw Exception('Respuesta inválida al obtener id del archivo');
  }
  final fileId = importJson != null && importJson['id_excel'] != null ? importJson['id_excel'].toString() : null;
  if (fileId == null || fileId.isEmpty) {
    throw Exception('Respuesta no contiene id_excel');
  }

  final fileUri = Uri.parse('$_apiBase/historial-asistencia/file/$fileId');
  final fileResp = await http.get(fileUri);
  if (fileResp.statusCode != 200) {
    throw Exception('Error al descargar archivo (status ${fileResp.statusCode})');
  }
  final bytes = fileResp.bodyBytes;
  if (bytes == null || bytes.isEmpty) {
    throw Exception('Archivo descargado vacío');
  }
  return bytes;
}

Future<Map<String, dynamic>> downloadLatestExcelFileApi(String obraId) async {
  if (obraId.isEmpty) throw Exception('obraId vacío');
  final importUri = Uri.parse('$_apiBase/historial-asistencia/import/${Uri.encodeComponent(obraId)}');
  final importResp = await http.get(importUri);
  if (importResp.statusCode != 200) {
    throw Exception('No se encontró id del archivo (status ${importResp.statusCode})');
  }
  dynamic importJson;
  try {
    importJson = jsonDecode(importResp.body);
  } catch (_) {
    throw Exception('Respuesta inválida al obtener id del archivo');
  }
  final fileId = importJson != null && importJson['id_excel'] != null ? importJson['id_excel'].toString() : null;
  if (fileId == null || fileId.isEmpty) {
    throw Exception('Respuesta no contiene id_excel');
  }

  final fileUri = Uri.parse('$_apiBase/historial-asistencia/file/$fileId');
  final fileResp = await http.get(fileUri);
  if (fileResp.statusCode != 200) {
    throw Exception('Error al descargar archivo (status ${fileResp.statusCode})');
  }
  final bytes = fileResp.bodyBytes;
  if (bytes == null || bytes.isEmpty) {
    throw Exception('Archivo descargado vacío');
  }
  return {'fileId': fileId, 'bytes': bytes};
}