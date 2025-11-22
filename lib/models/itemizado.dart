class Itemizado {
  final String id;
  final String nombre;
  final int cantidad;
  final int montoTotal;
  final int montoDisponible;
  final int gastoActual;
  bool excesoNotificado;

  Itemizado({
    required this.id,
    required this.nombre,
    required this.cantidad,
    required this.montoTotal,
    required this.montoDisponible,
    required this.gastoActual,
    required this.excesoNotificado,
  });

  factory Itemizado.fromJson(Map<String, dynamic> json) {
    return Itemizado(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      cantidad: json['cantidad'] ?? 0,
      montoTotal: json['monto_total'] ?? 0,
      montoDisponible: json['monto_disponible'] ?? 0,
      gastoActual: json['gasto_actual'] ?? 0,
      excesoNotificado: json['exceso_notificado'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'cantidad': cantidad,
      'monto_total': montoTotal,
      'monto_disponible': montoDisponible,
      'gasto_actual': gastoActual,
      'exceso_notificado': excesoNotificado,
    };
  }
}
