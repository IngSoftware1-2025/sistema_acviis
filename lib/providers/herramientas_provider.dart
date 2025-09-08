import 'package:flutter/material.dart';
import 'package:sistema_acviis/backend/controllers/herramientas/actualizar_estado_herramientas.dart';
import 'package:sistema_acviis/models/herramienta.dart';
import 'package:sistema_acviis/backend/controllers/herramientas/get_herramientas.dart';

class HerramientasProvider extends ChangeNotifier {
  List<Herramienta> _herramientas = [];
  List<Herramienta> get herramientas => _herramientas;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchHerramientas() async {
    _isLoading = true;
    notifyListeners();
    try {
      _herramientas = await fetchHerramientasFromApi();
    } catch (e) {
      // Manejo de error
      _herramientas = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> darDeBaja(List<String> ids) async {
    await darDeBajaHerramientas(ids); 
    // Recargar la lista completa después de dar de baja
    await fetchHerramientas(); 
  }

  // Filtros
  List<Herramienta> filterByTipo(String tipo) =>
      _herramientas.where((h) => h.tipo == tipo).toList();

  List<Herramienta> filterByEstado(String estado) =>
      _herramientas.where((h) => h.estado == estado).toList();

  List<Herramienta> filterByObraAsig(String obraAsig) =>
      _herramientas.where((h) => h.obraAsig == obraAsig).toList();

  List<Herramienta> filterByCantidad(int cantidad) =>
      _herramientas.where((h) => h.cantidad == cantidad).toList();

  List<Herramienta> filterByGarantia(DateTime fechaLimite) =>
      _herramientas.where((h) => h.garantia != null && h.garantia!.isBefore(fechaLimite)).toList();
}
