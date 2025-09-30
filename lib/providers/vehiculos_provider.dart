import 'package:flutter/material.dart';
import 'package:sistema_acviis/backend/controllers/vehiculos/actualizar_estado_vehiculos.dart';
import 'package:sistema_acviis/backend/controllers/vehiculos/get_vehiculos.dart';
import 'package:sistema_acviis/models/vehiculo.dart';

class VehiculosProvider extends ChangeNotifier{

  List<Vehiculo> _todos = [];
  List<Vehiculo> _vehiculos = [];
  List<Vehiculo> get vehiculos => _vehiculos;

  bool _isLoading = false;
  bool get isLoading => _isLoading;


  DateTime? tecnicaDesde;
  DateTime? tecnicaHasta;
  DateTime? gasesDesde;
  DateTime? gasesHasta;
  DateTime? mantencionDesde;
  DateTime? mantencionHasta;
  RangeValues? rangoCapacidad; // rango de capacidad en kg
  String? tipoNeumatico;
  String? estado; // "Activo" o "De baja"
  String? textoBusqueda;

  Future<void> fetchVehiculos() async {
    if (_todos.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }
    try {
      final nuevos = await fetchVehiculosFromApi();

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

      _vehiculos = List.from(_todos);
    } catch (e) {
      _vehiculos = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> darDeBaja(List<String> ids) async {
    await darDeBajaVehiculos(ids);
    await fetchVehiculos();
  }

  void actualizarFiltros({
  DateTime? tecnicaDesde,
  DateTime? tecnicaHasta,
  DateTime? gasesDesde,
  DateTime? gasesHasta,
  DateTime? mantencionDesde,
  DateTime? mantencionHasta,
  RangeValues? rangoCapacidad, 
  String? tipoNeumatico,
  String? estado,
  String? textoBusqueda,
  }) {
    this.tecnicaDesde = tecnicaDesde ?? this.tecnicaDesde;
    this.tecnicaHasta = tecnicaHasta ?? this.tecnicaHasta;
    this.gasesDesde = gasesDesde ?? this.gasesDesde;
    this.gasesHasta = gasesHasta ?? this.gasesHasta;
    this.mantencionDesde = mantencionDesde ?? this.mantencionDesde;
    this.mantencionHasta = mantencionHasta ?? this.mantencionHasta;
    this.rangoCapacidad = rangoCapacidad ?? this.rangoCapacidad;
    this.tipoNeumatico = tipoNeumatico ?? this.tipoNeumatico;
    this.estado = estado ?? this.estado;
    this.textoBusqueda = textoBusqueda ?? this.textoBusqueda;
    filtrar();
  }

  void actualizarBusqueda(String? texto) {
    textoBusqueda = texto;
    filtrar();
  }

  void filtrar() {
    _vehiculos = _todos.where((h) {
      if (tecnicaDesde != null && h.revisionTecnica.isBefore(tecnicaDesde!)) {
        return false;
      }
      if (tecnicaHasta != null && h.revisionTecnica.isAfter(tecnicaHasta!)) {
        return false;
      }
      if (gasesDesde != null && h.revisionGases.isBefore(gasesDesde!)) {
        return false;
      }
      if (gasesHasta != null && h.revisionGases.isAfter(gasesHasta!)) {
        return false;
      }
      if (mantencionDesde != null && h.ultimaMantencion.isBefore(mantencionDesde!)) {
        return false;
      }
      if (mantencionHasta != null && h.ultimaMantencion.isAfter(mantencionHasta!)) {
        return false;
      }
      if (rangoCapacidad != null) {
        if (h.capacidadKg < rangoCapacidad!.start || h.capacidadKg > rangoCapacidad!.end) return false;
      }
      if (tipoNeumatico != null && tipoNeumatico!.isNotEmpty && h.neumaticos != tipoNeumatico) return false;
      if (estado != null && estado!.isNotEmpty && h.estado != estado) return false;
      if (textoBusqueda != null && textoBusqueda!.isNotEmpty) {
        final texto = textoBusqueda!.toLowerCase();
        if (!h.patente.toLowerCase().contains(texto)) return false;
      }

      return true;
    }).toList();

    notifyListeners();
  }

  void reiniciarFiltros() {
    tecnicaDesde = null;
    tecnicaHasta = null;
    gasesDesde = null;
    gasesHasta = null;
    mantencionDesde = null;
    mantencionHasta = null;
    rangoCapacidad = null;
    tipoNeumatico = null;
    estado = null;
    textoBusqueda = null;
    filtrar();
  }
}