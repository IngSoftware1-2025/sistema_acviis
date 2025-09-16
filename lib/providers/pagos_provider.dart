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
  // ingresados de la factura o del pago pendiente
  Future<void> descargarFicha(BuildContext context, String facturaId, String codigo) async {
    await descargarFichaPDF(context, facturaId, codigo);
  }
  // Descarga el archivo PDF asociado a la factura o pago pendiente
  Future<void> descargarArchivoPDF(BuildContext context, String fotografiaId) async {
    await descargarYAbrirPdf(context, fotografiaId);
  }

  
}
