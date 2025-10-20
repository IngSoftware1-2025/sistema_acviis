class ObraRecurso {
  final String id;
  final String tipo; // 'vehiculo', 'herramienta', 'epp'
  final DateTime fechaAsignacion;
  final DateTime? fechaRetiro;
  final int cantidad;
  final String? observaciones;
  final String estado;
  final Map<String, dynamic>? detalles;

  ObraRecurso({
    required this.id,
    required this.tipo,
    required this.fechaAsignacion,
    this.fechaRetiro,
    required this.cantidad,
    this.observaciones,
    required this.estado,
    this.detalles,
  });

  factory ObraRecurso.fromJson(Map<String, dynamic> json) {
    return ObraRecurso(
      id: json['id'],
      tipo: json['tipo'],
      fechaAsignacion: json['fechaAsignacion'] != null
          ? DateTime.parse(json['fechaAsignacion'])
          : DateTime.now(),
      fechaRetiro: json['fechaRetiro'] != null
          ? DateTime.parse(json['fechaRetiro'])
          : null,
      cantidad: json['cantidad'] ?? 1,
      observaciones: json['observaciones'],
      estado: json['estado'] ?? 'activo',
      detalles: json['detalles'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo,
      'fechaAsignacion': fechaAsignacion.toIso8601String(),
      'fechaRetiro': fechaRetiro?.toIso8601String(),
      'cantidad': cantidad,
      'observaciones': observaciones,
      'estado': estado,
      'detalles': detalles,
    };
  }

  // Método para obtener una descripción legible del recurso
  String get descripcion {
    if (detalles == null) return 'Recurso sin detalles';

    switch (tipo) {
      case 'vehiculo':
        return 'Vehículo: ${detalles!['patente']} (${detalles!['tipo']})';
      case 'herramienta':
        return 'Herramienta: ${detalles!['tipo']}';
      case 'epp':
        return 'EPP: ${detalles!['tipo']}';
      default:
        return 'Recurso desconocido';
    }
  }

  // Método para obtener el estado en formato legible
  String get estadoLegible {
    switch (estado) {
      case 'activo':
        return 'Asignado';
      case 'retirado':
        return 'Retirado';
      case 'dañado':
        return 'Dañado';
      default:
        return 'Desconocido';
    }
  }
}