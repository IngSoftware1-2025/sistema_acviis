import 'package:sistema_acviis/models/pagos.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<Pago>> fetchOtrosPagosFromAPI() async {
  final response = await http.get(Uri.parse('http://localhost:3000/pagos'));
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((e) => Pago.fromMap(e))
        .where((pago) => pago.tipoPago != 'factura' && pago.visualizacion == 'activo')
        .toList();
  }
  return [];
}

Future<List<Pago>> fetchFacturasFromAPI() async {
  final response = await http.get(Uri.parse('http://localhost:3000/pagos'));
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data
          .map((e) => Pago.fromMap(e))
          .where((pago) => pago.tipoPago == 'factura' && pago.visualizacion == 'activo')
          .toList();
    }
    return [];
  }