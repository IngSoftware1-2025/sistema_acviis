class Vehiculo {
  final String id;
  final String patente;
  final String permisoCirc;
  final DateTime revisionTecnica;
  final DateTime revisionGases;
  final DateTime ultimaMantencion;
  final String? descripcionMant;
  final int capacidadKg;
  final String neumaticos;
  final bool ruedaRepuesto;
  final String? observaciones;
  final String estado;
  final DateTime proximaMantencion;

  Vehiculo({
    required this.id,
    required this.patente,
    required this.permisoCirc,
    required this.revisionTecnica,
    required this.revisionGases,
    required this.ultimaMantencion,
    this.descripcionMant,
    required this.capacidadKg,
    required this.neumaticos,
    required this.ruedaRepuesto,
    this.observaciones,
    required this.estado,
    required this.proximaMantencion,
  });

  factory Vehiculo.fromJson(Map<String, dynamic> json) {
    return Vehiculo(
      id: json['id'],
      patente: json['patente'],
      permisoCirc: json['permiso_circ'],
      revisionTecnica: DateTime.parse(json['revision_tecnica']),
      revisionGases: DateTime.parse(json['revision_gases']),
      ultimaMantencion: DateTime.parse(json['ultima_mantencion']),
      descripcionMant: json['descripcion_mant'],
      capacidadKg: json['capacidad_kg'],
      neumaticos: json['neumaticos'],
      ruedaRepuesto: json['rueda_repuesto'] ?? false,
      observaciones: json['observaciones'],
      estado: json['estado'],
      proximaMantencion: DateTime.parse(json['proxima_mantencion']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patente': patente,
      'permiso_circ': permisoCirc,
      'revision_tecnica': revisionTecnica.toIso8601String(),
      'revision_gases': revisionGases.toIso8601String(),
      'ultima_mantencion': ultimaMantencion.toIso8601String(),
      'descripcion_mant': descripcionMant,
      'capacidad_kg': capacidadKg,
      'neumaticos': neumaticos,
      'rueda_repuesto': ruedaRepuesto,
      'observaciones': observaciones,
      'estado': estado,
      'proxima_mantencion': proximaMantencion.toIso8601String(),
    };
  }
}
