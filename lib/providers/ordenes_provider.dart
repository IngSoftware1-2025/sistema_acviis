import 'package:flutter/material.dart';
import 'package:sistema_acviis/backend/controllers/ordenes/get_ordenes.dart';
import 'package:sistema_acviis/backend/controllers/ordenes/update_ordenes.dart';
import 'package:sistema_acviis/backend/controllers/ordenes/update_estado_ordenes.dart';
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

  String? numeroOrden;
  String? centroCosto;
  String? seccionItemizado;
  String? direccion;
  String? servicioOfrecido;
  int? valorDesde;
  int? valorHasta;
  bool? descuento;

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

  // ──────────────── ELIMINAR (Dar de baja) ────────────────
  Future<void> darDeBaja(List<String> ids) async {
    await darDeBajaOrdenes(ids);
    await fetchOrdenes();
  }

  // ──────────────── ACTUALIZAR ────────────────
  Future<bool> actualizarOrden(String id, Map<String, dynamic> data) async {
    final exito = await updateOrden(id, data);
    if (exito) await fetchOrdenes();
    return exito;
  }

  // ──────────────── FILTROS ────────────────
  void actualizarFiltros({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    String? proveedorId,
    String? textoBusqueda,
    String? numeroOrden,
    String? centroCosto,
    String? seccionItemizado,
    String? direccion,
    String? servicioOfrecido,
    int? valorDesde,
    int? valorHasta,
    bool? descuento,
  }) {
    this.fechaDesde = fechaDesde ?? this.fechaDesde;
    this.fechaHasta = fechaHasta ?? this.fechaHasta;
    this.proveedorId = proveedorId ?? this.proveedorId;
    this.textoBusqueda = textoBusqueda ?? this.textoBusqueda;

    this.numeroOrden = numeroOrden ?? this.numeroOrden;
    this.centroCosto = centroCosto ?? this.centroCosto;
    this.seccionItemizado = seccionItemizado ?? this.seccionItemizado;
    this.direccion = direccion ?? this.direccion;
    this.servicioOfrecido = servicioOfrecido ?? this.servicioOfrecido;
    this.valorDesde = valorDesde ?? this.valorDesde;
    this.valorHasta = valorHasta ?? this.valorHasta;
    this.descuento = descuento ?? this.descuento;

    filtrar();
  }

  void filtrar() {
    _ordenes = _todos.where((o) {
      if (fechaDesde != null && o.fechaEmision.isBefore(fechaDesde!)) return false;
      if (fechaHasta != null && o.fechaEmision.isAfter(fechaHasta!)) return false;
      if (proveedorId != null && proveedorId!.isNotEmpty && o.proveedorId != proveedorId) return false;

      if (numeroOrden != null && numeroOrden!.isNotEmpty && !o.numeroOrden.contains(numeroOrden!)) return false;
      if (centroCosto != null && centroCosto!.isNotEmpty && !o.centroCosto.contains(centroCosto!)) return false;
      if (seccionItemizado != null && seccionItemizado!.isNotEmpty &&
      !o.itemizado.nombre.contains(seccionItemizado!)) return false;
      if (direccion != null && direccion!.isNotEmpty &&
          !o.proveedor.nombre_vendedor.contains(direccion!)) return false;
      if (servicioOfrecido != null && servicioOfrecido!.isNotEmpty &&
          !o.nombreServicio.contains(servicioOfrecido!)) return false;
      if (valorDesde != null && o.valor < valorDesde!) return false;
      if (valorHasta != null && o.valor > valorHasta!) return false;
      if (descuento != null && o.descuento != descuento) return false;

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

    numeroOrden = null;
    centroCosto = null;
    seccionItemizado = null;
    direccion = null;
    servicioOfrecido = null;
    valorDesde = null;
    valorHasta = null;
    descuento = null;

    filtrar();
  }
}