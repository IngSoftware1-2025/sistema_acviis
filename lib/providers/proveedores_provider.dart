import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/proveedor.dart';
import 'package:sistema_acviis/backend/controllers/proveedores/get_proveedores.dart';
import 'package:sistema_acviis/backend/controllers/proveedores/update_proveedor.dart';
import 'package:sistema_acviis/backend/controllers/proveedores/delete_proveedor.dart';
import 'package:sistema_acviis/backend/controllers/proveedores/create_proveedor.dart';

class ProveedoresProvider extends ChangeNotifier {
  List<Proveedor> _todos = [];
  List<Proveedor> _proveedores = [];
  List<Proveedor> get proveedores => _proveedores;

  // Filtros
  String? estado;
  String? textoBusqueda;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchProveedores() async {
    _isLoading = true;
    notifyListeners();
    try {
      _todos = await fetchProveedoresFromApi();
      filtrar();
    } catch (e) {
      print('Error al obtener proveedores: $e');
      _todos = [];
      _proveedores = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void actualizarFiltros({String? estado, String? textoBusqueda}) {
    this.estado = estado ?? this.estado;
    this.textoBusqueda = textoBusqueda ?? this.textoBusqueda;
    filtrar();
  }

  void filtrar() {
    _proveedores = _todos.where((p) {
      if (estado != null && estado!.isNotEmpty && p.estado != estado) return false;
      if (textoBusqueda != null && textoBusqueda!.isNotEmpty) {
        final query = textoBusqueda!.toLowerCase();
        if (!p.nombre.toLowerCase().contains(query) &&
            !p.rut.toLowerCase().contains(query) &&
            !p.correoElectronico.toLowerCase().contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();
    notifyListeners();
  }

  Future<bool> actualizarProveedor(String id, Map<String, dynamic> data) async {
    final exito = await updateProveedor(id, data);
    if (exito) await fetchProveedores();
    return exito;
  }

  Future<bool> eliminarProveedor(String id) async {
    // En vez de borrar, actualiza el estado a 'Inactivo'
    final exito = await actualizarProveedor(id, {'estado': 'Inactivo'});
    if (exito) await fetchProveedores();
    return exito;
  }

  Future<bool> agregarProveedor(Proveedor proveedor) async {
    final exito = await createProveedor(proveedor.toMap());
    if (exito) await fetchProveedores();
    return exito;
  }
}