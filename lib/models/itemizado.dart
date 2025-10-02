class Itemizado {
  final String id;
  final String nombre;
  final int montoDisponible;

  Itemizado({
    required this.id,
    required this.nombre,
    required this.montoDisponible,
  });

  factory Itemizado.fromJson(Map<String, dynamic> json) {
    return Itemizado(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      montoDisponible: json['monto_disponible'] ?? 0,
    );
  }
}
