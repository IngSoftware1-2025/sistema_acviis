class Proveedor {
  final String id;
  final String rut; // “XXXXXXXX-X”
  final String direccion; // “región, ciudad, comuna, casa”
  final String nombreVendedor; // Nombre completo del vendedor asignado
  final String productoServicio; // Producto o servicio
  final String correoVendedor;
  final String telefonoVendedor;
  final int creditoDisponible; // en pesos chilenos
  final DateTime fechaRegistro;
  final String? estado; // <-- Agregado

  Proveedor({
    required this.id,
    required this.rut,
    required this.direccion,
    required this.nombreVendedor,
    required this.productoServicio,
    required this.correoVendedor,
    required this.telefonoVendedor,
    required this.creditoDisponible,
    required this.fechaRegistro,
    this.estado,
  });

  factory Proveedor.fromMap(Map<String, dynamic> map) {
    return Proveedor(
      id: map['id'],
      rut: map['rut'],
      direccion: map['direccion'],
      nombreVendedor: map['nombre_vendedor'],
      productoServicio: map['producto_servicio'],
      correoVendedor: map['correo_vendedor'],
      telefonoVendedor: map['telefono_vendedor'],
      creditoDisponible: map['credito_disponible'],
      fechaRegistro: DateTime.parse(map['fecha_registro']),
      estado: map['estado'], // <-- Agregado
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rut': rut,
      'direccion': direccion,
      'nombre_vendedor': nombreVendedor,
      'producto_servicio': productoServicio,
      'correo_vendedor': correoVendedor,
      'telefono_vendedor': telefonoVendedor,
      'credito_disponible': creditoDisponible,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'estado': estado, // <-- Agregado
    };
  }
}