import 'dart:convert';
import 'package:sistema_acviis/models/charla.dart';

class Obra {
  final String id;
  final String nombre;
  final String? descripcion;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? responsableEmail;
  final String direccion;
  final DateTime? obraInicio;
  final DateTime? obraFin;
  final String? jornada;
  final List<Charla> charlas;

  Obra({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.createdAt,
    required this.updatedAt,
    this.responsableEmail,
    required this.direccion,
    this.obraInicio,
    this.obraFin,
    this.jornada,
    required this.charlas,
  });

  factory Obra.fromJson(Map<String, dynamic> json) {
    return Obra(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      createdAt: json['createdat'] != null ? DateTime.parse(json['createdat']) : null,
      updatedAt: json['updatedat'] != null ? DateTime.parse(json['updatedat']) : null,
      responsableEmail: json['responsable_email'],
      direccion: json['direccion'] ?? '',
      obraInicio: json['obraInicio'] != null ? DateTime.parse(json['obraInicio']) : null,
      obraFin: json['obraFin'] != null ? DateTime.parse(json['obraFin']) : null,
      jornada: json['jornada'],
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
