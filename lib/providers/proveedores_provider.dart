import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/proveedor.dart';
import 'package:sistema_acviis/backend/controllers/proveedores/get_proveedores.dart';
import 'package:sistema_acviis/backend/controllers/proveedores/update_proveedor.dart';
import 'package:sistema_acviis/backend/controllers/proveedores/delete_proveedor.dart';

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

  // Precargar proveedores si aún no se han cargado
  Future<void> precargarProveedores() async {
    if (_todos.isEmpty) {
      await fetchProveedores();
    }
  }

  // Actualizar filtros
  void actualizarFiltros({String? estado, String? textoBusqueda}) {
    this.estado = estado ?? this.estado;
    this.textoBusqueda = textoBusqueda ?? this.textoBusqueda;
    filtrar();
  }

  // Filtrar proveedores según estado y búsqueda de texto
  void filtrar() {
    _proveedores = _todos.where((p) {
      if (estado != null && estado!.isNotEmpty && p.estado != estado) return false;
      if (textoBusqueda != null && textoBusqueda!.isNotEmpty) {
        final query = textoBusqueda!.toLowerCase();
        if (!p.nombre_vendedor.toLowerCase().contains(query) &&
            !p.rut.toLowerCase().contains(query) &&
            !p.correo_electronico.toLowerCase().contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();
    notifyListeners();
  }

  // Actualizar un proveedor
  Future<bool> actualizarProveedor(String id, Map<String, dynamic> data) async {
    final exito = await updateProveedor(id, data);
    if (exito) await fetchProveedores();
    return exito;
  }

  // Eliminar un proveedor
  Future<bool> eliminarProveedor(String id) async {
    final exito = await deleteProveedor(id);
    if (exito) await fetchProveedores();
    return exito;
  }
}
