class ObraFinanza {
  final String id;
  final String tipo;
  final DateTime fechaAsignacion;
  final String proposito;
  final String estado;
  final Map<String, dynamic>? detalles;

  ObraFinanza({
    required this.id,
    required this.tipo,
    required this.fechaAsignacion,
    required this.proposito,
    required this.estado,
    this.detalles,
  });

  double get montoTotalAsignado => 
      detalles != null ? (detalles!['montoTotalAsignado'] ?? 0).toDouble() : 0;
  
  double get montoTotalUtilizado => 
      detalles != null ? (detalles!['montoTotalUtilizado'] ?? 0).toDouble() : 0;
  
  double get montoUtilizadoImpago => 
      detalles != null ? (detalles!['montoUtilizadoImpago'] ?? 0).toDouble() : 0;
  
  double get montoUtilizadoResuelto => 
      detalles != null ? (detalles!['montoUtilizadoResuelto'] ?? 0).toDouble() : 0;

  double get montoDisponible => montoTotalAsignado - montoTotalUtilizado;
  
  double get porcentajeUtilizado => 
      montoTotalAsignado > 0 ? (montoTotalUtilizado / montoTotalAsignado) * 100 : 0;

  factory ObraFinanza.fromJson(Map<String, dynamic> json) {
    // IMPORTANTE: El backend envía fecha_asignacion (snake_case)
    return ObraFinanza(
      id: json['id'],
      tipo: json['tipo'],
      fechaAsignacion: json['fecha_asignacion'] != null
          ? DateTime.parse(json['fecha_asignacion'])
          : (json['fechaAsignacion'] != null 
              ? DateTime.parse(json['fechaAsignacion'])
              : DateTime.now()),
      proposito: json['proposito'] ?? '',
      estado: json['estado'] ?? 'activa',
      detalles: json['detalles'] is Map<String, dynamic> 
          ? json['detalles'] 
          : (json['detalles'] != null ? Map<String, dynamic>.from(json['detalles']) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo,
      'fecha_asignacion': fechaAsignacion.toIso8601String(),
      'proposito': proposito,
      'estado': estado,
      'detalles': detalles,
    };
  }
}