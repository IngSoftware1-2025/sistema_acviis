import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/ordenes.dart';
import 'package:intl/intl.dart';

class ExpansionTileOrdenes extends StatelessWidget {
  final OrdenCompra orden;

  const ExpansionTileOrdenes({Key? key, required this.orden}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(orden.numeroOrden),
      subtitle: Text('Proveedor ID: ${orden.proveedorId}'),
      children: [
        ListTile(
          title: const Text('Fecha de emisión'),
          subtitle: Text(DateFormat('yyyy-MM-dd').format(orden.fechaEmision)),
        ),
        ListTile(
          title: const Text('Centro de costo'),
          subtitle: Text(orden.centroCosto),
        ),
        ListTile(
          title: const Text('Sección itemizado'),
          subtitle: Text(orden.seccionItemizado ?? 'Sin sección'),
        ),
        ListTile(
          title: const Text('Número de cotización'),
          subtitle: Text(orden.numeroCotizacion),
        ),
        ListTile(
          title: const Text('Número de contacto'),
          subtitle: Text(orden.numeroContacto),
        ),
        ListTile(
          title: const Text('Nombre del servicio'),
          subtitle: Text(orden.nombreServicio),
        ),
        ListTile(
          title: const Text('Valor'),
          subtitle: Text('\$${orden.valor}'),
        ),
        ListTile(
          title: const Text('Descuento'),
          subtitle: Text('${orden.descuento}'),
        ),
        ListTile(
          title: const Text('Notas adicionales'),
          subtitle: Text(orden.notasAdicionales ?? 'Sin notas'),
        ),
      ],
    );
  }
}
