class Herramienta {
  final String id;
  final String tipo;
  final String estado;
  final DateTime? garantia;
  final int cantidadTotal;
  final int? cantidadDisponible;

  Herramienta({
    required this.id,
    required this.tipo,
    required this.estado,
    this.garantia,
    required this.cantidadTotal,
    this.cantidadDisponible,
  });

  factory Herramienta.fromJson(Map<String, dynamic> json) {
    return Herramienta(
      id: json['id'],
      tipo: json['tipo'],
      estado: json['estado'],
      garantia: json['garantia'] != null ? DateTime.parse(json['garantia']) : null,
      cantidadTotal: json['cantidad_total'],
      cantidadDisponible: json['cantidad_disponible'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo,
      'estado': estado,
      'garantia': garantia?.toIso8601String(),
      'cantidad_total': cantidadTotal,
      'cantidad_disponible': cantidadDisponible,
    };
  }
}