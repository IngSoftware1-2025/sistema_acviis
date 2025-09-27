import 'package:sistema_acviis/models/proveedor.dart';

class OrdenCompra {
  final String id;
  final String numeroOrden;
  final DateTime fechaEmision;
  final String centroCosto;
  final String? seccionItemizado;
  final String numeroCotizacion;
  final String? numeroContacto; 
  final String nombreServicio;
  final int valor;
  final bool descuento;
  final String? notasAdicionales;
  final String estado;
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
    this.numeroContacto, 
    required this.nombreServicio,
    required this.valor,
    required this.descuento,
    this.notasAdicionales,
    required this.estado,
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
      seccionItemizado: json['seccion_itemizado'],
      numeroCotizacion: json['numero_cotizacion'] ?? '',
      numeroContacto: json['numero_contacto'] ?? '', 
      nombreServicio: json['nombre_servicio'] ?? '',
      valor: json['valor'] ?? 0,
      descuento: json['descuento'] ?? false,
      notasAdicionales: json['notas_adicionales'],
      estado: json['estado'] ?? 'Activo',
      proveedorId: json['proveedor']?['id'] ?? '',
      proveedor: Proveedor.fromMap(json['proveedor']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
