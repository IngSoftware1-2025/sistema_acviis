import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/pagos.dart';
import 'package:sistema_acviis/backend/controllers/finanzas/get_pagos.dart';
import 'package:sistema_acviis/backend/controllers/finanzas/actualizar_visualizacion_pago.dart';

class PagosProvider extends ChangeNotifier {
  List<Pago> _facturas = [];
  List<Pago> get facturas => _facturas;

  List<Pago> _otrosPagos = [];
  List<Pago> get otrosPagos => _otrosPagos;

  List<Pago> facturasSeleccionadas = [];
  List<Pago> otrosPagosSeleccionados = [];

  bool _isLoadingFacturas = false;
  bool get isLoadingFacturas => _isLoadingFacturas;

  bool _isLoadingOtrosPagos = false;
  bool get isLoadingOtrosPagos => _isLoadingOtrosPagos;

  Future<void> fetchFacturas() async {
    _isLoadingFacturas = true;
    notifyListeners();
    try {
      _facturas = await fetchFacturasFromAPI();
    } catch (e) {
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
    await fetchFacturas();
    await fetchOtrosPagos();
  }
}