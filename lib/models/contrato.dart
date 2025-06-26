class Contrato {
  final String id;
  final String idTrabajadores;
  final String plazoDeContrato;
  final String estado;
  final DateTime fechaDeContratacion;

  Contrato({
    required this.id,
    required this.idTrabajadores,
    required this.plazoDeContrato,
    required this.estado,
    required this.fechaDeContratacion,
  });

  factory Contrato.fromMap(Map<String, dynamic> map) {
    final fechaStr = map['fecha_de_contratacion'];
    return Contrato(
      id: map['id'] ?? '',
      idTrabajadores: map['id_trabajadores'] ?? '',
      plazoDeContrato: map['plazo_de_contrato'] ?? '',
      estado: map['estado'] ?? '',
      fechaDeContratacion: (fechaStr != null && fechaStr.toString().isNotEmpty)
          ? DateTime.parse(fechaStr)
          : DateTime.now(),
    );
  }
  factory Contrato.fromJson(Map<String, dynamic> json) => Contrato.fromMap(json);
  Map<String, dynamic> toMap() {
  return {
    'id': id,
    'id_trabajadores': idTrabajadores,
    'plazo_de_contrato': plazoDeContrato,
    'estado': estado,
    'fecha_de_contratacion': fechaDeContratacion.toIso8601String(),
  };
}
}