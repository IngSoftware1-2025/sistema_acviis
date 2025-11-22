import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/custom_checkbox.dart';

class CheckboxProvider extends ChangeNotifier {
  List<CustomCheckbox> _checkBoxes = [];

  void setCheckBoxes(int cantidad) {
    // El primero es el "select all" (-1), los demás uno por cada item
    if (_checkBoxes.isEmpty) {
      // Primera inicialización
      _checkBoxes = [CustomCheckbox(index: -1)];
      for (int i = 0; i < cantidad; i++) {
        _checkBoxes.add(CustomCheckbox(index: i));
      }
    } else {
      // Ajustar la lista preservando estados existentes
      int currentCount = _checkBoxes.length - 1; // -1 por el "select all"
      
      if (cantidad > currentCount) {
        // Agregar nuevos checkboxes
        for (int i = currentCount; i < cantidad; i++) {
          _checkBoxes.add(CustomCheckbox(index: i));
        }
      } else if (cantidad < currentCount) {
        // Remover checkboxes sobrantes (mantener el primero que es el "select all")
        _checkBoxes = [_checkBoxes[0]] + _checkBoxes.sublist(1, cantidad + 1);
      }
      // Si cantidad == currentCount, no hacer nada (preservar estados)
    }
    notifyListeners();
  }

  List<CustomCheckbox> get checkBoxes => _checkBoxes;

  void toggleCheckbox(int index) {
    if (index == -1) {
      // Seleccionar/deseleccionar todos
      bool selectAll = !_checkBoxes[0].isSelected;
      for (var cb in _checkBoxes) {
        cb.isSelected = selectAll;
      }
    } else {
      _checkBoxes[index + 1].isSelected = !_checkBoxes[index + 1].isSelected;
      // Actualiza el "select all"
      _checkBoxes[0].isSelected = _checkBoxes.skip(1).every((cb) => cb.isSelected);
    }
    notifyListeners();
  }
  void clearCheckboxes() {
    if (_checkBoxes.isEmpty) return;
    for (var cb in _checkBoxes) {
      cb.isSelected = false;
    }
    notifyListeners();
  }
}