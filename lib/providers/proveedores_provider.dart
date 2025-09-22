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
      final data = await fetchProveedoresFromApi();
      _todos = data;
      filtrar();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void actualizarFiltros({
    String? rut,
    String? nombre,
    String? productoServicio,
    int? creditoMin,
    int? creditoMax,
    String? textoBusqueda,
  }) {
    // Guarda los filtros en variables
    // ...
    filtrar();
    notifyListeners();
  }

  void filtrar() {
    // Filtra _todos según los filtros activos
    // ...
    notifyListeners();
  }

  Future<bool> agregarProveedor(Proveedor proveedor) async {
    final exito = await createProveedor(proveedor.toMap());
    if (exito) await fetchProveedores();
    return exito;
  }

  Future<bool> actualizarProveedor(String id, Map<String, dynamic> data) async {
    final exito = await updateProveedor(id, data);
    if (exito) await fetchProveedores();
    return exito;
  }

  Future<bool> eliminarProveedor(String id) async {
    final exito = await deleteProveedor(id);
    if (exito) await fetchProveedores();
    return exito;
  }

// este método permite que se eliminen todos los proveedores que cumplan con el filtro actual
  Future<void> eliminarPorFiltro() async {
    for (final proveedor in _proveedores) {
      await eliminarProveedor(proveedor.id);
    }
    await fetchProveedores();
  }
}