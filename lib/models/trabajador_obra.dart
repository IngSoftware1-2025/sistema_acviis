import 'package:sistema_acviis/models/trabajador.dart';
import 'package:sistema_acviis/models/obra.dart';

class TrabajadorObra {
  final String id;
  final String? trabajadorId;
  final String? obraId;
  final DateTime? fechaAsignacion;
  final DateTime? fechaDesasignacion;
  final String? rolEnObra;
  final String? estado;
  final Trabajador? trabajador;
  final Obra? obra;

  TrabajadorObra({
    required this.id,
    this.trabajadorId,
    this.obraId,
    this.fechaAsignacion,
    this.fechaDesasignacion,
    this.rolEnObra,
    this.estado,
    this.trabajador,
    this.obra,
  });

  factory TrabajadorObra.fromJson(Map<String, dynamic> json) {
    return TrabajadorObra(
      id: json['id'],
      trabajadorId: json['trabajador_id'],
      obraId: json['obra_id'],
      fechaAsignacion: json['fecha_asignacion'] != null 
        ? DateTime.parse(json['fecha_asignacion']) 
        : null,
      fechaDesasignacion: json['fecha_desasignacion'] != null 
        ? DateTime.parse(json['fecha_desasignacion']) 
        : null,
      rolEnObra: json['rol_en_obra'],
      estado: json['estado'],
      trabajador: json['trabajadores'] != null 
        ? Trabajador.fromJson(json['trabajadores']) 
        : null,
      obra: json['obras'] != null 
        ? Obra.fromJson(json['obras']) 
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trabajador_id': trabajadorId,
      'obra_id': obraId,
      'fecha_asignacion': fechaAsignacion?.toIso8601String(),
      'fecha_desasignacion': fechaDesasignacion?.toIso8601String(),
      'rol_en_obra': rolEnObra,
      'estado': estado,
    };
  }
}