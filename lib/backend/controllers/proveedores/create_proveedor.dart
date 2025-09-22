import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sistema_acviis/models/proveedor.dart';

Future<bool> createProveedor(Map<String, dynamic> proveedor) async {
  final supabase = Supabase.instance.client;
  final response = await supabase.from('proveedores').insert([proveedor]);
  return response.error == null;
}