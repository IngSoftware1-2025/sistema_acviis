import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/itemizado.dart';
import 'package:sistema_acviis/backend/controllers/itemizados/get_itemizados.dart';

class ItemizadosProvider extends ChangeNotifier {
  List<Itemizado> _itemizados = [];
  List<Itemizado> get itemizados => _itemizados;

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
}
