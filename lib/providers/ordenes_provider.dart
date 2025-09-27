import 'package:flutter/material.dart';
import 'package:sistema_acviis/backend/controllers/ordenes/delete_ordenes.dart';
import 'package:sistema_acviis/backend/controllers/ordenes/get_ordenes.dart';
import 'package:sistema_acviis/models/ordenes.dart';

class OrdenesProvider extends ChangeNotifier {
  List<OrdenCompra> _todos = [];
  List<OrdenCompra> _ordenes = [];
  List<OrdenCompra> get ordenes => _ordenes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Filtros
  DateTime? fechaDesde;
  DateTime? fechaHasta;
  String? proveedorId;
  String? textoBusqueda;


Future<void> fetchOrdenes() async {
    if (_todos.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }
    try {
      final nuevos = await fetchOrdenesFromApi();

      if (_todos.isEmpty) {
        _todos = nuevos;
      } else {
        for (var nuevo in nuevos) {
          final index = _todos.indexWhere((v) => v.id == nuevo.id);
          if (index != -1) {
            _todos[index] = nuevo;
          } else {
            _todos.add(nuevo);
          }
        }
      }

      _ordenes = List.from(_todos);
    } catch (e) {
      _ordenes = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  // ──────────────── ELIMINAR ────────────────
  Future<void> darDeBaja(List<String> ids) async {
    await darDeBajaOrdenes(ids);
    await fetchOrdenes();
  }


  // ──────────────── FILTROS ────────────────
  void actualizarFiltros({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    String? proveedorId,
    String? textoBusqueda,
  }) {
    this.fechaDesde = fechaDesde ?? this.fechaDesde;
    this.fechaHasta = fechaHasta ?? this.fechaHasta;
    this.proveedorId = proveedorId ?? this.proveedorId;
    this.textoBusqueda = textoBusqueda ?? this.textoBusqueda;
    filtrar();
  }

  void filtrar() {
    _ordenes = _todos.where((o) {
      if (fechaDesde != null && o.fechaEmision.isBefore(fechaDesde!)) return false;
      if (fechaHasta != null && o.fechaEmision.isAfter(fechaHasta!)) return false;
      if (proveedorId != null && proveedorId!.isNotEmpty && o.proveedorId != proveedorId) return false;
      if (textoBusqueda != null && textoBusqueda!.isNotEmpty) {
        final t = textoBusqueda!.toLowerCase();
        if (!o.numeroOrden.toLowerCase().contains(t) &&
            !o.nombreServicio.toLowerCase().contains(t)) return false;
      }
      return true;
    }).toList();
    notifyListeners();
  }

  void reiniciarFiltros() {
    fechaDesde = null;
    fechaHasta = null;
    proveedorId = null;
    textoBusqueda = null;
    filtrar();
  }
}
