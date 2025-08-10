class Proveedor {
  final String id;
  final String nombre;
  final String rut;
  final String direccion;
  final String correoElectronico;
  final String telefono;
  final String estado;
  final DateTime fechaRegistro;

  Proveedor({
    required this.id,
    required this.nombre,
    required this.rut,
    required this.direccion,
    required this.correoElectronico,
    required this.telefono,
    required this.estado,
    required this.fechaRegistro,
  });

  factory Proveedor.fromMap(Map<String, dynamic> map) {
    return Proveedor(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      rut: map['rut'] ?? '',
      direccion: map['direccion'] ?? '',
      correoElectronico: map['correo_electronico'] ?? '',
      telefono: map['telefono'] ?? '',
      estado: map['estado'] ?? '',
      fechaRegistro: DateTime.parse(map['fecha_registro'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'rut': rut,
      'direccion': direccion,
      'correo_electronico': correoElectronico,
      'telefono': telefono,
      'estado': estado,
      'fecha_registro': fechaRegistro.toIso8601String(),
    };
  }
}