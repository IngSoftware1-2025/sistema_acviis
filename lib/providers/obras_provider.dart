import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/obra.dart';
import 'package:sistema_acviis/backend/controllers/obras/get_obras.dart';
import 'package:sistema_acviis/backend/controllers/obras/create_charla.dart';

class ObrasProvider extends ChangeNotifier {
  List<Obra> _todasLasObras = []; // Almacena todas las obras sin filtrar
  List<Obra> _obras = []; // Almacena las obras filtradas (o todas si no hay filtro)
  List<Obra> get obras => _obras; 

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchObras() async {
    // Usamos addPostFrameCallback para evitar errores de rebuild durante un build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isLoading = true;
      notifyListeners();
    });
    
    try {
      final data = await fetchObrasFromApi();
      _todasLasObras = data;
      _obras = List.from(_todasLasObras); // Inicialmente, la lista filtrada es igual a la completa
    } catch (e) {
      print('Error en ObrasProvider: $e');
      _todasLasObras = [];
      _obras = [];
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _isLoading = false;
        notifyListeners();
      });
    }
  }

  Future<bool> programarCharla({
    required String obraId,
    required DateTime fechaProgramada,
    String? tipoProgramacion,
    int? intervaloDias,
  }) async {
    try {
      final success = await createCharla(
        obraId: obraId,
        fechaProgramada: fechaProgramada,
        tipoProgramacion: tipoProgramacion,
        intervaloDias: intervaloDias,
      );
      if (success) await fetchObras(); // Recargar la lista si fue exitoso
      return success;
    } catch (e) {
      print('Error en ObrasProvider al programar charla: $e');
      return false;
    }
  }
}
