import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String baseUrl = 'http://localhost:3000/vehiculos-permisos';

/// Sube un permiso de circulación a MongoDB
/// Retorna el fileId del archivo subido
Future<String> subirPermisoCirculacion({
  required String vehiculoId,
  required File archivo,
}) async {
  try {
    final uri = Uri.parse('$baseUrl/upload-permiso');
    
    var request = http.MultipartRequest('POST', uri);
    
    // Agregar el ID del vehículo
    request.fields['vehiculoId'] = vehiculoId;
    
    // Agregar el archivo
    request.files.add(
      await http.MultipartFile.fromPath(
        'permiso',
        archivo.path,
      ),
    );
    
    print('[subirPermisoCirculacion] Subiendo permiso para vehículo: $vehiculoId');
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    print('[subirPermisoCirculacion] Status: ${response.statusCode}');
    print('[subirPermisoCirculacion] Body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['fileId'];
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Error al subir permiso');
    }
  } catch (e) {
    print('[subirPermisoCirculacion] Error: $e');
    rethrow;
  }
}

/// Obtiene la URL para descargar un permiso de circulación
String obtenerUrlPermisoCirculacion(String permisoId) {
  return '$baseUrl/download-permiso/$permisoId';
}

/// Elimina un permiso de circulación de MongoDB
Future<void> eliminarPermisoCirculacion(String permisoId) async {
  try {
    final uri = Uri.parse('$baseUrl/delete-permiso/$permisoId');
    
    print('[eliminarPermisoCirculacion] Eliminando permiso: $permisoId');
    
    final response = await http.delete(uri);
    
    print('[eliminarPermisoCirculacion] Status: ${response.statusCode}');
    
    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Error al eliminar permiso');
    }
  } catch (e) {
    print('[eliminarPermisoCirculacion] Error: $e');
    rethrow;
  }
}
