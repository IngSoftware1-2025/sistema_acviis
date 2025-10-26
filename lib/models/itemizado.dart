class Itemizado {
  final String id;
  final String nombre;
  final int cantidad;
  final int montoTotal;
  final int montoDisponible;

  Itemizado({
    required this.id,
    required this.nombre,
    required this.cantidad,
    required this.montoTotal,
    required this.montoDisponible,
  });

  factory Itemizado.fromJson(Map<String, dynamic> json) {
    return Itemizado(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      cantidad: json['cantidad'] ?? 0,
      montoTotal: json['monto_total'] ?? 0,
      montoDisponible: json['monto_disponible'] ?? 0,
    );
  }
}
