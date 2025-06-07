import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/trabajador.dart';
import 'package:sistema_acviis/backend/controllers/trabajadores/get_trabajadores.dart';

class TrabajadoresProvider extends ChangeNotifier {
  List<Trabajador> _trabajadores = [];
  List<Trabajador> get trabajadores => _trabajadores;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchTrabajadores() async {
    _isLoading = true;
    notifyListeners();

    _trabajadores = await fetchTrabajadoresFromApi();

    _isLoading = false;
    notifyListeners();
  }
}