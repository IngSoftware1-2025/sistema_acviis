import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/pagos.dart';
import 'package:sistema_acviis/backend/controllers/finanzas/get_pagos.dart';
import 'package:sistema_acviis/backend/controllers/finanzas/actualizar_visualizacion_pago.dart';
import 'package:sistema_acviis/backend/controllers/finanzas/actualizar_pago.dart';
import 'package:sistema_acviis/backend/controllers/finanzas/subirPDF.dart';
import 'package:sistema_acviis/backend/controllers/finanzas/create_pago.dart';
import 'package:sistema_acviis/backend/controllers/finanzas/manejoPDF.dart';
import 'package:file_picker/file_picker.dart';

class PagosProvider extends ChangeNotifier {
  List<Pago> _facturas = [];
  List<Pago> get facturas => _facturas;

  List<Pago> _otrosPagos = [];
  List<Pago> get otrosPagos => _otrosPagos;

  List<Pago> facturasSeleccionadas = [];
  List<Pago> otrosPagosSeleccionados = [];

  Map<String, dynamic>? _filtrosFacturas;
  Map<String, dynamic>? get filtrosFacturas => _filtrosFacturas;

  List<Pago> _facturasFiltradas = [];
  List<Pago> get facturasFiltradas => _facturasFiltradas.isNotEmpty ? _facturasFiltradas : _facturas;

  bool _isLoadingFacturas = false;
  bool get isLoadingFacturas => _isLoadingFacturas;

  bool _isLoadingOtrosPagos = false;
  bool get isLoadingOtrosPagos => _isLoadingOtrosPagos;

  void aplicarFiltrosFacturas(Map<String, dynamic> filtros) {
    _filtrosFacturas = filtros;
    _aplicarFiltros();
    notifyListeners();
  }
  
  void limpiarFiltrosFacturas() {
    _filtrosFacturas = null;
    _facturasFiltradas = [];
    notifyListeners();
  }
  
  void _aplicarFiltros() {
    if (_filtrosFacturas == null || _filtrosFacturas!.isEmpty) {
      _facturasFiltradas = [];
      return;
    }
    
    _facturasFiltradas = _facturas.where((factura) {
      // Filtro por servicio ofrecido
      if (_filtrosFacturas!.containsKey('servicio')) {
        final servicioBusqueda = _filtrosFacturas!['servicio'] as String;
        if (!factura.servicioOfrecido.toLowerCase().contains(servicioBusqueda.toLowerCase())) {
          return false;
        }
      }
      
      // Filtro por valor mínimo
      if (_filtrosFacturas!.containsKey('valorMin')) {
        final valorMin = _filtrosFacturas!['valorMin'] as double;
        if (factura.valor < valorMin) {
          return false;
        }
      }
      
      // Filtro por valor máximo
      if (_filtrosFacturas!.containsKey('valorMax')) {
        final valorMax = _filtrosFacturas!['valorMax'] as double;
        if (factura.valor > valorMax) {
          return false;
        }
      }
      
      // Filtro por fecha desde
      if (_filtrosFacturas!.containsKey('fechaDesde')) {
        final fechaDesde = _filtrosFacturas!['fechaDesde'] as DateTime;
        if (factura.plazoPagar.isBefore(fechaDesde)) {
          return false;
        }
      }
      
      // Filtro por fecha hasta
      if (_filtrosFacturas!.containsKey('fechaHasta')) {
        final fechaHasta = _filtrosFacturas!['fechaHasta'] as DateTime;
        if (factura.plazoPagar.isAfter(fechaHasta)) {
          return false;
        }
      }
      
      // Filtro por estado de pago
      if (_filtrosFacturas!.containsKey('estadoPago')) {
        final estadoPago = _filtrosFacturas!['estadoPago'] as String;
        if (factura.estadoPago != estadoPago) {
          return false;
        }
      }
      
      // NUEVO: Filtro por tipo de factura
      if (_filtrosFacturas!.containsKey('tipoFactura')) {
        final tipoFactura = _filtrosFacturas!['tipoFactura'] as String;
        if (factura.tipoPago != tipoFactura) {
          return false;
        }
      }
      
      return true;
    }).toList();
  }
  
  // Actualizar el método fetchFacturas para aplicar filtros después de cargar
  Future<void> fetchFacturas() async {
    _isLoadingFacturas = true;
    notifyListeners();
    try {
      // Ahora incluye facturas normales Y de caja chica
      _facturas = await fetchFacturasFromAPI();
      if (_filtrosFacturas != null) {
        _aplicarFiltros();
      }
    } catch (e) {
      print('Error al cargar facturas: $e');
      _facturas = [];
    }
    _isLoadingFacturas = false;
    notifyListeners();
  }

  Future<void> fetchOtrosPagos() async {
    _isLoadingOtrosPagos = true;
    notifyListeners();
    try {
      _otrosPagos = await fetchOtrosPagosFromAPI();
    } catch (e) {
      print('Error al cargar otros pagos: $e');
      _otrosPagos = [];
    }
    _isLoadingOtrosPagos = false;
    notifyListeners();
  }

  void seleccionarFactura(Pago factura, bool seleccionada) {
    if (seleccionada) {
      if (!facturasSeleccionadas.contains(factura)) {
        facturasSeleccionadas.add(factura);
      }
    } else {
      facturasSeleccionadas.remove(factura);
    }
    notifyListeners();
  }

  void seleccionarOtroPago(Pago pago, bool seleccionada) {
    if (seleccionada) {
      if (!otrosPagosSeleccionados.contains(pago)) {
        otrosPagosSeleccionados.add(pago);
      }
    } else {
      otrosPagosSeleccionados.remove(pago);
    }
    notifyListeners();
  }

  Future<void> actualizarVisualizacion(String id, String visualizacion) async {
    await actualizarVisualizacionFromAPI(id, visualizacion);
  }

  Future<void> actualizarPagoFactura(String id, Map<String, dynamic> data) async {
    await actualizarPago(id, data);
    await fetchFacturas();
    notifyListeners();
  }

  Future<void> actualizarPagoPendientes(String id, Map<String, dynamic> data) async {
    await actualizarPago(id, data);
    await fetchOtrosPagos();
    notifyListeners();
  }

  Future<String?> subirPDF(PlatformFile archivoPdf, BuildContext context) async {
    return await subirPdfPago(archivoPdf, context);
  }

  Future<void> agregarPagosOtros(Pago pago) async {
    await crearPago(pago);
    await fetchOtrosPagos();
    notifyListeners();
  }

  Future<void> agregarPagosFacturas(Pago pago) async {
    await crearPago(pago);
    await fetchFacturas();
    notifyListeners();
  }

  // Descarga la ficha PDF con los datos
  Future<void> descargarFicha(BuildContext context, String facturaId, String codigo) async {
    await descargarFichaPDF(context, facturaId, codigo);
  }

  // Descarga el archivo PDF asociado a la factura o pago pendiente
  Future<void> descargarArchivoPDF(BuildContext context, String fotografiaId) async {
    await descargarYAbrirPdf(context, fotografiaId);
  }
}
