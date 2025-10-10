import 'dart:convert';
import 'package:sistema_acviis/models/charla.dart';

class Obra {
  final String id;
  final String nombre;
  final String? descripcion;
  final String? estado;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? responsableEmail;
  final List<Charla> charlas;

  Obra({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.estado,
    required this.createdAt,
    required this.updatedAt,
    this.responsableEmail,
    required this.charlas,
  });

  factory Obra.fromJson(Map<String, dynamic> json) {
    return Obra(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      estado: json['estado'],
      createdAt: DateTime.parse(json['createdat']),
      updatedAt: DateTime.parse(json['updatedat']),
      responsableEmail: json['responsable_email'],
      charlas: (json['charlas'] as List<dynamic>?)
              ?.map((charlaJson) => Charla.fromJson(charlaJson))
              .toList() ??
          [],
    );
  }

  static List<Obra> fromJsonList(String jsonString) {
    final data = json.decode(jsonString) as List<dynamic>;
    return data.map((item) => Obra.fromJson(item)).toList();
  }
}
