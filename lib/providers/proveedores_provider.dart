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

  // Carga proveedores desde API de forma segura
  Future<void> fetchProveedores() async {
    // Marcamos loading, pero post-frame para no romper build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isLoading = true;
      notifyListeners();
    });

    try {
      _todos = await fetchProveedoresFromApi();
      _filtrarPostFrame();
    } catch (e) {
      print('Error al obtener proveedores: $e');
      _todos = [];
      _proveedores = [];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _isLoading = false;
        notifyListeners();
      });
    }
  }

  // Precargar proveedores si aún no se han cargado
  Future<void> precargarProveedores() async {
    if (_todos.isEmpty) {
      await fetchProveedores();
    }
  }

  // Actualizar filtros y filtrar proveedores de forma segura
  void actualizarFiltros({String? estado, String? textoBusqueda}) {
    this.estado = estado ?? this.estado;
    this.textoBusqueda = textoBusqueda ?? this.textoBusqueda;
    _filtrarPostFrame();
  }

  // Filtrado seguro usando post-frame
  void _filtrarPostFrame() {
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
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
