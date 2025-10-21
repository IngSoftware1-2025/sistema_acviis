import 'package:flutter/foundation.dart';
import 'package:sistema_acviis/backend/controllers/obra_finanzas/obtener_finanzas_obra.dart';
import 'package:sistema_acviis/backend/controllers/obra_finanzas/crear_caja_chica.dart' as backend_crear;
import 'package:sistema_acviis/backend/controllers/obra_finanzas/cerrar_caja_chica.dart' as backend_cerrar;
import 'package:sistema_acviis/backend/controllers/obra_finanzas/modificar_caja_chica.dart' as backend_modificar;
import 'package:sistema_acviis/models/obra_finanza.dart';

class FinanzasObraProvider with ChangeNotifier {
  List<ObraFinanza> _finanzas = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ObraFinanza> get finanzas => _finanzas;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filtrar finanzas por tipo
  List<ObraFinanza> getFinanzasPorTipo(String tipo) {
    return _finanzas.where((finanza) => finanza.tipo == tipo).toList();
  }
  
  // Obtener cajas chicas activas
  List<ObraFinanza> get cajasChicasActivas {
    return _finanzas.where((f) => 
      f.tipo == 'caja chica' && f.estado == 'activa'
    ).toList();
  }

  // Cargar finanzas de una obra
  Future<void> cargarFinanzasObra(String obraId, {String? tipo, bool forceRefresh = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _finanzas = await obtenerFinanzasObra(
        obraId: obraId,
        tipo: tipo,
      );
      
      print('[FinanzasObraProvider] Finanzas cargadas: ${_finanzas.length}');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('[FinanzasObraProvider] Error al cargar finanzas: $e');
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Crear nueva caja chica
  Future<void> crearCajaChica({
    required String obraId,
    required String proposito,
    required double montoTotalAsignado,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final nuevaCajaChica = await backend_crear.crearCajaChica(
        obraId: obraId,
        proposito: proposito,
        montoTotalAsignado: montoTotalAsignado,
      );

      _finanzas = [..._finanzas, nuevaCajaChica];
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Modificar caja chica existente
  Future<void> modificarCajaChica({
    required String id,
    required double montoTotalAsignado,
    required double montoTotalUtilizado,
    required double montoUtilizadoImpago,
    required double montoUtilizadoResuelto,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final cajaActualizada = await backend_modificar.modificarCajaChica(
        id,
        montoTotalAsignado: montoTotalAsignado,
        montoTotalUtilizado: montoTotalUtilizado,
        montoUtilizadoImpago: montoUtilizadoImpago,
        montoUtilizadoResuelto: montoUtilizadoResuelto,
      );

      final index = _finanzas.indexWhere((f) => f.id == id);
      if (index != -1) {
        _finanzas = [
          ..._finanzas.sublist(0, index),
          cajaActualizada,
          ..._finanzas.sublist(index + 1),
        ];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Cerrar caja chica
  Future<void> cerrarCajaChica(String id, {String? observaciones}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final cajaActualizada = await backend_cerrar.cerrarCajaChica(
        id,
        observaciones: observaciones,
      );

      final index = _finanzas.indexWhere((f) => f.id == id);
      if (index != -1) {
        _finanzas = [
          ..._finanzas.sublist(0, index),
          cajaActualizada,
          ..._finanzas.sublist(index + 1),
        ];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Limpiar caché
  Future<void> limpiarCacheFinanzasDisponibles() async {
    // Si tienes caché, límpialo aquí
  }

  void clear() {
    _finanzas = [];
    _error = null;
    notifyListeners();
  }
}