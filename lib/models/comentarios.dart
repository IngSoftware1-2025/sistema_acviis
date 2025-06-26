class Comentario {
  final String? id; // Puede ser null si aún no se ha guardado en backend
  final String idTrabajador;
  final String comentario;
  final DateTime fecha;
  final String? idContrato;

  Comentario({
    this.id,
    required this.idTrabajador,
    required this.comentario,
    required this.fecha,
    this.idContrato,
  });

  factory Comentario.fromMap(Map<String, dynamic> map) {
    return Comentario(
      id: map['id'],
      idTrabajador: map['id_trabajadores'],
      comentario: map['comentario'],
      fecha: DateTime.parse(map['fecha']),
      idContrato: map['id_contrato'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'id_trabajadores': idTrabajador,
      'comentario': comentario,
      'fecha': fecha.toIso8601String(),
      if (idContrato != null) 'id_contrato': idContrato,
    };
  }
}