class Proveedor {
  final String id;
  final String nombreVendedor;
  final String rut;
  final String direccion;
  final String telefonoVendedor;
  final String correoVendedor;
  final String estado;
  final DateTime fechaRegistro;

  Proveedor({
    required this.id,
    required this.nombreVendedor,
    required this.rut,
    required this.direccion,
    required this.telefonoVendedor,
    required this.correoVendedor,
    required this.estado,
    required this.fechaRegistro,
  });

  factory Proveedor.fromJson(Map<String, dynamic> json) {
    return Proveedor(
      id: json['id'],
      nombreVendedor: json['nombre_vendedor'] ?? '',
      rut: json['rut'] ?? '',
      direccion: json['direccion'] ?? '',
      telefonoVendedor: json['telefono_vendedor'] ?? '',
      correoVendedor: json['correo_vendedor'] ?? '',
      estado: json['estado'] ?? '',
      fechaRegistro: DateTime.parse(json['fecha_registro']),
    );
  }
}

class OrdenCompra {
  final String id;
  final String numeroOrden;
  final DateTime fechaEmision;
  final String centroCosto;
  final String? seccionItemizado; // opcional
  final String numeroCotizacion;
  final String numeroContacto;
  final String nombreServicio;
  final int valor;
  final bool descuento;
  final String? notasAdicionales; // opcional
  final String proveedorId;
  final Proveedor proveedor;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrdenCompra({
    required this.id,
    required this.numeroOrden,
    required this.fechaEmision,
    required this.centroCosto,
    this.seccionItemizado,
    required this.numeroCotizacion,
    required this.numeroContacto,
    required this.nombreServicio,
    required this.valor,
    required this.descuento,
    this.notasAdicionales,
    required this.proveedorId,
    required this.proveedor,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrdenCompra.fromJson(Map<String, dynamic> json) {
    return OrdenCompra(
      id: json['id'],
      numeroOrden: json['numero_orden'] ?? '',
      fechaEmision: DateTime.parse(json['fecha_emision']),
      centroCosto: json['centro_costo'] ?? '',
      seccionItemizado: json['seccion_itemizado'], // puede ser null
      numeroCotizacion: json['numero_cotizacion'] ?? '',
      numeroContacto: json['numero_contacto'] ?? '',
      nombreServicio: json['nombre_servicio'] ?? '',
      valor: json['valor'] ?? 0,
      descuento: json['descuento'] ?? false,
      notasAdicionales: json['notas_adicionales'], // puede ser null
      proveedorId: json['proveedor']?['id'] ?? '',
      proveedor: Proveedor.fromJson(json['proveedor']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
