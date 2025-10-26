import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/itemizado.dart';
import 'package:sistema_acviis/backend/controllers/itemizados/get_itemizados.dart';
import 'package:sistema_acviis/backend/controllers/itemizados/create_itemizados.dart';

class ItemizadosProvider extends ChangeNotifier {
  List<Itemizado> _itemizados = [];
  List<Itemizado> get itemizados => _itemizados;

  List<Itemizado> _itemizadosObra = [];
  List<Itemizado> get itemizadosObra => _itemizadosObra;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// ================== TRAER TODOS LOS ITEMIZADOS ==================
  Future<void> fetchItemizados() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isLoading = true;
      notifyListeners();
    });
    try {
      final data = await getItemizados(); 
      _itemizados = data;
      _error = null;
    } catch (e) {
      _itemizados = [];
      _error = e.toString();
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _isLoading = false;
        notifyListeners();
      });
    }
  }

  /// ================== TRAER ITEMIZADOS POR OBRA ==================
  Future<void> fetchItemizadosPorObra(String obraId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await getItemizadosPorObra(obraId); 
      _itemizados = data;
      _error = null;
    } catch (e) {
      _itemizados = [];
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ========== CREAR NUEVO ITEMIZADO ==========
  Future<bool> addItemizado({
    required String nombre,
    String? descripcion,
    required int cantidad,
    required int montoTotal,
    required String obraId,
  }) async {
    try {
      final resp = await createItemizado(
        nombre: nombre,
        descripcion: descripcion,
        cantidad: cantidad,
        montoTotal: montoTotal,
        obraId: obraId,
      );

      if (resp['success'] == true) {
        await fetchItemizadosPorObra(obraId);
        return true;
      } else {
        _error = resp['error'];
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  /// ================== PRECARGAR ==================
  Future<void> precargarItemizados() async {
    if (_itemizados.isEmpty) {
      await fetchItemizados(); 
    }
  }
}
