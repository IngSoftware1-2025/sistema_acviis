import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sistema_acviis/models/notificacion.dart';

Future<bool> saveConfiguracionNotificaciones(NotificacionConfig config) async {
  final url = Uri.parse("http://localhost:3000/finanzas/configurar-notificaciones");
  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(config.toJson()),
  );

  return response.statusCode == 200;
}
