class Herramienta {
  final String id;
  final String tipo;
  final String estado;
  final DateTime? garantia;
  final int cantidad;
  final String? obraAsig;
  final DateTime? asigInicio;
  final DateTime? asigFin;

  Herramienta({
    required this.id,
    required this.tipo,
    required this.estado,
    this.garantia,
    required this.cantidad,
    this.obraAsig,
    this.asigInicio,
    this.asigFin,
  });

  factory Herramienta.fromJson(Map<String, dynamic> json) {
    return Herramienta(
      id: json['id'],
      tipo: json['tipo'],
      estado: json['estado'],
      garantia: json['garantia'] != null ? DateTime.parse(json['garantia']) : null,
      cantidad: json['cantidad'],
      obraAsig: json['obra_asig'],
      asigInicio: json['asig_inicio'] != null ? DateTime.parse(json['asig_inicio']) : null,
      asigFin: json['asig_fin'] != null ? DateTime.parse(json['asig_fin']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo,
      'estado': estado,
      'garantia': garantia?.toIso8601String(),
      'cantidad': cantidad,
      'obra_asig': obraAsig,
      'asig_inicio': asigInicio?.toIso8601String(),
      'asig_fin': asigFin?.toIso8601String(),
    };
  }
}