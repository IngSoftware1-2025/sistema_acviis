
//Nuevo
class Trabajador {
  final String id;
  final String nombreCompleto;
  final String estadoCivil;
  final String rut;
  final DateTime fechaDeNacimiento;
  final String direccion;
  final String correoElectronico;
  final String sistemaDeSalud;
  final String previsionAfp;
  final String obraEnLaQueTrabaja;
  final String rolQueAsumeEnLaObra;

  Trabajador({
    required this.id,
    required this.nombreCompleto,
    required this.estadoCivil,
    required this.rut,
    required this.fechaDeNacimiento,
    required this.direccion,
    required this.correoElectronico,
    required this.sistemaDeSalud,
    required this.previsionAfp,
    required this.obraEnLaQueTrabaja,
    required this.rolQueAsumeEnLaObra,
  });

  factory Trabajador.fromJson(Map<String, dynamic> json) {
    return Trabajador(
      id: json['id'],
      nombreCompleto: json['nombre_completo'],
      estadoCivil: json['estado_civil'],
      rut: json['rut'],
      fechaDeNacimiento: DateTime.parse(json['fecha_de_nacimiento']),
      direccion: json['direccion'],
      correoElectronico: json['correo_electronico'],
      sistemaDeSalud: json['sistema_de_salud'],
      previsionAfp: json['prevision_afp'],
      obraEnLaQueTrabaja: json['obra_en_la_que_trabaja'],
      rolQueAsumeEnLaObra: json['rol_que_asume_en_la_obra'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre_completo': nombreCompleto,
      'estado_civil': estadoCivil,
      'rut': rut,
      'fecha_de_nacimiento': fechaDeNacimiento.toIso8601String(),
      'direccion': direccion,
      'correo_electronico': correoElectronico,
      'sistema_de_salud': sistemaDeSalud,
      'prevision_afp': previsionAfp,
      'obra_en_la_que_trabaja': obraEnLaQueTrabaja,
      'rol_que_asume_en_la_obra': rolQueAsumeEnLaObra,
    };
  }
}
