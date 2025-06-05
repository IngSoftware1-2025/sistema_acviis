class Contrato {
  final int id;
  final String idTrabajadores;
  final String plazoDeContrato;
  final String estado;
  final String documentoDeVacacionesDelTrabajador;
  final String comentarioAdicionalAcercaDelTrabajador;
  final DateTime fechaDeContratacion;

  Contrato({
    required this.id,
    required this.idTrabajadores,
    required this.plazoDeContrato,
    required this.estado,
    required this.documentoDeVacacionesDelTrabajador,
    required this.comentarioAdicionalAcercaDelTrabajador,
    required this.fechaDeContratacion,
  });

  factory Contrato.fromJson(Map<String, dynamic> json) {
    return Contrato(
      id: json['id'],
      idTrabajadores: json['id_trabajadores'],
      plazoDeContrato: json['plazo_de_contrato'],
      estado: json['estado'],
      documentoDeVacacionesDelTrabajador: json['documento_de_vacaciones_del_trabajador'],
      comentarioAdicionalAcercaDelTrabajador: json['comentario_adicional_acerca_del_trabajador'],
      fechaDeContratacion: DateTime.parse(json['fecha_de_contratacion']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_trabajadores': idTrabajadores,
      'plazo_de_contrato': plazoDeContrato,
      'estado': estado,
      'documento_de_vacaciones_del_trabajador': documentoDeVacacionesDelTrabajador,
      'comentario_adicional_acerca_del_trabajador': comentarioAdicionalAcercaDelTrabajador,
      'fecha_de_contratacion': fechaDeContratacion.toIso8601String(),
    };
  }
}