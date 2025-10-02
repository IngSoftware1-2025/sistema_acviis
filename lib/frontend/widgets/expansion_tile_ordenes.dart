import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/ordenes.dart';
import 'package:intl/intl.dart';

class ExpansionTileOrdenes extends StatelessWidget {
  final OrdenCompra orden;

  const ExpansionTileOrdenes({Key? key, required this.orden}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(orden.nombreServicio),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Proveedor: ${orden.proveedor.nombre_vendedor}'),
          Text(
            'Estado: ${orden.estado}',
            style: TextStyle(
              color: orden.estado == 'De baja' ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
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
          subtitle: Text(orden.itemizado.nombre),
        ),
        ListTile(
          title: const Text('Número de cotización'),
          subtitle: Text(orden.numeroCotizacion),
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
          subtitle: Text(orden.descuento ? 'Sí' : 'No'),
        ),
        ListTile(
          title: const Text('Estado'),
          subtitle: Text(orden.estado),
        ),
        ListTile(
          title: const Text('Contacto proveedor'),
          subtitle: Text(orden.proveedor.telefono_vendedor),
        ),
        ListTile(
          title: const Text('Correo proveedor'),
          subtitle: Text(orden.proveedor.correo_electronico),
        ),
        ListTile(
          title: const Text('Notas adicionales'),
          subtitle: Text(orden.notasAdicionales ?? 'Sin notas'),
        ),
      ],
    );
  }
}
