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
  final proveedorJson = json['proveedor'];
  final itemizadoJson = json['itemizado'];

  return OrdenCompra(
    id: json['id'] ?? '',
    numeroOrden: json['numero_orden'] ?? '',
    fechaEmision: DateTime.tryParse(json['fecha_emision'] ?? '') ?? DateTime.now(),
    centroCosto: json['centro_costo'] ?? '',
    numeroCotizacion: json['numero_cotizacion'] ?? '',
    numeroContacto: json['numero_contacto'],
    nombreServicio: json['nombre_servicio'] ?? '',
    valor: json['valor'] ?? 0,
    descuento: json['descuento'] ?? false,
    notasAdicionales: json['notas_adicionales'],
    estado: json['estado'] ?? 'Activo',
    proveedorId: proveedorJson?['id'] ?? '',
    proveedor: proveedorJson != null
        ? Proveedor(
            id: proveedorJson['id'] ?? '',
            rut: proveedorJson['rut'] ?? '',
            direccion: proveedorJson['direccion'] ?? '',
            nombreVendedor: proveedorJson['nombre_vendedor'] ?? '',
            productoServicio: proveedorJson['producto_servicio'] ?? '',
            correoVendedor: proveedorJson['correo_vendedor'] ?? '',
            telefonoVendedor: proveedorJson['telefono_vendedor'] ?? '',
            creditoDisponible: proveedorJson['credito_disponible'] ?? 0,
            fechaRegistro: proveedorJson['fecha_registro'] != null
                ? DateTime.parse(proveedorJson['fecha_registro'])
                : DateTime.now(),
            estado: proveedorJson['estado'],
          )
        : Proveedor(
            id: '',
            rut: '',
            direccion: '',
            nombreVendedor: '',
            productoServicio: '',
            correoVendedor: '',
            telefonoVendedor: '',
            creditoDisponible: 0,
            fechaRegistro: DateTime.now(),
          ),
    itemizado: itemizadoJson != null
        ? Itemizado.fromJson(itemizadoJson)
        : Itemizado(id: '', nombre: '', montoDisponible: 0),
  );
}

}
