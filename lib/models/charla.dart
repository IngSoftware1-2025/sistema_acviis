import 'package:sistema_acviis/models/asistencia_charla.dart';

class Charla {
  final String id;
  final String obraId;
  final DateTime fechaProgramada;
  final String estado;
  final bool recordatorioEnviado;
  final List<AsistenciaCharla> asistencias;

  Charla({
    required this.id,
    required this.obraId,
    required this.fechaProgramada,
    required this.estado,
    required this.recordatorioEnviado,
    required this.asistencias,
  });

  factory Charla.fromJson(Map<String, dynamic> json) {
    return Charla(
      id: json['id'],
      obraId: json['obra_id'],
      fechaProgramada: DateTime.parse(json['fecha_programada']),
      estado: json['estado'],
      recordatorioEnviado: json['recordatorio_enviado'],
      asistencias: (json['asistencias_charlas'] as List<dynamic>?)
              ?.map((asistenciaJson) => AsistenciaCharla.fromJson(asistenciaJson))
              .toList() ??
          [],
    );
  }
}
