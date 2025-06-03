class Trabajador {
  final String id;
  final String nombre;
  final String? apellido;
  final String email;
  final int? edad;
  final DateTime createdAt;
  final DateTime updatedAt;

  Trabajador({
    required this.id,
    required this.nombre,
    this.apellido,
    required this.email,
    this.edad,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Trabajador.fromJson(Map<String, dynamic> json) {
    return Trabajador(
      id: json['id'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      email: json['email'],
      edad: json['edad'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'edad': edad,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
