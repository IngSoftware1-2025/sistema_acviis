import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/proveedor.dart';
import 'package:sistema_acviis/backend/controllers/proveedores/get_proveedores.dart';
import 'package:sistema_acviis/backend/controllers/proveedores/update_proveedor.dart';
import 'package:sistema_acviis/backend/controllers/proveedores/delete_proveedor.dart';
import 'package:sistema_acviis/backend/controllers/proveedores/create_proveedor.dart';
import 'package:sistema_acviis/backend/controllers/proveedores/actualizar_estado_proveedor.dart';

class ProveedoresProvider extends ChangeNotifier {
  List<Proveedor> _todos = [];
  List<Proveedor> _proveedores = [];
  List<Proveedor> get proveedores => _proveedores;

  // Filtros
  String? rut;
  String? nombreVendedor;
  String? productoServicio;
  int? creditoMin;
  int? creditoMax;

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
  }) {
    this.rut = rut;
    this.nombreVendedor = nombre;
    this.productoServicio = productoServicio;
    this.creditoMin = creditoMin;
    this.creditoMax = creditoMax;
    filtrar();
    notifyListeners();
  }

  void filtrar() {
    _proveedores = _todos.where((p) {
      final estadoOk = p.estado == null || p.estado == 'activo';
      final rutOk = rut == null || rut!.isEmpty || p.rut.contains(rut!);
      final nombreOk = nombreVendedor == null || nombreVendedor!.isEmpty || p.nombreVendedor.toLowerCase().contains(nombreVendedor!.toLowerCase());
      final productoOk = productoServicio == null || productoServicio!.isEmpty || p.productoServicio.toLowerCase().contains(productoServicio!.toLowerCase());
      final creditoMinOk = creditoMin == null || p.creditoDisponible >= creditoMin!;
      final creditoMaxOk = creditoMax == null || p.creditoDisponible <= creditoMax!;
      return estadoOk && rutOk && nombreOk && productoOk && creditoMinOk && creditoMaxOk;
    }).toList();
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
    final exito = await actualizarEstadoProveedor(id, 'inactivo');
    if (exito) await fetchProveedores();
    return exito;
  }

  Future<void> eliminarPorFiltro() async {
    for (final proveedor in _proveedores) {
      await eliminarProveedor(proveedor.id);
    }
    await fetchProveedores();
  }
}