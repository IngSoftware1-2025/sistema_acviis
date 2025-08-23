import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/contrato.dart';
import 'package:sistema_acviis/backend/controllers/contratos/get_contratos.dart';

class ContratosProvider extends ChangeNotifier {
  List<Contrato> _contratos = [];
  List<Contrato> get contratos => _contratos;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchContratos() async {
    _isLoading = true;
    notifyListeners();
    try {
      _contratos = await fetchContratosFromApi();
    } catch (e) {
      print('Error al obtener contratos: $e');
      _contratos = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}