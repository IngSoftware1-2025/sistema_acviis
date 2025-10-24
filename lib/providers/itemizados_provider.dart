import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/itemizado.dart';
import 'package:sistema_acviis/backend/controllers/itemizados/get_itemizados.dart';
import 'package:sistema_acviis/backend/controllers/itemizados/create_itemizado.dart';

class ItemizadosProvider extends ChangeNotifier {
  List<Itemizado> _itemizados = [];
  List<Itemizado> get itemizados => _itemizados;

  List<Itemizado> _itemizadosObra = [];
  List<Itemizado> get itemizadosObra => _itemizadosObra;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

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
  Future<void> precargarItemizados() async {
    if (_itemizados.isEmpty) {
      await fetchItemizados();
    }
  }
  
  Future<void> fetchItemizadosObra() async {
    _isLoading = true;
    notifyListeners();
    try {
      _itemizadosObra = await getItemizados();
    } catch (e) {
      print('Error al cargar otros pagos: $e');
      _itemizadosObra = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> crearItemizado(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      final payload = Map<String, dynamic>.from(data);
      if (payload.containsKey('valor_total') && !payload.containsKey('monto_disponible')) {
        payload['monto_disponible'] = payload.remove('valor_total');
      }
      payload.remove('id');
      await crearItemizadoMap(payload);
      await fetchItemizados();
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
