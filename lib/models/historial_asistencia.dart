class HistorialAsistencia {
  final String id;
  final String idExcel;
  final String obraId;
  final DateTime fechaSubida;

  const HistorialAsistencia({
    required this.id,
    required this.idExcel,
    required this.obraId,
    required this.fechaSubida,
  });

  factory HistorialAsistencia.fromMap(Map<String, dynamic> m) {
    return HistorialAsistencia(
      id: m['id'] as String,
      idExcel: m['id_excel'] as String? ?? m['idExcel'] as String? ?? '',
      obraId: m['obraId'] as String? ?? m['obra_id'] as String? ?? '',
      fechaSubida: m['fecha_subida'] != null
          ? DateTime.parse(m['fecha_subida'] as String)
          : (m['fechaSubida'] is DateTime ? m['fechaSubida'] as DateTime : DateTime.now()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_excel': idExcel,
      'obraId': obraId,
      'fecha_subida': fechaSubida.toIso8601String(),
    };
  }

  String toJson() => toMap().toString();

  HistorialAsistencia copyWith({
    String? id,
    String? idExcel,
    String? obraId,
    DateTime? fechaSubida,
  }) {
    return HistorialAsistencia(
      id: id ?? this.id,
      idExcel: idExcel ?? this.idExcel,
      obraId: obraId ?? this.obraId,
      fechaSubida: fechaSubida ?? this.fechaSubida,
    );
  }

  @override
  String toString() {
    return 'HistorialAsistencia(id: $id, idExcel: $idExcel, obraId: $obraId, fechaSubida: $fechaSubida)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HistorialAsistencia &&
        other.id == id &&
        other.idExcel == idExcel &&
        other.obraId == obraId &&
        other.fechaSubida == fechaSubida;
  }

  @override
  int get hashCode => Object.hash(id, idExcel, obraId, fechaSubida);
}