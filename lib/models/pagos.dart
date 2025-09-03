class Pago {
  final String id;
  final String nombreMandante;
  final String rutMandante;
  final String direccionComercial;
  final String codigo;
  final String servicioOfrecido;
  final double valor;
  final DateTime plazoPagar;
  final String estadoPago;
  final String fotografiaId;
  final String tipoPago;
  final bool sentido;
  final String visualizacion;

  Pago({
    required this.id,
    required this.nombreMandante,
    required this.rutMandante,
    required this.direccionComercial,
    required this.codigo,
    required this.servicioOfrecido,
    required this.valor,
    required this.plazoPagar,
    required this.estadoPago,
    required this.fotografiaId,
    required this.tipoPago,
    required this.sentido,
    required this.visualizacion,
  });

  factory Pago.fromMap(Map<String, dynamic> map) {
    return Pago(
      id: map['id'],
      nombreMandante: map['nombre_mandante'],
      rutMandante: map['rut_mandante'],
      direccionComercial: map['direccion_comercial'],
      codigo: map['codigo'],
      servicioOfrecido: map['servicio_ofrecido'],
      valor: map['valor'] is int ? (map['valor'] as int).toDouble() : map['valor'],
      plazoPagar: DateTime.parse(map['plazo_pagar']),
      estadoPago: map['estado_pago'],
      fotografiaId: map['fotografia_id'],
      tipoPago: map['tipo_pago'],
      sentido: map['sentido'],
      visualizacion: map['visualizacion'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre_mandante': nombreMandante,
      'rut_mandante': rutMandante,
      'direccion_comercial': direccionComercial,
      'codigo': codigo,
      'servicio_ofrecido': servicioOfrecido,
      'valor': valor,
      'plazo_pagar': plazoPagar.toIso8601String(),
      'estado_pago': estadoPago,
      'fotografia_id': fotografiaId,
      'tipo_pago': tipoPago,
      'sentido': sentido,
      'visualizacion': visualizacion,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pago &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
