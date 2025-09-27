class Proveedor {
  final String id;
  final String nombre_vendedor;
  final String rut;
  final String direccion;
  final String correo_electronico;
  final String telefono_vendedor;
  final String estado;
  final DateTime fechaRegistro;

  Proveedor({
    required this.id,
    required this.nombre_vendedor,
    required this.rut,
    required this.direccion,
    required this.correo_electronico,
    required this.telefono_vendedor,
    required this.estado,
    required this.fechaRegistro,
  });

  factory Proveedor.fromMap(Map<String, dynamic> map) {
    return Proveedor(
      id: map['id'] ?? '',
      nombre_vendedor: map['nombre_vendedor'] ?? '',
      rut: map['rut'] ?? '',
      direccion: map['direccion'] ?? '',
      correo_electronico: map['correo_electronico'] ?? '',
      telefono_vendedor: map['telefono_vendedor'] ?? '',
      estado: map['estado'] ?? '',
      fechaRegistro: DateTime.parse(map['fecha_registro'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre_vendedor': nombre_vendedor,
      'rut': rut,
      'direccion': direccion,
      'correo_electronico': correo_electronico,
      'telefono_vendedor': telefono_vendedor,
      'estado': estado,
      'fecha_registro': fechaRegistro.toIso8601String(),
    };
  }
}