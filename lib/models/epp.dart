import 'dart:convert';

class EPP {
  final int? id; // Puede ser null al crearlo
  final String tipo;
  final List<String> obrasAsignadas;
  final int cantidad;
  final String? certificadoId; // ID de GridFS en MongoDB
  final DateTime? fechaRegistro;

  EPP({
    this.id,
    required this.tipo,
    required this.obrasAsignadas,
    required this.cantidad,
    this.certificadoId,
    this.fechaRegistro,
  });

  /// Convertir JSON → Objeto EPP
factory EPP.fromJson(Map<String, dynamic> json) {
  return EPP(
    id: json['id'],
    tipo: json['tipo'],
    // ⚡ ASEGURAR QUE SIEMPRE SEA UN ARRAY:
    obrasAsignadas: json['obrasAsignadas'] != null 
      ? List<String>.from(json['obrasAsignadas']) 
      : [], // ← Array vacío si es null
    cantidad: json['cantidad'],
    certificadoId: json['certificadoId'],
    fechaRegistro: json['fechaRegistro'] != null
        ? DateTime.parse(json['fechaRegistro'])
        : null,
  );
}

  /// Convertir Objeto EPP → JSON (para enviar al backend)
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "tipo": tipo,
      "obrasAsignadas": obrasAsignadas,
      "cantidad": cantidad,
      "certificadoId": certificadoId,
      "fechaRegistro": fechaRegistro?.toIso8601String(),
    };
  }

  /// Convertir a JSON String (opcional)
  String toRawJson() => json.encode(toJson());

  /// Crear EPP desde JSON String (opcional)
  factory EPP.fromRawJson(String str) =>
      EPP.fromJson(json.decode(str));
}