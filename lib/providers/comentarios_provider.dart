import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/comentarios.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ComentariosProvider extends ChangeNotifier {
  List<Comentario> _comentarios = [];
  List<Comentario> get comentarios => _comentarios;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchComentarios() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('http://localhost:3000/comentarios'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _comentarios = data.map((e) => Comentario.fromMap(e)).toList();
      } else {
        _comentarios = [];
      }
    } catch (e) {
      _comentarios = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  void addComentario(Comentario comentario) {
    _comentarios.add(comentario);
    notifyListeners();
  }

  void clear() {
    _comentarios.clear();
    notifyListeners();
  }
}