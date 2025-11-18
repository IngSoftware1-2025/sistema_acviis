import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/herramienta.dart';
import 'package:intl/intl.dart';

class ExpansionTileHerramienta extends StatelessWidget {
  final Herramienta herramienta;

  const ExpansionTileHerramienta({Key? key, required this.herramienta}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(herramienta.tipo),
      subtitle: Text('Estado: ${herramienta.estado}'),
      children: [
        ListTile(
          title: Text('Garantía'),
          subtitle: Text(
            herramienta.garantia != null 
            ? DateFormat('yyyy-MM-dd').format(herramienta.garantia!) :
            'Sin garantía',
          ),
        ),
        ListTile(
          title: Text('Cantidad Total'),
          subtitle: Text(herramienta.cantidadTotal.toString()),
        ),
        ListTile(
          title: Text('Cantidad Disponible'),
          subtitle: Text(herramienta.cantidadDisponible?.toString() ?? herramienta.cantidadTotal.toString()),
        ),
      ],
    );
  }
}
