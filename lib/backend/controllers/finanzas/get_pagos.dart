import 'package:sistema_acviis/models/pagos.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Función para otros pagos (sin facturas ni caja chica)
Future<List<Pago>> fetchOtrosPagosFromAPI() async {
  final response = await http.get(Uri.parse('http://localhost:3000/pagos'));
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((e) => Pago.fromMap(e))
        .where((pago) => 
            pago.tipoPago != 'factura' && 
            pago.tipoPago != 'caja_chica' && 
            pago.visualizacion == 'activo')
        .toList();
  }
  return [];
}

// Función modificada para incluir AMBOS tipos de facturas
Future<List<Pago>> fetchFacturasFromAPI() async {
  final response = await http.get(Uri.parse('http://localhost:3000/pagos'));
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data
          .map((e) => Pago.fromMap(e))
          .where((pago) => 
              (pago.tipoPago == 'factura' || pago.tipoPago == 'caja_chica') && 
              pago.visualizacion == 'activo')
          .toList();
    }
    return [];
}

// Función específica solo para facturas normales
Future<List<Pago>> fetchFacturasNormalesFromAPI() async {
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

// Función específica solo para facturas de caja chica
Future<List<Pago>> fetchFacturasCajaChicaFromAPI() async {
  final response = await http.get(Uri.parse('http://localhost:3000/pagos'));
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data
          .map((e) => Pago.fromMap(e))
          .where((pago) => pago.tipoPago == 'caja_chica' && pago.visualizacion == 'activo')
          .toList();
    }
    return [];
}
