import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> createContrato() async {
  Map<String, String> data = {
    'nombre': 'Test1',
    'fechaInicio': 'Test1',
    'cargo': 'Test1',
    'salario': 'Test1',
  };
  final response = await http.post(
    Uri.parse('http://localhost:3000/contratos/mongo'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(data),
  );
  if (response.statusCode == 201 || response.statusCode == 200) {
    print('Contrato creado correctamente');
  } else {
    print('Error al crear contrato: ${response.statusCode}');
    print('Respuesta del backend: ${response.body}');
    throw Exception('Error al crear contrato');
  }
}