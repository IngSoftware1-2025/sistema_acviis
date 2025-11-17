import 'dart:convert';

class PersonaAsistencia {
  final String nombre;
  final String cargo;
  final String rut;

  final List<String> fecha;
  final List<String> asistenciaDiaria;
  final List<String> asistenciaFinesSemana;
  final List<String> horasExtra;

  PersonaAsistencia({
    required this.nombre,
    required this.cargo,
    required this.rut,
    List<String>? fecha,
    List<String>? asistenciaDiaria,
    List<String>? asistenciaFinesSemana,
    List<String>? horasExtra,
  })  : fecha = fecha ?? [],
        asistenciaDiaria = asistenciaDiaria ?? [],
        asistenciaFinesSemana = asistenciaFinesSemana ?? [],
        horasExtra = horasExtra ?? [];

  factory PersonaAsistencia.fromMap(Map<String, dynamic> map) {
    return PersonaAsistencia(
      nombre: map['nombre']?.toString() ?? '',
      cargo: map['cargo']?.toString() ?? '',
      rut: map['rut']?.toString() ?? '',
      fecha: (map['fecha'] is List) ? List<String>.from(map['fecha']) : <String>[],
      asistenciaDiaria: (map['asistenciaDiaria'] is List) ? List<String>.from(map['asistenciaDiaria']) : <String>[],
      asistenciaFinesSemana: (map['asistenciaFinesSemana'] is List) ? List<String>.from(map['asistenciaFinesSemana']) : <String>[],
      horasExtra: (map['horasExtra'] is List) ? List<String>.from(map['horasExtra']) : <String>[],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'cargo': cargo,
      'rut': rut,
      'fecha': fecha,
      'asistenciaDiaria': asistenciaDiaria,
      'asistenciaFinesSemana': asistenciaFinesSemana,
      'horasExtra': horasExtra,
    };
  }

  factory PersonaAsistencia.fromJson(String source) => PersonaAsistencia.fromMap(json.decode(source) as Map<String, dynamic>);
  String toJson() => json.encode(toMap());

  PersonaAsistencia copyWith({
    String? nombre,
    String? cargo,
    String? rut,
    List<String>? fecha,
    List<String>? asistenciaDiaria,
    List<String>? asistenciaFinesSemana,
    List<String>? horasExtra,
  }) {
    return PersonaAsistencia(
      nombre: nombre ?? this.nombre,
      cargo: cargo ?? this.cargo,
      rut: rut ?? this.rut,
      fecha: fecha ?? List<String>.from(this.fecha),
      asistenciaDiaria: asistenciaDiaria ?? List<String>.from(this.asistenciaDiaria),
      asistenciaFinesSemana: asistenciaFinesSemana ?? List<String>.from(this.asistenciaFinesSemana),
      horasExtra: horasExtra ?? List<String>.from(this.horasExtra),
    );
  }
}