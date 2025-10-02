import 'package:sistema_acviis/models/proveedor.dart';
import 'package:sistema_acviis/models/itemizado.dart';

class OrdenCompra {
  final String id;
  final String numeroOrden;
  final DateTime fechaEmision;
  final String centroCosto;
  final String numeroCotizacion;
  final String? numeroContacto; 
  final String nombreServicio;
  final int valor;
  final bool descuento;
  final String? notasAdicionales;
  final String estado;
  final String proveedorId;
  final Proveedor proveedor;
  final Itemizado itemizado; 

  OrdenCompra({
    required this.id,
    required this.numeroOrden,
    required this.fechaEmision,
    required this.centroCosto,
    required this.numeroCotizacion,
    this.numeroContacto, 
    required this.nombreServicio,
    required this.valor,
    required this.descuento,
    this.notasAdicionales,
    required this.estado,
    required this.proveedorId,
    required this.proveedor,
    required this.itemizado, 
  });

  factory OrdenCompra.fromJson(Map<String, dynamic> json) {
    return OrdenCompra(
      id: json['id'] ?? '',
      numeroOrden: json['numero_orden'] ?? '',
      fechaEmision: DateTime.parse(json['fecha_emision']),
      centroCosto: json['centro_costo'] ?? '',
      numeroCotizacion: json['numero_cotizacion'] ?? '',
      numeroContacto: json['numero_contacto'] ?? '', 
      nombreServicio: json['nombre_servicio'] ?? '',
      valor: json['valor'] ?? 0,
      descuento: json['descuento'] ?? false,
      notasAdicionales: json['notas_adicionales'],
      estado: json['estado'] ?? 'Activo',
      proveedorId: json['proveedor']?['id'] ?? '',
      proveedor: Proveedor.fromMap(json['proveedor']),
      itemizado: Itemizado.fromJson(json['itemizado']), 
    );
  }
}
