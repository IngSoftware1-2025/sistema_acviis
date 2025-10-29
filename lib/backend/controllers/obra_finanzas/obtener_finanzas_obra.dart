import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sistema_acviis/models/obra_finanza.dart';
import 'constants.dart';

Future<List<ObraFinanza>> obtenerFinanzasObra({
  required String obraId,
  String? tipo,
}) async {
  String url = '$baseUrl/obra/$obraId';
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  
  if (tipo != null) {
    url += '?tipo=$tipo&_=$timestamp';
  } else {
    url += '?_=$timestamp';
  }
  
  print('[obtenerFinanzasObra] Solicitando finanzas: $url');

  try {
    final response = await http.get(Uri.parse(url));
    print('[obtenerFinanzasObra] Código de respuesta: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List finanzas = data['finanzas'];
      print('[obtenerFinanzasObra] Finanzas obtenidas: ${finanzas.length}');
      
      return finanzas.map((json) => ObraFinanza.fromJson(json)).toList();
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Error al obtener finanzas');
    }
  } catch (e) {
    print('[obtenerFinanzasObra] Excepción: $e');
    rethrow;
  }
}