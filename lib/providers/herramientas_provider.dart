import 'package:flutter/material.dart';
import 'package:sistema_acviis/backend/controllers/herramientas/actualizar_estado_herramientas.dart';
import 'package:sistema_acviis/backend/controllers/herramientas/get_herramientas.dart';
import 'package:sistema_acviis/models/herramienta.dart';

class HerramientasProvider extends ChangeNotifier {
  List<Herramienta> _todas = [];
  List<Herramienta> _herramientas = [];
  List<Herramienta> get herramientas => _herramientas;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Filtros
  String? tipo;
  String? estado; // "Activa" o "De baja"
  DateTime? garantiaDesde;
  DateTime? garantiaHasta;
  String? obraAsig;
  RangeValues? rangoCantidad; // rango de cantidad disponible
  String? textoBusqueda;

  Future<void> fetchHerramientas() async {
    if (_todas.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }
    try {
      final nuevas = await fetchHerramientasFromApi();

      if (_todas.isEmpty) {
        _todas = nuevas;
      } else {
        for (var nueva in nuevas) {
          final index = _todas.indexWhere((h) => h.id == nueva.id);
          if (index != -1) {
            _todas[index] = nueva;
          } else {
            _todas.add(nueva);
          }
        }
      }

      _herramientas = List.from(_todas);
    } catch (e) {
      _herramientas = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> darDeBaja(List<String> ids) async {
    await darDeBajaHerramientas(ids);
    await fetchHerramientas();
  }

  void actualizarFiltros({
    String? tipo,
    String? estado,
    DateTime? garantiaDesde,
    DateTime? garantiaHasta,
    String? obraAsig,
    RangeValues? rangoCantidad,
  }) {
    this.tipo = tipo ?? this.tipo;
    this.estado = estado ?? this.estado;
    this.garantiaDesde = garantiaDesde ?? this.garantiaDesde;
    this.garantiaHasta = garantiaHasta ?? this.garantiaHasta;
    this.obraAsig = obraAsig ?? this.obraAsig;
    this.rangoCantidad = rangoCantidad ?? this.rangoCantidad;
    filtrar();
  }

  void actualizarBusqueda(String? texto) {
    textoBusqueda = texto;
    filtrar();
  }

  void filtrar() {
    _herramientas = _todas.where((h) {
      if (tipo != null && tipo!.isNotEmpty && h.tipo != tipo) return false;

      if (estado != null && estado!.isNotEmpty && h.estado != estado) return false;

      if (garantiaDesde != null && h.garantia != null && h.garantia!.isBefore(garantiaDesde!)) {
        return false;
      }
      if (garantiaHasta != null && h.garantia != null && h.garantia!.isAfter(garantiaHasta!)) {
        return false;
      }

      if (obraAsig != null && obraAsig!.isNotEmpty && h.obraAsig != obraAsig) return false;

      if (rangoCantidad != null) {
        if (h.cantidad < rangoCantidad!.start || h.cantidad > rangoCantidad!.end) return false;
      }

      if (textoBusqueda != null && textoBusqueda!.isNotEmpty) {
        final texto = textoBusqueda!.toLowerCase();
        if (!h.tipo.toLowerCase().contains(texto) &&
            !(h.obraAsig?.toLowerCase().contains(texto) ?? false)) {
          return false;
        }
      }

      return true;
    }).toList();

    notifyListeners();
  }

  void reiniciarFiltros() {
    tipo = null;
    estado = null;
    garantiaDesde = null;
    garantiaHasta = null;
    obraAsig = null;
    rangoCantidad = null;
    textoBusqueda = null;
    filtrar();
  }
}
