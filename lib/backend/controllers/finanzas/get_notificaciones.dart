import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sistema_acviis/models/notificacion.dart';

// Obtener configuración actual
Future<NotificacionConfig?> getConfiguracionNotificaciones() async {
  final url = Uri.parse("http://localhost:3000/finanzas/configuracion-notificaciones");
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return NotificacionConfig.fromJson(data);
  } else {
    return null;
  }
}

