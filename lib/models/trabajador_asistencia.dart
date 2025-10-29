class Trabajador {
  final String nombre;
  final String rut;
  final String cargo;
  final int fila;

  const Trabajador({
    required this.nombre,
    required this.rut,
    required this.cargo,
    required this.fila,
  });

  factory Trabajador.fromJson(Map<String, dynamic> json) => Trabajador(
        nombre: json['nombre']?.toString() ?? '',
        rut: json['rut']?.toString() ?? '',
        cargo: json['cargo']?.toString() ?? '',
        fila: json['fila'] is int ? json['fila'] as int : int.tryParse(json['fila']?.toString() ?? '') ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'rut': rut,
        'cargo': cargo,
      };

  Trabajador copyWith({String? nombre, String? rut, String? cargo, int? fila}) => Trabajador(
        nombre: nombre ?? this.nombre,
        rut: rut ?? this.rut,
        cargo: cargo ?? this.cargo,
        fila: fila ?? this.fila,
      );

  @override
  String toString() => 'Trabajador(nombre: $nombre, rut: $rut, cargo: $cargo, fila: $fila)';
}