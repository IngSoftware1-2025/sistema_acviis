import 'package:sistema_acviis/models/contrato.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


// Función que crea la petición al servidor para conseguir todos los contratos
Future<List<Contrato>> fetchContratosFromApi() async {
  final response = await http.get(Uri.parse('http://localhost:3000/contratos/supabase'));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data is List) {
      return data.map((e) => Contrato.fromJson(e)).toList();
    } else {
      throw Exception('La respuesta no es una lista de contratos');
    }
  } else {
    throw Exception('Error al obtener contratos');
  }
}