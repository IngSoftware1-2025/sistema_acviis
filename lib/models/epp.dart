import 'dart:convert';

class EPP {
  final int? id; // Puede ser null al crearlo
  final String tipo;
  final int cantidadTotal;
  final int? cantidadDisponible;
  final String? certificadoId; // ID de GridFS en MongoDB
  final DateTime? fechaRegistro;

  EPP({
    this.id,
    required this.tipo,
    required this.cantidadTotal,
    this.cantidadDisponible,
    this.certificadoId,
    this.fechaRegistro,
  });

  /// Convertir JSON → Objeto EPP
factory EPP.fromJson(Map<String, dynamic> json) {
  return EPP(
    id: json['id'],
    tipo: json['tipo'],
    cantidadTotal: json['cantidadTotal'] ?? json['cantidad_total'] ?? 0,
    cantidadDisponible: json['cantidadDisponible'] ?? json['cantidad_disponible'],
    certificadoId: json['certificadoId'] ?? json['certificado_id'],
    fechaRegistro: json['fechaRegistro'] != null
        ? DateTime.parse(json['fechaRegistro'])
        : (json['fecha_registro'] != null 
            ? DateTime.parse(json['fecha_registro'])
            : null),
  );
}

  /// Convertir Objeto EPP → JSON (para enviar al backend)
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "tipo": tipo,
      "cantidadTotal": cantidadTotal,
      "cantidad_total": cantidadTotal,
      "cantidadDisponible": cantidadDisponible,
      "cantidad_disponible": cantidadDisponible,
      "certificadoId": certificadoId,
      "certificado_id": certificadoId,
      "fechaRegistro": fechaRegistro?.toIso8601String(),
      "fecha_registro": fechaRegistro?.toIso8601String(),
    };
  }

  /// Convertir a JSON String (opcional)
  String toRawJson() => json.encode(toJson());

  /// Crear EPP desde JSON String (opcional)
  factory EPP.fromRawJson(String str) =>
      EPP.fromJson(json.decode(str));
}
